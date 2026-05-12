# Change: add-supabase-multifamily-auth

## Why

Today the app is single-file static HTML with all state in `localStorage`. That has been fine for one kid on one device, but it does not support:

- **Sync**: words added on the laptop don't appear on the iPad
- **Persistence**: a browser cache clear wipes the dictionary and the streak
- **Other families**: cousin Yael's family cannot use the app as their own without overwriting Maya's data
- **Real auth**: today's "admin PIN" is a UI lock that anyone with DevTools sees through

We want real user accounts, server-side persistence, and per-family isolation, **without** losing:

- Static single-file deployment to Vercel (no build step, no Next.js migration)
- Public guest mode where anyone can practice with the built-in 25 words + 200 sentences
- $0/month at family scale

## What Changes

- Provision a Supabase project; use Auth + Postgres + Realtime
- **Magic-link sign-in** for parents (passwordless, email-only)
- **Invite-only**: `allowed_emails` table gates which emails can sign up; Rafi is the sole admin
- **Families table** with one owner per family (multi-owner deferred to future)
- **Netflix-style profile picker** after parent sign-in; each kid is a `profiles` row
- **Optional per-kid PIN** stored plain-text on `profiles.pin` (sibling-friction tier, not security)
- **Family-shared dictionary**: `vocab` and `sentences` scope to `family_id`; the dad adds a word, every kid sees it
- **Per-profile progress**: `score`, `best_streak`, `seen` live on a profile-keyed row
- **Access-request contact form** visible to guests; submissions land in Supabase, hidden from other guests
- **Realtime indicator** on the admin tab when new access requests arrive (no email infrastructure)
- **Pure-ephemeral guest mode**: no Supabase calls for unauthenticated visitors; built-in corpus + `localStorage` for score/streak only
- Schema reserves forward-compat columns (`pack_id`) and tables (`families`) for pack-sharing without committing to building it

## Out of Scope (captured for future)

- **Pack sharing across families** — `pack_id NULL` today; design preserved so a future change can add a `packs` table and "subscribe" UI without migration
- **Cousin visibility / cross-family streaks** — strict isolation now
- **Email notifications** (Resend/Postmark/etc.) — Realtime + manual triage only
- **LocalStorage → server migration** on first sign-in — manual export/import workaround documented in README
- **Multiple owners per family** (mom + dad both admin) — single `owner_user_id` for now
- **Tutor-as-account-type** with cross-family lesson publishing — punt
- **CAPTCHA / advanced anti-spam** — honeypot + dwell time is enough at this scale

## Impact

- **New**: Supabase project, ~7-table schema, RLS policies, anon-role grants
- **Modified**: `index.html` — auth modal, profile picker, data-layer wrapper that routes reads/writes to Supabase when authed and `localStorage` when guest
- **New UI**: contact form modal in guest footer, admin "Requests" tab with realtime subscription
- **Replaced**: today's localStorage-PIN admin gate becomes "are you the admin user (Rafi)?" check; per-family parents see their own data via RLS
- **Updated**: `README.md` with Supabase setup steps and clone instructions
- **Vercel**: unchanged (still static, no functions); Supabase URL + anon key embedded as `<script>` constants in `index.html`
- **Estimated effort**: ~5–6 hours implementation
