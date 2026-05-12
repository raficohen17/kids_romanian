# families Specification Delta

## ADDED Requirements

### Requirement: Family auto-created on first sign-in

The system SHALL ensure each authenticated user has exactly one family they own. On a user's first successful sign-in (no row in `families` with `owner_user_id = auth.uid()`), the app SHALL INSERT a default family row.

The default family name MAY be derived from the user's email (e.g., the local-part) or set to a generic placeholder; the user MAY rename it from the profile-management UI later.

#### Scenario: First sign-in creates a family

- **WHEN** a user signs in for the first time
- **AND** no row exists in `families` for their `auth.uid()`
- **THEN** the app INSERTs a new `families` row with `owner_user_id = auth.uid()`
- **AND** prompts the user to create their first kid profile

#### Scenario: Subsequent sign-in reuses existing family

- **WHEN** an already-onboarded user signs in
- **AND** a row in `families` with `owner_user_id = auth.uid()` already exists
- **THEN** the app SHALL NOT create a second family
- **AND** loads the existing family's profiles into the picker

### Requirement: Kid profile CRUD

The system SHALL allow the authenticated family owner to create, rename, recolor, set emoji on, and delete profiles within their family. Profiles MUST scope to a single `family_id`.

A family SHALL support at least 1 and at most 10 profiles. Attempting to create an 11th profile SHALL surface a friendly limit message.

#### Scenario: Add a profile

- **WHEN** the family owner clicks "Add profile" and submits name "Maya" with emoji "🦋"
- **THEN** a new row is INSERTed into `profiles` with `family_id` = the owner's family
- **AND** the profile appears in the picker on next render

#### Scenario: Rename a profile

- **WHEN** the family owner edits Maya's profile and changes the name to "Maya Romi"
- **THEN** the `profiles` row is UPDATEd
- **AND** the picker reflects the new name

#### Scenario: Delete a profile

- **WHEN** the family owner deletes Noam's profile
- **AND** confirms the destructive action
- **THEN** the `profiles` row is DELETEd
- **AND** the associated `progress` row is cascade-deleted
- **AND** `vocab` and `sentences` rows that reference Noam via `added_by_profile_id` SHALL have that column set to NULL (not deleted — the family still owns the words)

#### Scenario: Profile limit enforced

- **WHEN** the family owner attempts to create the 11th profile
- **THEN** the UI displays "Family supports up to 10 profiles"
- **AND** no row is INSERTed

### Requirement: Netflix-style profile picker

After sign-in, the system SHALL display all profiles in the user's family as large tiles (emoji + name + optional lock icon). Clicking a tile selects that profile for the session.

The picker SHALL also include an "Add profile" tile that opens the create-profile form.

#### Scenario: Profile picker shows all family profiles

- **WHEN** a signed-in owner has 3 profiles (Maya, Noam, Tata)
- **THEN** the picker shows 3 tiles plus an "Add" tile
- **AND** each tile renders the profile's emoji, name, and PIN lock icon (if `pin IS NOT NULL`)

#### Scenario: Unlocked profile is selected immediately

- **WHEN** the user clicks Noam's tile
- **AND** Noam's `pin` is NULL
- **THEN** the app loads Noam's progress and the family dictionary into state
- **AND** transitions to the main practice UI

### Requirement: Optional per-kid PIN (plain text)

The system SHALL allow the family owner to set an optional 4-digit PIN on any profile. The PIN SHALL be stored as plain text in `profiles.pin`. The PIN SHALL be nullable; profiles without a PIN are openly clickable.

When a PIN-protected profile is selected, the app SHALL prompt for the PIN before loading the profile. Comparison happens client-side against the value read via Supabase (the parent's RLS context allows reading their own family's PINs).

The PIN is explicitly NOT a security control. It is a sibling-friction barrier. The product copy and admin UI SHOULD communicate this so users do not over-trust it.

#### Scenario: Set a PIN on a profile

- **WHEN** the family owner opens "Manage profiles" and sets Maya's PIN to "1234"
- **AND** confirms by re-entering "1234"
- **THEN** `profiles.pin` is UPDATEd to "1234"
- **AND** the picker tile for Maya gains a lock icon

#### Scenario: Correct PIN unlocks profile

- **WHEN** a user clicks Maya's locked tile
- **AND** enters "1234" in the PIN prompt
- **THEN** the prompt closes
- **AND** Maya's profile loads

#### Scenario: Wrong PIN is rejected

- **WHEN** a user enters "0000" in Maya's PIN prompt
- **AND** the stored value is "1234"
- **THEN** the prompt shows "Wrong PIN" feedback
- **AND** the input is cleared and refocused
- **AND** the profile is NOT loaded

#### Scenario: Parent removes PIN from a profile

- **WHEN** the family owner opens "Manage profiles" and clears Maya's PIN
- **THEN** `profiles.pin` is UPDATEd to NULL
- **AND** the lock icon disappears from Maya's tile
- **AND** clicking the tile selects the profile without prompting

### Requirement: Last-selected profile remembered per device

The system SHALL persist the last-selected profile id in `localStorage` so that a returning signed-in user is offered to resume that profile without re-picking.

If the persisted profile id no longer exists (deleted), the system SHALL silently fall back to the picker.

#### Scenario: Resume last profile on reload

- **WHEN** a signed-in user has selected Maya and then reloads the page
- **THEN** the app reads the persisted profile id from `localStorage`
- **AND** loads Maya's profile directly, skipping the picker
- **AND** still shows a "switch profile" action in the header

#### Scenario: Deleted profile resets to picker

- **WHEN** the persisted profile id no longer exists in `profiles`
- **THEN** the app falls back to showing the picker
- **AND** clears the stale `localStorage` value
