# Project: kids_romanian

A single-file static web app for a 9-year-old practicing Romanian between tutor lessons. Currently personal/family use; invite-only multi-family planned.

## Stack

- Static HTML/CSS/JS — `index.html` is the entire app, no build step, no framework
- Deployed to Vercel from GitHub (`raficohen17/kids_romanian`, main branch)
- Browser `SpeechSynthesis` for TTS with `ro-RO` / `en-US` voices
- `localStorage` for local persistence today (guest mode + offline cache after backend lands)
- Supabase for auth, Postgres, Realtime
- Vercel serverless functions in `/api/` for any code that must hold a secret (e.g. `OPENROUTER_API_KEY` for the chat feature). Keep this surface minimal — anything possible from the browser stays in the browser.

## Constraints

- Keep the "single HTML file" feel for the frontend — `index.html` is still the whole app; `/api/` is a thin secret-holding proxy, not a sprawling backend
- Minimize external dependencies; add SDKs via CDN/ESM in the browser; Node deps in `/api/` should be zero or near-zero (prefer raw `fetch`)
- Hebrew RTL UI for the kid; must work on iPad and laptop
- Zero ops: deploys are `git push`; backend must be SaaS not self-hosted
- Free-tier costs only at family scale (≤ 20 families, ≤ 100 profiles)

## Conventions

- Single admin: `raficohen17@gmail.com` (gated server-side, not exposed in HTML)
- All user-typed content runs through `escapeHtml` before rendering
- Translations / labels in Hebrew; identifiers and code comments in English
