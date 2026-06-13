-- Mad Monkey — GM Recruitment landing page — Supabase setup
-- Run ONCE in the Supabase SQL editor for project ksvzfkqmljqojwzauaim.
-- Dashboard → SQL Editor → New Query → paste → Run.
--
-- SECURITY NOTE — this is intentionally STRICTER than the internal dashboard's
-- `allow_all` policy. This page is PUBLIC, so applicant PII (names, emails) and
-- CV files must never be readable with the publishable/anon key. The public can
-- only INSERT (submit an application). Recruiters read rows + download CVs from
-- the Supabase dashboard, or via short-lived signed URLs created with the
-- service-role key on a trusted machine — never from the browser.

-- 1. Applications table -------------------------------------------------------
create table if not exists gm_applications (
  id          uuid        primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  full_name   text        not null,
  email       text        not null,
  cv_url      text,                   -- public link to view the CV (click in the table editor)
  cv_path     text        not null,   -- object path inside the gm-cvs bucket
  cv_name     text,                   -- original filename, for the recruiter's convenience
  role        text        not null default 'GM',
  intake      text,                   -- e.g. 'Q4'
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

-- If the table already exists from an earlier run, add the CV link column.
alter table gm_applications add column if not exists cv_url text;

-- 2. Row Level Security — enable, then allow INSERT ONLY for the public key.
--    No SELECT/UPDATE/DELETE policy ⇒ the anon/publishable key cannot read,
--    edit, or delete applications. Service role (dashboard) bypasses RLS.
alter table gm_applications enable row level security;

drop policy if exists "gm_applications public insert" on gm_applications;
create policy "gm_applications public insert" on gm_applications
  for insert
  with check (true);

-- 2b. Table-level GRANT. RLS gates WHICH rows; this GRANT allows the operation at
--     all. This project doesn't auto-grant anon on new tables, so it's required.
--     INSERT only — no SELECT/UPDATE/DELETE grant ⇒ the public key still can't
--     read, edit, or delete applications.
grant insert on table gm_applications to anon, authenticated;

-- 3. CV storage bucket — PUBLIC, so the CV link in your Google Sheet opens the file.
--    Object paths are long random UUIDs (unguessable), so CVs aren't listable or
--    discoverable — but anyone with the exact link can open it. That's the standard
--    trade-off for a clickable "View CV" link. If you need stricter control, say so
--    and we'll switch to time-limited signed links instead.
insert into storage.buckets (id, name, public)
  values ('gm-cvs', 'gm-cvs', true)
  on conflict (id) do update set public = true;

-- 4. Storage policy — the public may UPLOAD a CV. Reads happen via the public URL
--    (public buckets serve files without an RLS read policy).
drop policy if exists "gm-cvs public upload" on storage.objects;
create policy "gm-cvs public upload" on storage.objects
  for insert
  with check (bucket_id = 'gm-cvs');

-- (Deliberately NO select/update/delete policy for the anon role on gm-cvs.)

-- Optional hardening you can set in the dashboard:
--   Storage → gm-cvs → Settings → restrict allowed MIME types to
--   application/pdf, application/msword,
--   application/vnd.openxmlformats-officedocument.wordprocessingml.document
--   and set a max file size (e.g. 10 MB). The page also validates client-side.
