# curriculum-units Specification Delta

## ADDED Requirements

### Requirement: Ten ordered curriculum units

The system SHALL provide exactly 10 curriculum units, numbered 1 through 10. Each unit SHALL contain 20 new built-in vocabulary entries and 60 new built-in sentence entries. Unit 1 SHALL additionally contain the 20 cardinal numbers from 1 to 20.

Each unit SHALL have stable metadata in code: an integer number (1-10), a Hebrew display name, an emoji, and an integer unlock threshold.

#### Scenario: Unit 1 contains 40 effective vocabulary entries

- **WHEN** the app loads
- **THEN** the built-in vocab tagged `unit = 1` contains exactly 40 entries
- **AND** of those, exactly 20 have `cat = 'מספרים'` representing 1, 2, ..., 20
- **AND** the remaining 20 are the thematic Unit 1 vocabulary

#### Scenario: Units 2-10 contain 20 vocabulary entries each

- **WHEN** the app loads
- **AND** for each `N` in 2..10
- **THEN** the built-in vocab tagged `unit = N` contains exactly 20 entries

#### Scenario: Each unit contains 60 sentences

- **WHEN** the app loads
- **AND** for each `N` in 1..10
- **THEN** the built-in sentences tagged `unit = N` contains exactly 60 entries

### Requirement: Starter Pack remains always available

The existing 25 built-in words and 200 built-in sentences SHALL remain accessible across every unit. They SHALL NOT be removed, renumbered, or tagged with a unit. They are exposed to the practice pool regardless of the kid's current unit.

#### Scenario: Starter Pack content has no unit tag

- **WHEN** the built-in vocab is inspected
- **THEN** all 25 original entries have either no `unit` field or `unit = null`

#### Scenario: Starter Pack appears in every unit's practice pool

- **WHEN** the kid is in Unit N (for any N in 1..10)
- **AND** a practice mode requests vocab
- **THEN** all 25 Starter Pack words are in the returned set
- **AND** all 200 Starter Pack sentences are in the returned set

### Requirement: User-added content always available

User-added vocab and sentences (created via the manage tab or bulk import) SHALL NOT be unit-gated. They are exposed to the practice pool regardless of which unit the kid is "in."

#### Scenario: User-added words appear in any unit's practice pool

- **WHEN** the parent adds 5 words via the manage tab
- **AND** the kid switches between Unit 1 and Unit 5
- **THEN** all 5 user-added words are present in both pools

### Requirement: Linear unlock progression

Unit `N` SHALL unlock when `score >= 500 * (N - 1)`. Unit 1 unlocks at score 0 (so every profile starts with Unit 1 unlocked).

Thresholds:

| Unit | Threshold |
|---|---|
| 1 | 0 |
| 2 | 500 |
| 3 | 1000 |
| 4 | 1500 |
| 5 | 2000 |
| 6 | 2500 |
| 7 | 3000 |
| 8 | 3500 |
| 9 | 4000 |
| 10 | 4500 |

When the score crosses a threshold during a practice session, the app SHALL persist the new `max_unlocked_unit` on the `progress` row and surface a brief celebration ("🎉 Unit N נפתחה!").

#### Scenario: Profile starts with Unit 1 unlocked

- **WHEN** a new profile is created and selected
- **THEN** `max_unlocked_unit` is 1
- **AND** Unit 1 is selectable from the unit picker
- **AND** Units 2-10 are visible but disabled with their unlock-threshold hints shown

#### Scenario: Crossing a threshold unlocks the next unit

- **WHEN** the kid's score increases from 490 to 510 during a practice session
- **THEN** `max_unlocked_unit` is updated from 1 to 2
- **AND** a celebration notice appears on screen
- **AND** the unit picker now shows Unit 2 as selectable

#### Scenario: Score regress does NOT lock units back

- **WHEN** progress is reset (`uResetProgress` from the admin tab)
- **AND** score drops to 0
- **THEN** `max_unlocked_unit` is also reset to 1
- **NOTE**: This is the only path that locks a previously-unlocked unit. Normal play never moves `max_unlocked_unit` backwards.

### Requirement: Cumulative practice pool

When a kid is "in" Unit N (`state.currentUnit = N`), the practice pool for ALL practice modes (flashcards, quiz, listening, matching, sentences) SHALL be the union of:

- the Starter Pack
- the kid's user-added content
- the built-in content of units 1 through N

#### Scenario: Practice in Unit 3 includes Units 1-3 plus Starter Pack

- **WHEN** the kid selects Unit 3
- **AND** a flashcard session starts
- **THEN** the pool is: 25 starter + N user-added + 60 (Units 1+2+3 = 40 + 20 + 20 vocab)
- **AND** sentences pool is: 200 starter + M user-added + 180 (60 × 3 units)

#### Scenario: Practicing in a lower unit narrows the pool

- **WHEN** the kid has unlocked Unit 7 but selects Unit 2
- **AND** a flashcard session starts
- **THEN** the pool is: 25 starter + N user-added + Units 1+2 vocab (60 entries)
- **AND** Unit 3-7 content is NOT included

### Requirement: Always go back

A kid SHALL be able to select any previously unlocked unit at any time. Selecting an earlier unit changes the practice pool (narrower) and the displayed current-unit indicator but does NOT affect `max_unlocked_unit` or progress.

#### Scenario: Switching to a lower unit preserves max_unlocked_unit

- **WHEN** the kid has `max_unlocked_unit = 5`
- **AND** she selects Unit 2 from the unit picker
- **THEN** `state.currentUnit` is set to 2
- **AND** `max_unlocked_unit` remains 5
- **AND** the unit picker still shows Units 1-5 as selectable

#### Scenario: Locked units are not selectable

- **WHEN** the kid has `max_unlocked_unit = 3`
- **AND** she attempts to click Unit 5 in the picker
- **THEN** the tile is visibly disabled
- **AND** clicking does not change `state.currentUnit`
- **AND** a hint shows the unlock threshold ("עוד 1100 נקודות")

### Requirement: Per-profile progression

Unit progression SHALL be tracked per kid profile. Sibling profiles SHALL progress independently — Maya's unlocks have no effect on Noam's.

#### Scenario: Sibling profiles have independent unlocks

- **WHEN** Maya unlocks Unit 4
- **AND** the parent switches to Noam's profile
- **THEN** Noam's `max_unlocked_unit` is whatever it was for him (unchanged by Maya's progress)

### Requirement: Unit picker UI

The system SHALL provide a "📚 יחידות" mode tab. The tab renders a 10-tile grid showing each unit's number, name, emoji, and locked/unlocked state. Clicking an unlocked tile sets `state.currentUnit` and returns the kid to her last-used practice mode.

The auth/header area SHALL display a small "current unit" pill ("🎒 יחידה N — שם") so the kid always knows the context.

#### Scenario: Unit picker shows all 10 tiles

- **WHEN** the kid opens the "📚 יחידות" tab
- **THEN** 10 unit tiles are rendered, in numeric order
- **AND** each tile shows the unit number, name, and emoji
- **AND** unlocked tiles have a different visual state from locked ones
- **AND** locked tiles show the unlock-threshold hint

#### Scenario: Header shows current unit

- **WHEN** the kid has selected Unit 3
- **THEN** the header pill reads "🎒 יחידה 3 — <unit-3-name>"
- **AND** clicking the pill jumps to the unit picker tab

### Requirement: Default current unit

When a profile is loaded (after sign-in or profile switch), the system SHALL set `state.currentUnit` to the profile's `max_unlocked_unit`. Profiles always start their session in their most advanced unit.

#### Scenario: Loading a profile sets currentUnit to max unlocked

- **WHEN** the kid signs in and selects her profile
- **AND** her `max_unlocked_unit` is 4
- **THEN** `state.currentUnit` is set to 4
- **AND** practice modes draw from Units 1-4 + Starter Pack + user-added

## MODIFIED Requirements

### Requirement: Per-profile progress (originally in family-dictionary)

The `progress` table gains a `max_unlocked_unit` integer column (default 1). The existing score/streak/seen columns are unchanged. All three plus the new column SHALL be loaded into JS state on profile selection and persisted (debounced) during practice.

#### Scenario: max_unlocked_unit persists across sessions

- **WHEN** the kid unlocks Unit 4 and signs out
- **AND** signs back in and selects the same profile
- **THEN** her unit picker shows Units 1-4 as unlocked
- **AND** `state.currentUnit` defaults to 4
