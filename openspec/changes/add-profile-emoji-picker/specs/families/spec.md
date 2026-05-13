# families Specification Delta

## ADDED Requirements

### Requirement: Curated emoji set for profile avatars

The system SHALL define a constant `PROFILE_EMOJIS` containing exactly 20 emoji strings suitable for kid profile avatars. The set MUST be:

- gender-neutral (no gendered figures like 🤴 / 👸)
- culturally neutral (no flags, food specific to one cuisine, etc.)
- kid-friendly (no weapons, alcohol, currency, gestures)
- a mix of animals, nature, and sparkly/celebratory symbols

Recommended set (subject to fine-tuning):

```
🌟 ⭐ 🌈 ✨ 🌸 🌻 🍀 🦋
🐱 🐶 🦊 🐰 🐻 🐼 🦁 🐯
🐸 🦄 🐙 🦉
```

#### Scenario: Constant has 20 entries

- **WHEN** the JS module loads
- **THEN** `PROFILE_EMOJIS.length` equals 20

#### Scenario: All entries are renderable

- **WHEN** each emoji is rendered into a button tile
- **THEN** no entry produces a blank or "tofu" character on a current browser

### Requirement: Emoji picker modal

The system SHALL render an emoji-picker modal when the parent triggers "add profile" or "change emoji" on an existing profile. The picker SHALL display the 20 `PROFILE_EMOJIS` as a grid of tiles (recommended 5 columns × 4 rows). Each tile is large enough for finger-tap (minimum 56×56 CSS pixels).

The picker SHALL:

- highlight the currently-selected emoji (if any) when opened from "change emoji"
- commit the selection immediately on tap (no separate "OK" button)
- close on tap-to-select or on tap of an explicit "ביטול" button (cancel)
- be dismissible by tapping outside the modal area

#### Scenario: Picker opens with current emoji highlighted

- **WHEN** the parent opens "change emoji" for Maya whose current emoji is 🦋
- **THEN** the 🦋 tile in the picker has a visible "selected" style
- **AND** other tiles are unselected

#### Scenario: Tap commits and closes

- **WHEN** the parent taps the 🦊 tile
- **THEN** the modal closes
- **AND** the profile's emoji is updated to 🦊
- **AND** the change is persisted via Supabase update (if authed) or in-memory (if guest test environment)

#### Scenario: Cancel leaves emoji unchanged

- **WHEN** the parent taps "ביטול" in the picker
- **THEN** the modal closes
- **AND** the profile's emoji is unchanged

#### Scenario: Outside-tap dismisses without change

- **WHEN** the picker is open
- **AND** the parent taps the dark overlay outside the modal card
- **THEN** the modal closes
- **AND** no update is sent

### Requirement: Picker used in profile creation flow

When the parent triggers "Add profile", the flow SHALL prompt for the name first (text input), then open the emoji picker for the avatar choice. The chosen emoji becomes the new profile's `emoji` value.

If the parent cancels the emoji picker after entering a name, the system SHALL default the emoji to `'🌟'` and proceed with profile creation.

#### Scenario: Create profile with name + emoji

- **WHEN** the parent enters name "Maya" and selects 🦋 from the picker
- **THEN** the new `profiles` row has `name = 'Maya'` and `emoji = '🦋'`

#### Scenario: Cancel emoji defaults to 🌟

- **WHEN** the parent enters name "Maya" and cancels the emoji picker
- **THEN** the new `profiles` row has `name = 'Maya'` and `emoji = '🌟'`

### Requirement: Picker used in manage-profiles flow

The manage-profiles flow SHALL replace its previous "change emoji" `prompt()` with the same picker. Selecting an emoji updates the existing profile's `emoji` and persists immediately.

#### Scenario: Change emoji from manage flow

- **WHEN** the parent opens "Manage profiles" and selects Maya
- **AND** chooses "change emoji"
- **AND** the picker opens with 🦋 highlighted
- **AND** the parent taps 🦊
- **THEN** Maya's `emoji` is updated to 🦊 in `profiles`
- **AND** the picker closes
- **AND** the profile tile re-renders with the new emoji

## MODIFIED Requirements

### Requirement: Kid profile CRUD (emoji entry via picker)

The "Add profile" flow SHALL accept a name through a text input and an emoji through the curated emoji-picker modal. The flow MUST NOT use a `prompt()` dialog for emoji entry.

Setting `color` and `pin` SHALL remain in the manage-profiles flow as before.

(Originally in the `families` capability of `add-supabase-multifamily-auth`.)

#### Scenario: Add profile via name input + picker

- **WHEN** the parent clicks "Add profile"
- **THEN** they are first prompted for a name (text input)
- **AND** then shown the emoji picker
- **AND** a new `profiles` row is INSERTed with the supplied values

#### Scenario: Picker is the only emoji-entry path

- **WHEN** the parent uses any flow that sets `profiles.emoji`
- **THEN** the picker UI is used
- **AND** no free-text emoji prompt appears
