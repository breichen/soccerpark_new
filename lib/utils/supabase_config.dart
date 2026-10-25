/// Zugangsdaten für die Online-Highscores in Supabase.
///
/// Zu finden im Supabase-Dashboard unter Project Settings -> API:
///  - [supabaseUrl]: "Project URL", z. B. https://abcdefgh.supabase.co
///  - [supabaseAnonKey]: der "anon"/"publishable" Key (NICHT der
///    "service_role"/"secret" Key!). Dieser Key ist öffentlich und darf in
///    der App stehen; was er darf, regelt das SQL-Skript in
///    supabase/online_highscores.sql (nur lesen + submit_highscore).
///
/// Solange einer der Werte leer ist, ist die Online-Bestenliste abgeschaltet
/// und die App verhält sich wie bisher.
const String supabaseUrl = 'https://pcrxhufbazkfsjgezzui.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjcnhodWZiYXprZnNqZ2V6enVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI5NDg0MTAsImV4cCI6MjEwODUyNDQxMH0.hp5m8aSkmQxahirRKwFUvNlQmXQRHa-b9x2u92zVmf8';
