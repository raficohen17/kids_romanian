# Design: add-supabase-multifamily-auth

## Context

The app is one HTML file deployed to Vercel as a static site. All state today lives in `localStorage`. We're adding a backend (Supabase) for auth + persistence while keeping the frontend a single static file. No build step, no framework migration, no Vercel Functions.

This is the first multi-tenant version of the app. Most decisions below trade some upside (richer features) against the constraint of staying static + family-scale + zero-ops.

## Architectural Decisions

### Decision 1: `families` table, not `parent_user_id` everywhere

**Choice**: Introduce a `families(id, owner_user_id, name)` table. All tenant-scoped rows (`profiles`, `vocab`, `sentences`) reference `family_id`, not `auth.users.id` directly.

**Why**: Buys forward-compat for:
- Multiple owners per family later (mom + dad both admin) — add a `family_owners(family_id, user_id)` table
- Sharing a family pool to another family — `family_shares(from_id, to_id)` without renaming columns
- Renaming a family without touching auth identity

**Cost**: One extra column on every tenant row, one extra row created on first sign-in. Negligible.

### Decision 2: Family-shared dictionary, per-profile progress

**Choice**: `vocab` and `sentences` scope to `family_id`. `progress` scopes to `profile_id`.

**Why**: The realistic family use case is "the dad adds words once, everyone learns them." Per-kid dictionaries duplicate work. Progress is rightly private — Maya's streak isn't Noam's streak.

**Trade-off**: A sibling can technically delete a word the other was learning. Mitigated by:
- Soft attribution (`added_by_profile_id`) — UI can show "Maya added this"
- Audit trail in `created_at`
- The parent has the override path

### Decision 3: Plain-text per-kid PIN

**Choice**: `profiles.pin` is a nullable plain-text 4-digit string.

**Why**: The threat model is "Noam shouldn't trivially open Maya's tab from the picker," not "Noam needs cryptographic isolation from Maya." The parent's session can read every row in the family anyway via RLS — hashing the PIN doesn't change the actual security boundary, it just adds complexity.

**Honest framing**: PIN protects against accidental sibling clicks and casual griefing. It does not protect against a kid who opens DevTools. For real per-kid security we'd need separate Supabase auth identities per child — heavy and breaks the "kid picks tile and plays" UX. Not worth it.

### Decision 4: Realtime-only notifications for access requests

**Choice**: When a new row is inserted into `access_requests`, Rafi's admin tab (if open) shows a red dot via Supabase Realtime subscription. No email, no Edge Function, no Resend/Postmark.

**Why**: Avoids running any email service or Edge Function. Trade-off accepted: if Rafi doesn't open the app for a week, requests sit pending. For invite-only at family scale, that's fine.

**Future**: Email notifications are a small follow-on if request volume grows — add a Postgres trigger → Edge Function → Resend. Schema doesn't change.

### Decision 5: Pure-ephemeral guest mode (no Supabase calls)

**Choice**: Unauthenticated visitors never touch Supabase. The app loads the built-in corpus from code, stores score/streak in `localStorage`, and disables save/add buttons. The Supabase JS SDK is loaded but not invoked until sign-in.

**Why**:
- Simplest possible guest experience — no anonymous-session bookkeeping, no DB rows for tire-kickers
- Zero privacy footprint for guests
- Cleanly separates "tier you pay for" (server-stored, multi-device) from "tier you don't" (browser-local, ephemeral)

**Cost**: A guest who plays for two weeks then signs up loses their progress. Acceptable — this isn't a growth-optimized SaaS.

### Decision 6: `pack_id` columns reserved but unused

**Choice**: `vocab.pack_id` and `sentences.pack_id` are nullable columns from day 1. Default is NULL, meaning "belongs to the family pool." A future `packs` table can later make rows shareable across families by setting `pack_id` to a row in `packs`.

**Why**: Costs nothing now. Saves a migration if pack-sharing is ever added. The column is invisible in the UI today; RLS simply checks `family_id` and ignores `pack_id`.

**Out-of-scope confirmation**: We are not building pack sharing in this change. The proposal explicitly lists it as future.

### Decision 7: Single admin via hardcoded user metadata flag

**Choice**: Rafi (raficohen17@gmail.com) is the sole admin. RLS policies that need "admin access" (e.g. SELECT on `access_requests`, INSERT on `allowed_emails`) check `auth.jwt() ->> 'role' = 'admin'`, which is set via Supabase user metadata on his user row.

**Alternatives considered**:
- Hardcode UID in RLS — works but UID only known after first sign-in, makes the SQL setup feel chicken-and-egg
- `admins` table — overkill for a single admin
- Service role from a client — never, that's the key that bypasses RLS

**Why metadata**: Single source of truth, can be toggled from Supabase dashboard, no extra table.

### Decision 8: Invite gating via `allowed_emails` table + Auth Hook

**Choice**: `allowed_emails(email)` is a server-only table. A Supabase "before signup" Auth Hook (Postgres function) checks the incoming email against `allowed_emails` and rejects sign-ups for unlisted emails.

**Why**: Supabase's built-in "disable signups" is too coarse (it would block Rafi too). Auth Hook is the documented pattern for whitelist-based access.

**Admin flow**: Rafi sees an `access_requests` row, clicks "Approve" in admin UI → admin UI INSERTs the email into `allowed_emails`. The requester is then free to sign in (magic link).

### Decision 9: Skip localStorage migration

**Choice**: When the dad first signs in, his existing localStorage vocabulary does NOT auto-migrate to the family pool. He must manually `Export → sign in → Import` (both already exist in the user tab).

**Why**: One-shot migration logic is brittle (especially with two states of truth). The export/import flow already works, so the manual workaround is one extra click. Documented in README.

## Data Model

```
auth.users  (Supabase managed)
  id, email, raw_user_meta_data ({ "role": "admin" } for Rafi only)

allowed_emails
  email          TEXT PRIMARY KEY
  added_at       TIMESTAMPTZ DEFAULT now()
  added_by       UUID FK auth.users.id

families
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid()
  owner_user_id  UUID NOT NULL FK auth.users.id
  name           TEXT
  created_at     TIMESTAMPTZ DEFAULT now()

profiles
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid()
  family_id      UUID NOT NULL FK families.id ON DELETE CASCADE
  name           TEXT NOT NULL
  emoji          TEXT DEFAULT '🌟'
  color          TEXT DEFAULT '#ba68c8'
  pin            TEXT NULL                          -- 4 digits, plain text, nullable
  created_at     TIMESTAMPTZ DEFAULT now()

vocab
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid()
  family_id            UUID NOT NULL FK families.id ON DELETE CASCADE
  he                   TEXT NOT NULL
  ro                   TEXT NOT NULL
  pron                 TEXT
  cat                  TEXT
  emoji                TEXT DEFAULT '✨'
  note                 TEXT
  added_by_profile_id  UUID NULL FK profiles.id ON DELETE SET NULL
  pack_id              UUID NULL                    -- reserved for future
  created_at           TIMESTAMPTZ DEFAULT now()

sentences
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid()
  family_id            UUID NOT NULL FK families.id ON DELETE CASCADE
  he                   TEXT NOT NULL
  ro                   TEXT NOT NULL
  pron                 TEXT
  emoji                TEXT DEFAULT '💬'
  theme                TEXT
  words                JSONB                        -- [{ro, he, pron}, ...]
  added_by_profile_id  UUID NULL FK profiles.id ON DELETE SET NULL
  pack_id              UUID NULL                    -- reserved for future
  created_at           TIMESTAMPTZ DEFAULT now()

progress
  profile_id     UUID PRIMARY KEY FK profiles.id ON DELETE CASCADE
  score          INT DEFAULT 0
  best_streak    INT DEFAULT 0
  seen           INT DEFAULT 0
  updated_at     TIMESTAMPTZ DEFAULT now()

access_requests
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid()
  email          TEXT NOT NULL
  name           TEXT
  message        TEXT
  status         TEXT NOT NULL DEFAULT 'pending'     -- pending|approved|rejected
  created_at     TIMESTAMPTZ DEFAULT now()
  reviewed_at    TIMESTAMPTZ
  notes          TEXT
```

## RLS Policies (summary)

| Table | anon | authenticated | admin (Rafi) |
|---|---|---|---|
| `allowed_emails` | none | none | full |
| `families` | none | SELECT/UPDATE where `owner_user_id = auth.uid()` | full |
| `profiles` | none | full where joined family's `owner_user_id = auth.uid()` | full |
| `vocab`, `sentences` | none | full where joined family's `owner_user_id = auth.uid()` | full |
| `progress` | none | full where joined profile's family's `owner_user_id = auth.uid()` | full |
| `access_requests` | INSERT only | none | SELECT/UPDATE full |

Anon role gets exactly one privilege: `INSERT INTO access_requests`. Everything else returns empty or errors. Guest mode therefore never sees other families' data, by construction.

## Auth Flow

```
[Visitor opens URL]
        │
        ▼
[Supabase getSession() returns null]
        │
        ▼
[Guest mode: built-in corpus, localStorage score]
        │
   [Sign in CTA]
        │
        ▼
[Email input → supabase.auth.signInWithOtp({ email })]
        │
        ▼
[Magic link email sent]
        │
[Click link → /auth/callback handled by SDK]
        │
        ▼
[Auth hook checks allowed_emails: pass or reject]
        │
        ▼
[Session established, getSession() returns user]
        │
        ▼
[Does this user have a family?]
   ─ No  → INSERT INTO families (owner_user_id = uid)
           → show "Add first kid profile" wizard
   ─ Yes → fetch profiles → show profile picker
        │
        ▼
[Pick profile]
        │
   [Profile has PIN?]
   ─ No  → load profile's progress + family dictionary → app
   ─ Yes → PIN prompt → on match → load → app
```

## Trade-offs / Risks

| Risk | Mitigation |
|---|---|
| Anon key in HTML | Public by design; RLS is the actual security boundary. Rotate via Supabase dashboard if needed. |
| Supabase project pauses after 7 days idle | First request wakes it in <1s; acceptable for personal app. |
| Guest spams `access_requests` | Honeypot + dwell time + rate limit by IP in an Auth Hook function. Manual triage absorbs anything that gets through. |
| Sibling deletes shared family vocab | `added_by_profile_id` + `created_at` audit trail; parent restores manually if needed. |
| Sibling guesses 4-digit PIN | Acceptable threat — PIN is sibling-friction, not security. See Decision 3. |
| Rafi forgets to check admin tab | Realtime + future email notification path (out of scope here). |
| Migration of existing localStorage | Manual export/import; documented. See Decision 9. |

## Implementation Sequencing

The change has natural dependency layers; later layers assume earlier ones:

1. **Supabase setup** — project, schema, RLS, allowed_emails for Rafi
2. **Auth layer** — sign-in, sign-out, session detection, guest-vs-authed routing
3. **Family + profile** — auto-create family on first sign-in, profile CRUD, picker
4. **Data layer wrapper** — single set of read/write helpers that route to Supabase when authed and localStorage otherwise
5. **Family dictionary** — replace localStorage vocab/sentences reads/writes; verify all five practice modes still work
6. **PIN gating** — optional per-profile lock UI
7. **Access requests** — guest contact form, admin Requests tab with Realtime
8. **Polish** — sign-out menu, error states, README updates

Layers 5 + 6 + 7 can be done in any order once layers 1–4 are in place.
