# Mad Monkey — repo notes for Claude

## Logo usage
- Use the **monkey-face icon** (no wordmark) as the primary Mad Monkey logo on
  pages in this repo — e.g. site nav / top-left. Prefer it over the full
  wordmark `photos/logo-black.png` unless a full wordmark is specifically wanted.
- Two versions:
  - `photos/mad-monkey-icon.png` — black on transparent, for LIGHT backgrounds.
  - `photos/mad-monkey-icon-white.png` — white silhouette with the face features
    knocked out (transparent), for DARK backgrounds.
- Do NOT just `filter:invert()` the black icon on a dark background — inverting
  flips the white face to black and the friendly monkey looks "evil". Use the
  dedicated `-white` version instead.

## Giveaway pages
- `dnb-thailand-giveaway.html` — DnB All Stars Thailand giveaway. Entries save to
  the Supabase table `dnb_thailand_entries` (insert-only RLS; view/draw winners
  from the Supabase dashboard). Setup SQL: `supabase-dnb-thailand-setup.sql`.
- Brand fonts: Anton (display) + Inter (body) match the DnB All Stars brand.
