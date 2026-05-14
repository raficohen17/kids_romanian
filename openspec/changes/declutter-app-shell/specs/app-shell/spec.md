# app-shell Specification Delta

## ADDED Requirements

### Requirement: Modes bar shows practice modes as icon-only tabs

The modes bar SHALL show exactly the practice modes as primary tabs:

- 🎴 Flashcards
- 🎯 Quiz
- 🔊 Listen
- 🧩 Match
- 🗣️ Sentences
- 📕 Stories
- 💬 Chat (only when authenticated AND a profile is selected)

Each tab SHALL display only the emoji as its visible label. Each tab SHALL carry an `aria-label` and `title` with the Hebrew name so accessibility tools and hover tooltips remain functional.

Practice tabs SHALL be at least 48×48px to remain comfortable touch targets for a 9-year-old.

#### Scenario: Practice tab is icon-only

- **WHEN** the page renders for a signed-in profile
- **THEN** the `.modes` element contains exactly 7 practice tabs
- **AND** each tab's visible text is exactly its emoji (no Hebrew word inside the button)
- **AND** each tab has an `aria-label` such as "כרטיסיות" or "סיפורים"

#### Scenario: Chat tab is still auth-gated

- **WHEN** the user is not signed in OR no profile is selected
- **THEN** the `💬` chat tab is NOT visible in the bar

### Requirement: Secondary modes live behind a ⋯ menu

A `⋯` trigger button at the end of the modes bar SHALL open a popover containing the secondary modes in this order:

- 📚 יחידות
- 📖 הגייה
- 📝 הוסיפי
- 👤 שלי
- 📥 בקשות (only when `auth.isAdmin`)

Each row SHALL include both its emoji and Hebrew label. Selecting a row SHALL activate that mode (same effect as the old direct tab) and close the popover.

#### Scenario: Secondary modes are not in the main bar

- **WHEN** the modes bar renders
- **THEN** no button with `data-mode` equal to `units`, `guide`, `manage`, `user`, or `requests` is a direct child of `.modes`

#### Scenario: Tapping ⋯ opens the menu

- **WHEN** the user taps the ⋯ button
- **THEN** a `.shell-popover` becomes visible
- **AND** it lists 📚 יחידות, 📖 הגייה, 📝 הוסיפי, 👤 שלי

#### Scenario: Admin sees requests inside ⋯

- **WHEN** `auth.isAdmin` is true
- **AND** the ⋯ popover opens
- **THEN** the list also contains a 📥 בקשות row
- **AND** the existing pending-requests notification dot is rendered on the ⋯ button itself

#### Scenario: Selecting a row activates and closes

- **WHEN** the user taps "📝 הוסיפי" in the popover
- **THEN** `state.mode` becomes `manage`
- **AND** the popover closes
- **AND** the main content area re-renders the Manage view

### Requirement: Active practice mode has accent indication

The currently active practice tab SHALL be visually distinguishable by an accent fill (rounded background in the system accent color). Modes SHALL NOT each carry their own brand color in this bar — only the active tab is filled, the others are neutral.

#### Scenario: Switching modes moves the accent

- **GIVEN** Flashcards is active
- **WHEN** the user taps the Quiz tab
- **THEN** the Flashcards tab loses the accent fill
- **AND** the Quiz tab gains it
- **AND** `state.mode` becomes `quiz`

### Requirement: Auth bar collapses into a single profile chip

For signed-in users, the auth bar SHALL render a single `.profile-chip` element. The chip's visible content SHALL be in the form:

```
<emoji> <name> · <flag> · יחידה <n>
```

The previous separate `.lang-pill`, `.speed-pill`, and `.unit-pill` elements SHALL no longer be rendered as siblings of the chip.

For guests (no Supabase session OR no profile selected), the auth bar SHALL render only a `🔓 כניסה` button.

#### Scenario: Chip shows current identity and context

- **GIVEN** the active profile is Maya with emoji 🌟
- **AND** the active language is Romanian
- **AND** the active unit is 3
- **WHEN** the auth bar renders
- **THEN** the chip's text content includes "🌟", "Maya", "🇷🇴" or the Hebrew name "רומנית", and "יחידה 3"

#### Scenario: Guest sees only sign-in button

- **WHEN** no session is active
- **THEN** the auth bar contains exactly one button labelled "🔓 כניסה"
- **AND** there is no chip

### Requirement: Tapping the profile chip opens a settings popover

Tapping the chip SHALL open a `.shell-popover` containing, in order:

1. A language toggle (🇷🇴 / 🇬🇧 as two buttons; the active flag has the accent fill).
2. A speech-speed selector with four buttons: `×1`, `×0.9`, `×0.75`, `×0.5` (active value highlighted).
3. A "→ 📚 יחידות" deep-link row that sets `state.mode = 'units'` and closes the popover.
4. A "🔄 החלפת פרופיל" row that triggers the existing profile-picker overlay.
5. A "🚪 יציאה" row that calls `signOut()`.

#### Scenario: Language toggle inside popover

- **WHEN** the popover is open
- **AND** the user taps the 🇬🇧 button
- **THEN** `switchLanguage('en')` is called
- **AND** the active fill moves to the 🇬🇧 button
- **AND** the popover stays open

#### Scenario: Speed selection persists

- **WHEN** the user taps `×0.75` in the popover
- **THEN** `state.speechRate` becomes `0.75`
- **AND** `localStorage.getItem('ro-kids-speech-rate')` is `'0.75'` after the action

#### Scenario: Sign-out closes everything

- **WHEN** the user taps 🚪 יציאה
- **THEN** `signOut()` runs
- **AND** the popover closes
- **AND** the profile chip is replaced by the guest 🔓 כניסה button

### Requirement: Shared popover primitive with consistent dismissal

Both popovers (profile-chip and ⋯) SHALL share a single CSS class `.shell-popover` and SHALL be dismissed by:

- Tapping the trigger again
- Tapping outside the popover
- Pressing the `Escape` key

At most one popover SHALL be open at a time; opening one closes the other.

#### Scenario: Outside click closes popover

- **GIVEN** either popover is open
- **WHEN** the user clicks anywhere outside it
- **THEN** the popover closes

#### Scenario: Escape closes popover

- **GIVEN** either popover is open
- **WHEN** the user presses `Escape`
- **THEN** the popover closes

#### Scenario: Opening the other closes the first

- **GIVEN** the profile-chip popover is open
- **WHEN** the user taps ⋯
- **THEN** the profile-chip popover closes
- **AND** the ⋯ popover opens
