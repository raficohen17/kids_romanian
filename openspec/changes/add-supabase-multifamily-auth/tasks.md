# Tasks: add-supabase-multifamily-auth

Ordered phases. Phases 1–4 are sequential; 5, 6, 7 can be done in any order once the foundation is in place.

## Phase 1 — Supabase project + schema

- [ ] 1.1 Create new Supabase project (free tier), record `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- [ ] 1.2 In SQL editor, create tables: `allowed_emails`, `families`, `profiles`, `vocab`, `sentences`, `progress`, `access_requests` (per `design.md`)
- [ ] 1.3 Enable Row-Level Security on all tables
- [ ] 1.4 Create RLS policies per `design.md` summary (anon: only INSERT on `access_requests`; authed: own family; admin: full on `allowed_emails` and `access_requests`)
- [ ] 1.5 Configure Supabase Auth: email provider on, open sign-up off, magic-link template customized for Hebrew RTL
- [ ] 1.6 Add Postgres function + Auth Hook: reject sign-up if email not in `allowed_emails`
- [ ] 1.7 Manually INSERT Rafi's email into `allowed_emails`; sign in once via Supabase dashboard to provision his `auth.users` row
- [ ] 1.8 Set Rafi's `raw_user_meta_data` to `{"role": "admin"}` via SQL
- [ ] 1.9 Verify: sign in with Rafi's email = success; sign in with random email = rejected

**Validation**: Manual smoke test via Supabase dashboard "Authentication" + "SQL editor". Document the project URL + anon key in a `.env.example` (committed) and `.env.local` (gitignored). No code changes yet.

## Phase 2 — Auth layer in index.html

- [ ] 2.1 Add Supabase JS SDK via ESM CDN: `<script type="module">import { createClient } from "https://esm.sh/@supabase/supabase-js@2";</script>`
- [ ] 2.2 Hardcode (or inject from build-less `<meta>` tags) `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `index.html`
- [ ] 2.3 On page load, call `supabase.auth.getSession()`; route to guest mode or authed flow accordingly
- [ ] 2.4 Build sign-in modal: email input → `signInWithOtp({ email })` → "check your email" confirmation
- [ ] 2.5 Handle magic-link callback: SDK does this automatically when URL hash contains `access_token`; verify session is established
- [ ] 2.6 Build sign-out menu entry: `supabase.auth.signOut()` → drop to guest mode
- [ ] 2.7 Listen to `supabase.auth.onAuthStateChange` to re-render when session changes

**Validation**: Manual browser test on both authed and unauthed paths. Verify with Network tab that guest mode does NOT trigger Supabase requests until sign-in.

## Phase 3 — Family + profile bootstrapping

- [ ] 3.1 On first auth state change with a session, query `SELECT * FROM families WHERE owner_user_id = auth.uid()`
- [ ] 3.2 If no family exists, INSERT one with a default name derived from email; redirect to "Add first profile" wizard
- [ ] 3.3 If family exists, query `SELECT * FROM profiles WHERE family_id = ?`
- [ ] 3.4 Render profile picker UI (tiles with emoji, name, optional lock icon)
- [ ] 3.5 Implement "Add profile" form (name, emoji, optional color)
- [ ] 3.6 Implement "Manage profiles" view: rename, set/clear PIN, delete (with confirm), set color/emoji
- [ ] 3.7 Implement profile-pick flow: click tile → if PIN-locked, prompt for PIN → load profile state into JS
- [ ] 3.8 Persist last-selected profile id to `localStorage`; restore on reload
- [ ] 3.9 Header shows current profile + "Switch profile" + "Sign out"
- [ ] 3.10 Enforce max-10-profiles-per-family in UI

**Validation**: Create 3 profiles, set PIN on one, verify all flows. Open DevTools and confirm RLS prevents inserting a profile with another family's id.

## Phase 4 — Data layer wrapper

- [ ] 4.1 Refactor existing vocab/sentence/progress read sites in `index.html` to go through a single wrapper module (`storage.js` or an inline IIFE)
- [ ] 4.2 Wrapper: if session and profile selected → Supabase; else → localStorage (guest)
- [ ] 4.3 In-memory state shape stays identical to today's so practice-mode UI is untouched
- [ ] 4.4 Initial load: fetch family's vocab + sentences + the active profile's progress; concatenate with built-in corpus
- [ ] 4.5 Writes: route to Supabase with proper `family_id` and `added_by_profile_id`
- [ ] 4.6 Practice answers update progress; debounce writes (e.g., every 5 correct answers or on streak break)

**Validation**: All 5 practice modes work for both guest and authed user. Score on Maya, switch to Noam, verify their scores are independent. Sign out and reload — guest progress isolated from family progress.

## Phase 5 — Per-kid PIN gating

(Mostly done in Phase 3 — break-out tasks for completeness)

- [ ] 5.1 PIN prompt modal: 4-digit input, OK/Cancel, focus-on-open, Enter submits
- [ ] 5.2 Wrong-PIN feedback: shake animation, clear input, refocus
- [ ] 5.3 Lock icon on picker tiles for PIN-protected profiles
- [ ] 5.4 Manage-profiles UI for setting/changing/clearing PIN (with current-PIN confirmation if changing)

**Validation**: Manually test all PIN states (none, set, locked, unlock, wrong).

## Phase 6 — Access requests

- [ ] 6.1 Add contact form modal (name, email, message, hidden honeypot, dwell timer)
- [ ] 6.2 Footer link in guest mode opens the modal
- [ ] 6.3 Submit handler: validate, INSERT into `access_requests`, show "Thanks" state
- [ ] 6.4 Build admin "Requests" tab (visible only when `auth.jwt() ->> 'role' = 'admin'`)
- [ ] 6.5 List pending/approved/rejected requests with timestamps
- [ ] 6.6 "Approve" button: `INSERT INTO allowed_emails ... ON CONFLICT DO NOTHING` + UPDATE status
- [ ] 6.7 "Reject" button: UPDATE status only
- [ ] 6.8 Subscribe to Supabase Realtime on `access_requests` INSERT; show red dot on admin tab when new rows arrive

**Validation**: From an incognito window, submit the contact form; in the primary window (signed in as Rafi), confirm realtime dot appears and the request shows up. Approve → from the original incognito → sign-in with that email succeeds.

## Phase 7 — Polish, docs, deploy

- [ ] 7.1 Update README with: Supabase setup steps, env variables, sign-in flow, manual approval flow, "this PIN is not security" caveat
- [ ] 7.2 Update `AGENTS.md` / `CLAUDE.md` in the repo with Supabase auth conventions (test fakes if any, security model)
- [ ] 7.3 Loading states + error toasts for Supabase calls
- [ ] 7.4 Empty states: new family with no profiles, profile with no progress
- [ ] 7.5 Smoke test on iPad + laptop (different sessions)
- [ ] 7.6 Verify Vercel deploy still works after the change (no build step regressions)
- [ ] 7.7 Manual export from current localStorage; sign in; manual import (documents the migration path)
- [ ] 7.8 Run `openspec validate add-supabase-multifamily-auth --strict` before archiving the change

## Dependencies and parallelism

```
Phase 1  ──►  Phase 2  ──►  Phase 3  ──►  Phase 4
                                              │
                                              ▼
                       ┌──────────────────────┼──────────────────────┐
                       ▼                      ▼                      ▼
                    Phase 5               Phase 6                Phase 7
                  (PIN polish)        (Access requests)       (Polish/docs)
```

Phases 5, 6, 7 can run in parallel after Phase 4 lands.
