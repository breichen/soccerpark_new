// Supabase Edge Function "push-topics"
//
// Meldet den Push-Token eines Browsers (Web-Version der App) bei einem
// Firebase-Thema an, z. B. "lang_de", und bei anderen ab. Browser können das
// nicht selbst; Android/iOS erledigen es direkt in der App.
//
// Aufruf (POST, JSON):
//   { "token": "<FCM-Token>", "topic": "lang_de", "remove": ["lang_en"] }
//
// Benötigt das Secret FIREBASE_SERVICE_ACCOUNT = kompletter Inhalt der
// JSON-Datei eines Firebase-Dienstkontos (Projekteinstellungen →
// Dienstkonten → Neuen privaten Schlüssel generieren).

const ALLOWED_TOPICS = new Set([
  "lang_de",
  "lang_en",
  "dev_lang_de", // Debug-Builds, damit Tests keine echten Nutzer erreichen
  "dev_lang_en",
]);

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

// ---------------------------------------------------------------------
// Google-Zugriffstoken aus dem Dienstkonto (JWT, RS256, Web Crypto)
// ---------------------------------------------------------------------

type ServiceAccount = { client_email: string; private_key: string };
let cachedToken: { value: string; expires: number } | null = null;

function base64url(data: Uint8Array | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function accessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expires - 60 > now) return cachedToken.value;

  const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!raw) throw new Error("Secret FIREBASE_SERVICE_ACCOUNT fehlt");
  const sa = JSON.parse(raw) as ServiceAccount;

  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/cloud-platform " +
      "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const unsigned = `${header}.${claims}`;

  const pem = sa.private_key
    .replace(/-----[^-]+-----/g, "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );
  const jwt = `${unsigned}.${base64url(signature)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) throw new Error(`OAuth ${res.status}: ${await res.text()}`);
  const data = await res.json();
  cachedToken = { value: data.access_token, expires: now + (data.expires_in ?? 3600) };
  return cachedToken.value;
}

// ---------------------------------------------------------------------
// Themen-Verwaltung von Firebase Cloud Messaging
// ---------------------------------------------------------------------

async function topicChange(op: "batchAdd" | "batchRemove", topic: string, token: string) {
  const res = await fetch(`https://iid.googleapis.com/iid/v1:${op}`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${await accessToken()}`,
      "access_token_auth": "true",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ to: `/topics/${topic}`, registration_tokens: [token] }),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${op} ${topic} ${res.status}: ${text}`);
  // Fehler einzelner Tokens stehen in results[].error
  const error = JSON.parse(text)?.results?.[0]?.error;
  if (error) throw new Error(`${op} ${topic}: ${error}`);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "method not allowed" }, 405);

  let body: { token?: unknown; topic?: unknown; remove?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid json" }, 400);
  }

  const token = body.token;
  const topic = body.topic;
  const remove = Array.isArray(body.remove) ? body.remove : [];
  if (typeof token !== "string" || token.length < 20 || token.length > 4096) {
    return json({ error: "invalid token" }, 400);
  }
  if (typeof topic !== "string" || !ALLOWED_TOPICS.has(topic)) {
    return json({ error: "invalid topic" }, 400);
  }
  if (!remove.every((t) => typeof t === "string" && ALLOWED_TOPICS.has(t))) {
    return json({ error: "invalid remove" }, 400);
  }

  try {
    for (const t of remove as string[]) {
      if (t !== topic) await topicChange("batchRemove", t, token);
    }
    await topicChange("batchAdd", topic, token);
    return json({ ok: true, topic });
  } catch (e) {
    console.error(e);
    return json({ error: String(e) }, 502);
  }
});
