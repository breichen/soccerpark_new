-- =====================================================================
-- Soccerpark: monatliche Online-Highscores (Top 50 pro Anlage und Monat)
--
-- Einmalig im Supabase-Dashboard ausführen: SQL Editor -> New query ->
-- diesen Inhalt einfügen -> Run. Das Skript kann gefahrlos erneut
-- ausgeführt werden.
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

create index if not exists online_highscores_ranking_idx
  on public.online_highscores (locality, month, total, created_at, id);

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
-- Trägt eine volle Runde ein und behält danach nur die Top 50 des
-- Monats für diese Anlage. Gibt den erreichten Platz zurück (1-50),
-- oder NULL, wenn die Runde inzwischen nicht mehr gereicht hat.
-- Monat wird am Server bestimmt (Zeitzone Europe/Vienna).
-- Bei gleicher Schlagzahl liegt der frühere Eintrag vorne.
-- ---------------------------------------------------------------------
create or replace function public.submit_highscore(
  p_locality text,
  p_name     text,
  p_holes    integer[]
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_month text := to_char(now() at time zone 'Europe/Vienna', 'YYYY-MM');
  v_name  text := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  v_total integer;
  v_id    bigint;
  v_rank  integer;
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

  -- Gleichzeitige Einträge für dieselbe Liste nacheinander abarbeiten.
  perform pg_advisory_xact_lock(hashtext('online_highscores:' || p_locality || ':' || v_month));

  insert into online_highscores (locality, month, name, total, holes)
  values (p_locality, v_month, v_name, v_total, p_holes::smallint[])
  returning id into v_id;

  -- Alles ab Platz 51 entfernen.
  delete from online_highscores
  where id in (
    select id from online_highscores
    where locality = p_locality and month = v_month
    order by total, created_at, id
    offset 50
  );

  select r.rank into v_rank
  from (
    select id, row_number() over (order by total, created_at, id) as rank
    from online_highscores
    where locality = p_locality and month = v_month
  ) r
  where r.id = v_id;

  return v_rank;  -- NULL, falls nicht (mehr) in den Top 50
end;
$$;

revoke all on function public.submit_highscore(text, text, integer[]) from public;
grant execute on function public.submit_highscore(text, text, integer[]) to anon, authenticated;
