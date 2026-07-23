-- Mad Monkey — DnB All Stars Thailand Giveaway — Supabase setup
-- Run ONCE in the Supabase SQL editor for project ksvzfkqmljqojwzauaim.
-- Dashboard → SQL Editor → New Query → paste → Run.
--
-- This gives the DnB giveaway its OWN table, separate from the Siargao
-- competition_entries table.
--
-- SECURITY NOTE — the giveaway page is PUBLIC, so entrant PII (names,
-- emails, WhatsApp numbers) must never be readable with the publishable/
-- anon key. The public can only INSERT (submit an entry). You read entries
-- from the Supabase dashboard, or via the service-role key on a trusted
-- machine — never from the browser.

-- 1. Entries table -----------------------------------------------------------
create table if not exists dnb_thailand_entries (
  id          uuid        primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  full_name   text        not null,
  email       text        not null,
  whatsapp    text        not null,   -- WhatsApp number incl. country code
  campaign    text        default 'dnb-thailand-giveaway',
  -- ad / referral attribution (captured from the URL query string, never shown to the user)
  utm_source   text,
  utm_medium   text,
  utm_campaign text,
  utm_content  text,
  utm_term     text,
  source_country text,                -- from ?country= if present
  page_url     text,
  user_agent   text
);

-- 2. Row Level Security — enable, then allow INSERT ONLY for the public key.
--    No SELECT/UPDATE/DELETE policy ⇒ the anon/publishable key cannot read,
--    edit, or delete entries. Service role (dashboard) bypasses RLS.
alter table dnb_thailand_entries enable row level security;

drop policy if exists "dnb_thailand_entries public insert" on dnb_thailand_entries;
create policy "dnb_thailand_entries public insert" on dnb_thailand_entries
  for insert
  with check (true);

-- 2b. Table-level GRANT. RLS gates WHICH rows; this GRANT allows the operation
--     at all. INSERT only — no SELECT/UPDATE/DELETE grant ⇒ the public key
--     still can't read, edit, or delete entries.
grant insert on table dnb_thailand_entries to anon, authenticated;

-- 3. View your entries (run in the dashboard; service role bypasses RLS):
--   select created_at, full_name, email, whatsapp
--   from dnb_thailand_entries
--   order by created_at desc;
--
-- 4. Draw a winner after entries close:
--   select full_name, email, whatsapp
--   from dnb_thailand_entries
--   order by random() limit 1;
