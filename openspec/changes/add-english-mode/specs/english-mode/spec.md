# english-mode Specification Delta

## ADDED Requirements

### Requirement: Language toggle in header

The system SHALL display a language pill in the auth/header area showing the currently selected target language (🇷🇴 רומנית or 🇬🇧 אנגלית). Clicking the pill SHALL open a language picker that lets the kid switch between the two.

The toggle SHALL be reachable in guest mode and in authed mode alike.

#### Scenario: Pill shows current language

- **WHEN** the page renders
- **THEN** the header pill shows the flag and Hebrew name of the current target language
- **AND** matches `state.language`

#### Scenario: Picker switches the target language

- **WHEN** the kid taps the language pill
- **AND** the picker opens
- **AND** she taps the English flag
- **THEN** `state.language` becomes `'en'`
- **AND** the built-in corpus references switch to the English constants
- **AND** TTS uses `'en-US'` thereafter
- **AND** the picker closes

### Requirement: Independent English curriculum

The system SHALL include 10 English curriculum units, parallel to but independent of the Romanian units. Each English unit SHALL contain 20 new vocabulary entries and 60 new sentences specific to English-learning for Hebrew speakers (not direct translations of Romanian content).

In addition, an English Starter Pack of approximately 25 words and 200 sentences SHALL be available always (analogous to the Romanian Starter Pack).

#### Scenario: English Unit 1 contains 20 vocab + 60 sentences

- **WHEN** the app loads in English mode
- **AND** the built-in English vocab is inspected
- **THEN** entries tagged `language = 'en'` and `unit = 1` total exactly 20

#### Scenario: English Starter Pack has no unit tag

- **WHEN** built-in English vocab is inspected
- **THEN** Starter Pack entries have `language = 'en'` and either no `unit` field or `unit = null`

#### Scenario: Romanian and English curriculums are disjoint

- **WHEN** the kid is in English mode
- **THEN** no Romanian vocab or sentences appear in any practice pool
- **AND** vice versa when in Romanian mode

### Requirement: Per-(profile, language) progress

The `progress` table SHALL be keyed by `(profile_id, language)`. Each profile holds at most one progress row per language, with independent score, best_streak, seen, max_unlocked_unit, and updated_at fields.

#### Scenario: Switching language loads different progress

- **WHEN** Maya has been practicing Romanian and her score is 850
- **AND** she taps the language pill and switches to English
- **AND** her English progress row exists with score 100
- **THEN** the stats display shows score=100, not 850
- **AND** her unit picker reflects English's `max_unlocked_unit`, not Romanian's

#### Scenario: First switch to English creates a fresh progress row

- **WHEN** a profile has never used English mode before
- **AND** the kid switches to English
- **THEN** a new `progress` row is inserted with `(profile_id, 'en')` and zeros for score/streak/seen and 1 for `max_unlocked_unit`
- **AND** the row is loaded into state

### Requirement: Per-language family vocab and sentences

User-added vocab and sentences in the family pool SHALL be tagged with the language they were added in. Practice modes filter user-added content by the active `state.language`.

#### Scenario: Adding a word in Romanian mode tags it 'ro'

- **WHEN** the parent is in Romanian mode and adds "Pisică = חתול"
- **THEN** the inserted `vocab` row has `language = 'ro'`
- **AND** the row appears in Romanian-mode practice
- **AND** the row is absent from English-mode practice

#### Scenario: Bulk import targets the active language

- **WHEN** the parent is in English mode and bulk-imports a Markdown table of 8 words
- **THEN** all 8 inserted rows have `language = 'en'`

### Requirement: TTS language follows state.language

The `speak()` function SHALL use `'en-US'` as the SpeechSynthesisUtterance lang when `state.language === 'en'`, and `'ro-RO'` when `state.language === 'ro'`. Voice selection falls back to whatever the browser provides for that locale.

#### Scenario: English mode reads with English voice

- **WHEN** the kid is in English mode
- **AND** she taps a flashcard's pronunciation button
- **THEN** `speak()` is called with `lang = 'en-US'`
- **AND** if the browser has any `en-*` voice installed, it is preferred

### Requirement: Default language

A newly-loaded profile session SHALL start with `state.language = 'ro'` unless the profile has previously chosen English in this browser. Last-used language SHALL be persisted in `localStorage` (`ro-kids-last-language-<profile-id>`).

#### Scenario: Returning kid sees her last language

- **WHEN** Maya last used English on this device
- **AND** the parent signs in again and selects Maya
- **THEN** the app loads in English mode without manual toggling

#### Scenario: New profile starts in Romanian

- **WHEN** a profile is freshly created
- **AND** selected for the first time
- **THEN** `state.language = 'ro'`

### Requirement: UI strings remain Hebrew

All Hebrew UI strings (tab names, button labels, pronunciation guide explanations, modal copy) SHALL be unaffected by the language toggle. Only the target-language content (vocab, sentences, TTS lang) changes.

#### Scenario: Toggling to English doesn't change UI labels

- **WHEN** the kid switches from Romanian to English mode
- **THEN** mode tabs still read "🎴 כרטיסיות", "🎯 חידון", etc.
- **AND** the pronunciation guide page still explains Hebrew transliteration conventions

### Requirement: Guest mode supports language toggle

Even when not signed in, the kid SHALL be able to switch between Romanian and English target languages. Guest progress (score/streak/seen) is persisted per-language in `localStorage`:

- `ro-kids-stats-ro` for Romanian progress
- `ro-kids-stats-en` for English progress

#### Scenario: Guest toggles to English and back

- **WHEN** an unauthenticated visitor starts in Romanian and reaches score 30
- **AND** she switches to English
- **AND** scores 20 in English
- **AND** switches back to Romanian
- **THEN** the displayed score is 30 (her Romanian progress)
- **AND** flipping to English again shows 20

## MODIFIED Requirements

### Requirement: Vocab and sentences scoped to family (now also by language)

Vocab and sentences SHALL be scoped by both `family_id` AND `language`. RLS still enforces `family_id`; the application MUST also filter by `state.language` when reading. Writes SHALL set `language` from `state.language` at insert time.

(Originally defined in `family-dictionary` capability of `add-supabase-multifamily-auth`.)

#### Scenario: RLS plus language filter

- **WHEN** the parent is in English mode and queries `SELECT * FROM vocab WHERE family_id = X`
- **THEN** RLS returns only rows where `family_id` matches
- **AND** the client filters those to rows with `language = 'en'`

### Requirement: Per-profile progress (now also per-language)

Progress SHALL be keyed by `(profile_id, language)`. Each combination MUST hold its own score, best_streak, seen, and max_unlocked_unit. Switching language SHALL load the matching row (or initialize one if it does not exist).

(Originally in `family-dictionary` of `add-supabase-multifamily-auth`, MODIFIED again in `add-curriculum-units`.)

#### Scenario: Two languages, two progress rows

- **WHEN** Maya has practiced both languages
- **THEN** her family has 2 progress rows: `(maya_id, 'ro')` and `(maya_id, 'en')`
- **AND** each has independent values

### Requirement: Ten ordered curriculum units (now per-language)

Each language SHALL have its own set of exactly 10 units with their own metadata, vocab, and sentences. `state.currentUnit` MUST be scoped to `(profile, language)`. Switching language SHALL re-render the unit picker with the metadata for the newly-active language.

(Originally in `curriculum-units` capability of `add-curriculum-units`.)

#### Scenario: Each language has 10 units

- **WHEN** the kid is in Romanian mode
- **THEN** the unit picker shows 10 Romanian-themed units
- **WHEN** she switches to English
- **THEN** the unit picker re-renders to show 10 English-themed units (different names, different thresholds optional but same default)
