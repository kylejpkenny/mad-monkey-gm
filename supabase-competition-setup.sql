-- Mad Monkey — Siargao Giveaway landing page — Supabase setup
-- Run ONCE in the Supabase SQL editor for project ksvzfkqmljqojwzauaim.
-- Dashboard → SQL Editor → New Query → paste → Run.
--
-- SECURITY NOTE — this page is PUBLIC, so entrant PII (names, emails, IG handles)
-- must never be readable with the publishable/anon key. The public can only
-- INSERT (submit an entry). You read entries from the Supabase dashboard, or via
-- the service-role key on a trusted machine — never from the browser.

-- 1. Entries table -----------------------------------------------------------
create table if not exists competition_entries (
  id          uuid        primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  full_name   text        not null,
  email       text        not null,
  whatsapp    text        not null,   -- WhatsApp number incl. country code
  instagram   text,                   -- @handle, optional
  campaign    text,                   -- e.g. 'siargao-giveaway'
  -- ad attribution (captured from the URL query string, never shown to the user)
  utm_source   text,
  utm_medium   text,
  utm_campaign text,
  utm_content  text,
  utm_term     text,
  source_country text,                -- from ?country= if present
  page_url     text,
  user_agent   text
);

-- If the table already exists from an earlier run, add the WhatsApp column.
alter table competition_entries add column if not exists whatsapp text;

-- 2. Row Level Security — enable, then allow INSERT ONLY for the public key.
--    No SELECT/UPDATE/DELETE policy ⇒ the anon/publishable key cannot read,
--    edit, or delete entries. Service role (dashboard) bypasses RLS.
alter table competition_entries enable row level security;

drop policy if exists "competition_entries public insert" on competition_entries;
create policy "competition_entries public insert" on competition_entries
  for insert
  with check (true);

-- 2b. Table-level GRANT. RLS gates WHICH rows; this GRANT allows the operation at
--     all. INSERT only — no SELECT/UPDATE/DELETE grant ⇒ the public key still
--     can't read, edit, or delete entries.
grant insert on table competition_entries to anon, authenticated;

-- To draw a winner later, run this in the dashboard (service role bypasses RLS):
--   select * from competition_entries
--   where campaign = 'siargao-giveaway'
--   order by random() limit 1;
