# family-dictionary Specification Delta

## ADDED Requirements

### Requirement: Vocab and sentences scoped to family

The system SHALL store user-added vocab and user-added sentences in `vocab` and `sentences` tables, each row scoped to a single `family_id`. RLS SHALL enforce that a user can only SELECT/INSERT/UPDATE/DELETE rows whose `family_id` joins to a `families` row where `owner_user_id = auth.uid()`.

All kid profiles within a family SHALL see the same dictionary — there is no per-profile vocab scoping.

#### Scenario: Parent adds a word visible to all profiles

- **WHEN** the parent signs in, selects Maya's profile, and adds the word "Pisică" / "חתול"
- **AND** then switches to Noam's profile
- **THEN** "Pisică" / "חתול" appears in Noam's vocab list
- **AND** in any of his practice modes

#### Scenario: RLS blocks cross-family read

- **WHEN** Family A has signed in and queries `SELECT * FROM vocab`
- **AND** Family B has rows in `vocab` from their own family
- **THEN** Family A's query returns ONLY rows where `family_id` matches Family A's family
- **AND** Family B's rows are absent

#### Scenario: Anon role cannot read vocab

- **WHEN** an unauthenticated client (anon role) attempts to SELECT from `vocab`
- **THEN** RLS returns zero rows
- **AND** no error message reveals the existence of data

### Requirement: Soft attribution for added words

The system SHALL record `added_by_profile_id` on every newly-inserted `vocab` or `sentences` row, set to the currently-selected profile at the time of the add. This column SHALL be nullable to permit profile deletion without losing the word.

The UI MAY display attribution (e.g., "Added by Maya") but SHALL NOT use it for access control.

#### Scenario: Adding a word records attribution

- **WHEN** Maya's profile is active and the parent adds "Banană"
- **THEN** the inserted row has `added_by_profile_id` equal to Maya's id
- **AND** the row is still scoped to the family (`family_id` set)

#### Scenario: Deleting a profile preserves the words it added

- **WHEN** Maya's profile is deleted
- **THEN** vocab rows with `added_by_profile_id = Maya's id` are NOT deleted
- **AND** their `added_by_profile_id` is set to NULL via ON DELETE SET NULL
- **AND** they remain visible to the rest of the family

### Requirement: pack_id column reserved, defaulted to NULL

Both `vocab` and `sentences` tables SHALL include a `pack_id UUID NULL` column from the initial schema. The application SHALL NOT use this column in any read or write path in this change — its sole purpose is to keep a future pack-sharing change migration-free.

RLS policies SHALL continue to scope by `family_id` regardless of `pack_id`.

#### Scenario: All rows in this release have pack_id = NULL

- **WHEN** the schema is created and the app is in production
- **THEN** every row in `vocab` and `sentences` has `pack_id` = NULL
- **AND** no UI in this release reads or writes `pack_id`

#### Scenario: Future pack-sharing change does not need a migration

- **WHEN** a later change introduces a `packs` table and a "subscribe to pack" UI
- **THEN** existing `vocab.pack_id` and `sentences.pack_id` columns are already in place
- **AND** that future change can SET pack_id without an ALTER TABLE

### Requirement: Per-profile progress

The system SHALL store score, best streak, and total-seen counts in a `progress` table keyed by `profile_id`. Each kid SHALL have their own progress independent of siblings.

Progress writes SHOULD be debounced (e.g., on streak break, on session end) rather than on every correct answer, to limit DB write volume.

#### Scenario: Two siblings have independent scores

- **WHEN** Maya answers correctly 10 times and Noam answers correctly 5 times
- **THEN** Maya's progress row shows `score = 100` (10 × 10 points)
- **AND** Noam's progress row shows `score = 50`
- **AND** switching profiles loads the right row

#### Scenario: Progress survives sign-out and sign-in

- **WHEN** Maya has score 250, signs out, then the parent signs back in and selects Maya
- **THEN** Maya's score is still 250
- **AND** the `progress` row was preserved server-side

### Requirement: Bulk import targets the family pool

The existing bulk-import flow (Markdown table / JSON file in the user/admin tab) SHALL, when used by an authenticated parent, INSERT parsed rows into `vocab` / `sentences` scoped to the family. The preview-and-merge UX MUST remain unchanged.

When invoked in guest mode, bulk import SHALL be disabled or hidden.

#### Scenario: Authed bulk import writes to family pool

- **WHEN** the parent pastes a Markdown table of 8 words and clicks "Add to my dictionary"
- **THEN** 8 rows are INSERTed into `vocab` with the family's `family_id`
- **AND** all profiles in the family see them on next practice load

#### Scenario: Guest cannot bulk import

- **WHEN** an unauthenticated visitor opens the user/admin tab
- **THEN** the bulk-import section is either hidden or shows a "Sign in to add words" message
- **AND** no client-side state mutates if they try

### Requirement: Data-layer wrapper routes by auth state

The application SHALL provide a single wrapper module for vocab/sentence/progress reads and writes that:

- When `supabase.auth.getSession()` returns a session, uses Supabase queries scoped by RLS
- When no session, uses `localStorage` (guest mode)
- Returns the same in-memory shape to the rest of the app, so the practice-mode UI does not branch on auth state

#### Scenario: Guest path uses localStorage only

- **WHEN** an unauthenticated visitor opens the app
- **AND** practice modes call `getVocab()` and `getSentences()` via the wrapper
- **THEN** no Supabase HTTP requests fire
- **AND** the wrapper returns the built-in corpus only (no user-added rows in guest mode)

#### Scenario: Authed path uses Supabase

- **WHEN** a signed-in parent's session is active
- **AND** the wrapper is called for vocab
- **THEN** a single Supabase `select()` returns the family's user-added rows
- **AND** the wrapper concatenates them with the built-in corpus in the same shape as before
