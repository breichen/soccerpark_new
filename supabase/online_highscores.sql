-- =====================================================================
-- Soccerpark: Online-Highscores
--   * Monatswertung: Top 50 pro Anlage und Monat (bleibt als Archiv)
--   * Tageswertung:  Top 20 pro Anlage für den aktuellen Tag
--     (Einträge vergangener Tage werden gelöscht, außer sie sind in der
--     Monatswertung)
--
-- Einmalig im Supabase-Dashboard ausführen: SQL Editor -> New query ->
-- diesen Inhalt einfügen -> Run. Das Skript kann gefahrlos erneut
-- ausgeführt werden; vorhandene Einträge bleiben erhalten.
-- =====================================================================

create table if not exists public.online_highscores (
  id          bigint generated always as identity primary key,
  locality    text        not null check (locality in ('salzburg', 'wagrain', 'goldberg')),
  month       text        not null check (month ~ '^[0-9]{4}-[0-9]{2}$'),  -- z. B. '2026-10'
  name        text        not null check (char_length(name) between 2 and 20),
  total       integer     not null,
  holes       smallint[]  not null check (array_length(holes, 1) = 18),
  created_at  timestamptz not null default now()
);

-- Tag (Europe/Vienna) für die Tageswertung, z. B. '2026-10-26'.
alter table public.online_highscores add column if not exists day text;
update public.online_highscores
  set day = to_char(created_at at time zone 'Europe/Vienna', 'YYYY-MM-DD')
  where day is null;

create index if not exists online_highscores_ranking_idx
  on public.online_highscores (locality, month, total, created_at, id);
create index if not exists online_highscores_day_idx
  on public.online_highscores (locality, day, total, created_at, id);

-- Row Level Security: die App darf nur lesen.
-- Eintragen geht ausschließlich über die Funktion submit_highscore().
alter table public.online_highscores enable row level security;

drop policy if exists "Highscores sind öffentlich lesbar" on public.online_highscores;
create policy "Highscores sind öffentlich lesbar"
  on public.online_highscores for select
  to anon, authenticated
  using (true);

revoke insert, update, delete on public.online_highscores from anon, authenticated;
grant select on public.online_highscores to anon, authenticated;

-- ---------------------------------------------------------------------
-- Trägt eine volle Runde ein und räumt danach auf: behalten wird, was in
-- der Monats-Top-50 ist oder vom heutigen Tag in der Tages-Top-20.
-- Gibt {"month_rank": 1-50 | null, "day_rank": 1-20 | null} zurück
-- (null = nicht bzw. nicht mehr in dieser Wertung).
-- Monat und Tag werden am Server bestimmt (Zeitzone Europe/Vienna).
-- Bei gleicher Schlagzahl liegt der frühere Eintrag vorne.
-- ---------------------------------------------------------------------
drop function if exists public.submit_highscore(text, text, integer[]);

create function public.submit_highscore(
  p_locality text,
  p_name     text,
  p_holes    integer[]
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_now   timestamp := now() at time zone 'Europe/Vienna';
  v_month text := to_char(v_now, 'YYYY-MM');
  v_day   text := to_char(v_now, 'YYYY-MM-DD');
  v_name  text := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  v_total integer;
  v_id    bigint;
  v_mrank integer;
  v_drank integer;
begin
  if p_locality not in ('salzburg', 'wagrain', 'goldberg') then
    raise exception 'invalid locality';
  end if;
  if char_length(v_name) not between 2 and 20 then
    raise exception 'invalid name';
  end if;
  if p_holes is null
     or array_length(p_holes, 1) is distinct from 18
     or exists (select 1 from unnest(p_holes) h where h is null or h < 1 or h > 20) then
    raise exception 'invalid holes';
  end if;

  select sum(h) into v_total from unnest(p_holes) h;

  -- Gleichzeitige Einträge für dieselbe Anlage nacheinander abarbeiten.
  perform pg_advisory_xact_lock(hashtext('online_highscores:' || p_locality));

  insert into online_highscores (locality, month, day, name, total, holes)
  values (p_locality, v_month, v_day, v_name, v_total, p_holes::smallint[])
  returning id into v_id;

  -- Aufräumen.
  with ranked as (
    select id, day,
           row_number() over (partition by month order by total, created_at, id) as mrank,
           row_number() over (partition by day   order by total, created_at, id) as drank
    from online_highscores
    where locality = p_locality
  )
  delete from online_highscores h
  using ranked r
  where h.id = r.id
    and r.mrank > 50
    and not (r.day = v_day and r.drank <= 20);

  -- Plätze des neuen Eintrags.
  select r.mrank into v_mrank
  from (
    select id, row_number() over (order by total, created_at, id) as mrank
    from online_highscores
    where locality = p_locality and month = v_month
  ) r
  where r.id = v_id and r.mrank <= 50;

  select r.drank into v_drank
  from (
    select id, row_number() over (order by total, created_at, id) as drank
    from online_highscores
    where locality = p_locality and day = v_day
  ) r
  where r.id = v_id and r.drank <= 20;

  return json_build_object('month_rank', v_mrank, 'day_rank', v_drank);
end;
$$;

revoke all on function public.submit_highscore(text, text, integer[]) from public;
grant execute on function public.submit_highscore(text, text, integer[]) to anon, authenticated;
