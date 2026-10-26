-- =====================================================================
-- Soccerpark: Neuigkeiten für die App
--
-- Einmalig im Supabase-Dashboard ausführen (SQL Editor -> New query ->
-- einfügen -> Run). Kann gefahrlos erneut ausgeführt werden.
--
-- Beiträge legst du danach im Table Editor in der Tabelle "news" an.
-- Die App zeigt nur Beiträge, deren Zeitraum gerade läuft:
--   visible_from <= jetzt  und  (visible_until leer oder > jetzt)
-- Abgelaufene Beiträge bleiben in der Tabelle, die App sieht sie nicht.
-- =====================================================================

create table if not exists public.news (
  id             bigint generated always as identity primary key,
  -- Anlage; leer = für alle Anlagen
  locality       text check (locality in ('salzburg', 'wagrain', 'goldberg')),
  title_de       text not null,
  body_de        text not null default '',
  -- Englisch optional; fehlt es, zeigt die App den deutschen Text
  title_en       text,
  body_en        text,
  -- Optional: Bild (öffentliche Adresse) und Link für "Mehr erfahren"
  image_url      text,
  link_url       text,
  -- Sichtbarkeit (Zeitzone beachten: Supabase zeigt UTC an)
  visible_from   timestamptz not null default now(),
  visible_until  timestamptz,
  created_at     timestamptz not null default now()
);

create index if not exists news_visible_idx
  on public.news (locality, visible_from desc);

-- Die App darf nur aktuelle Beiträge lesen, nichts ändern.
alter table public.news enable row level security;

drop policy if exists "Aktuelle Neuigkeiten sind öffentlich lesbar" on public.news;
create policy "Aktuelle Neuigkeiten sind öffentlich lesbar"
  on public.news for select
  to anon, authenticated
  using (visible_from <= now() and (visible_until is null or visible_until > now()));

revoke insert, update, delete on public.news from anon, authenticated;
grant select on public.news to anon, authenticated;
