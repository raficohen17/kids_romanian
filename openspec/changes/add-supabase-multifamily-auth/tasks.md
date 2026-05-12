# Tasks: add-supabase-multifamily-auth

Legend: `[x]` complete · `[ ]` not started · `[~]` partial (artifact ready, user action pending) · 🧑 **user action required** (cannot be automated — depends on Supabase dashboard or live env).

## Phase 1 — Supabase project + schema

- [ ] 1.1 🧑 Create new Supabase project (free tier), record `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- [x] 1.2 SQL in `supabase/schema.sql`: tables `allowed_emails`, `families`, `profiles`, `vocab`, `sentences`, `progress`, `access_requests`
- [x] 1.3 RLS enabled on all tables (in `supabase/schema.sql`)
- [x] 1.4 RLS policies (anon-INSERT on `access_requests`; family-owner scope; `is_admin()` helper for `allowed_emails`/`access_requests`)
- [ ] 1.5 🧑 Email provider on, open sign-up off, Site URL pointing to your Vercel domain
- [~] 1.6 `check_allowed_email(jsonb)` function shipped in `supabase/schema.sql`; 🧑 wire it as a "Before User Created" Auth Hook in the dashboard
- [ ] 1.7 🧑 INSERT your email into `allowed_emails`; sign in once to provision `auth.users`
- [ ] 1.8 🧑 SQL `update auth.users set raw_user_meta_data = jsonb_set(...,'{role}','"admin"')`
- [ ] 1.9 🧑 Smoke-test: allowed email signs in OK, non-allowed gets the 403 from the hook

Full step-by-step in [`SETUP.md`](../../../SETUP.md).

## Phase 2 — Auth layer in index.html

- [x] 2.1 Supabase JS SDK loaded via ESM CDN inside a `<script type="module">` in `<head>`
- [x] 2.2 `config.js` (gitignored) supplies `window.APP_CONFIG = { SUPABASE_URL, SUPABASE_ANON_KEY }`; template in `config.example.js`
- [x] 2.3 `initAuth()` calls `supabase.auth.getSession()` on load; routes to guest or authed flow
- [x] 2.4 Sign-in modal: email field → `signInWithOtp({ email })` → "check your email" card
- [x] 2.5 Magic-link callback handled by Supabase SDK (`detectSessionInUrl: true`)
- [x] 2.6 Sign-out button in auth bar; clears local session and reverts to guest
- [x] 2.7 `onAuthStateChange` listener re-renders auth bar + overlay on SIGNED_IN / SIGNED_OUT

## Phase 3 — Family + profile bootstrapping

- [x] 3.1 `ensureFamily()` queries `families` where `owner_user_id = auth.uid()`
- [x] 3.2 If none, INSERTs default family (name derived from email local-part)
- [x] 3.3 `loadProfiles()` fetches all profiles for the family
- [x] 3.4 `renderPickerCard()` renders Netflix-style tiles with emoji + lock icon
- [x] 3.5 `createProfileFlow()` adds a profile via prompt-based flow
- [x] 3.6 `manageProfilesFlow()` covers rename / change emoji / set/clear PIN / delete
- [x] 3.7 Click tile → if PIN, prompt; else `selectProfile()`
- [x] 3.8 Persist last-selected profile id; auto-resume on reload (unless PIN-locked)
- [x] 3.9 `renderAuthBar()` shows current profile + Switch + Sign out
- [x] 3.10 `createProfileFlow()` enforces 10-profile cap

## Phase 4 — Data layer wrapper

- [x] 4.1 `saveUserVocab()` / `saveUserSentences()` route via `isAuthed()` to either `localStorage` or `syncVocabFull()` / `syncSentencesFull()`
- [x] 4.2 Reads happen via `loadFamilyData()` after `selectProfile()`; populate `userVocab` / `userSentences` / `state.score` etc.
- [x] 4.3 In-memory shape unchanged; existing practice-mode renderers untouched
- [x] 4.4 Initial load fetches family vocab + sentences + profile progress
- [x] 4.5 Writes carry `family_id` and `added_by_profile_id`; nulls allowed
- [x] 4.6 `updateStats()` triggers `saveProgressDebounced()` (1.5s debounce)

## Phase 5 — Per-kid PIN gating

- [x] 5.1 PIN prompt modal with 4-digit input, Enter-to-submit, focus-on-open (`renderPinCard()`)
- [x] 5.2 Wrong-PIN feedback: red text + clear + refocus (no full shake animation; acceptable)
- [x] 5.3 Lock icon on picker tiles when `pin IS NOT NULL`
- [x] 5.4 Manage-profiles flow covers set / change / clear PIN (with confirm dialogs)

## Phase 6 — Access requests

- [x] 6.1 Contact-form modal with name / email / message + hidden `honeypot` field + 3-second dwell-time check
- [x] 6.2 Footer link `#contact-link` opens the modal in guest or authed mode
- [x] 6.3 Submit INSERTs into `access_requests` (RLS allows anon INSERT)
- [x] 6.4 Admin "Requests" tab dynamically added to `.modes` when `auth.isAdmin`
- [x] 6.5 List renders newest-first with status badges
- [x] 6.6 Approve: upserts `allowed_emails` + updates request status
- [x] 6.7 Reject: updates request status only
- [x] 6.8 Realtime subscription on `access_requests` INSERTs shows red dot + counter on tab

## Phase 7 — Polish, docs, deploy

- [x] 7.1 README links to `SETUP.md`; SETUP covers all 9 manual steps + troubleshooting
- [ ] 7.2 🧑 No `AGENTS.md` / `CLAUDE.md` in this repo yet (work repo only); add if/when conventions stabilize
- [~] 7.3 Loading states: minimal (`prompt` / `alert` for now); proper toasts deferred — works but could be prettier
- [x] 7.4 Empty states: "no profiles → add your first one" handled in picker
- [ ] 7.5 🧑 Smoke test on iPad + laptop after `config.js` is filled in
- [ ] 7.6 🧑 Verify Vercel deploy works post-change (should — no build step regressions)
- [x] 7.7 Migration documented: SETUP.md lists Export → sign in → Import workaround
- [x] 7.8 `openspec validate add-supabase-multifamily-auth --strict` — passes before archive

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

## Remaining work (only the 🧑 user-action items)

The code side is complete. To go live:

1. Run the Supabase setup in `SETUP.md` (1.1, 1.5–1.9)
2. Copy `config.example.js` → `config.js`, paste your URL + anon key
3. Smoke-test in browser; verify guest mode untouched, authed mode loads picker

Re-archiving plan: once steps 1–3 above are verified live, mark the 🧑 items and run `openspec archive add-supabase-multifamily-auth`.
