# Mad Monkey — repo notes for Claude

## Logo usage
- Use **`photos/mad-monkey-icon.png`** (the monkey-face icon, no wordmark) as the
  primary Mad Monkey logo on pages in this repo — e.g. site nav / top-left.
  Prefer it over the full wordmark `photos/logo-black.png` unless a full
  wordmark is specifically wanted (e.g. a footer signature).
- The icon is black on transparent; on dark backgrounds apply
  `filter:invert(1) brightness(2)` to render it white.

## Giveaway pages
- `dnb-thailand-giveaway.html` — DnB All Stars Thailand giveaway. Entries save to
  the Supabase table `dnb_thailand_entries` (insert-only RLS; view/draw winners
  from the Supabase dashboard). Setup SQL: `supabase-dnb-thailand-setup.sql`.
- Brand fonts: Anton (display) + Inter (body) match the DnB All Stars brand.
