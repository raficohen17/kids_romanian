# stories-mode Specification Delta

## ADDED Requirements

### Requirement: Stories mode shows short multi-sentence passages

The system SHALL provide a "Stories" practice mode reachable from the mode bar. In Stories mode, the kid SHALL see one story at a time, where a story is 2–3 sentences in the active target language with a Hebrew title.

The mode SHALL respect the current language (`state.language` ∈ {`ro`, `en`}) and unit (`state.currentUnit`) — only stories whose `unit` is unset (Starter) or ≤ `state.currentUnit` are shown.

#### Scenario: Stories tab is visible

- **WHEN** the page renders
- **THEN** the mode bar contains a `📕 סיפורים` button between `🗣️ משפטים` and `📚 יחידות`

#### Scenario: Only in-scope stories appear

- **WHEN** `state.language` is `ro` and `state.currentUnit` is `3`
- **THEN** the story list contains every entry of `STORIES_RO` whose `unit` is undefined OR `unit <= 3`
- **AND** no entry from `STORIES_EN`

### Requirement: Each word is hover/tap interactive

For every word in the displayed story the system SHALL render an interactive element. On devices that report `matchMedia('(hover:hover)').matches`, hovering the element SHALL reveal a tooltip containing the word's Hebrew meaning and Hebrew niqqud transliteration when known. On other devices, tapping the element SHALL toggle the same tooltip.

Tapping or clicking a word SHALL also speak that single word via the existing `speak()` function (using the current `state.speechRate` and `ttsLang()`).

#### Scenario: Hover shows tooltip on desktop

- **GIVEN** the device reports hover capability
- **WHEN** the user hovers a word with a known `{he, pron}` entry
- **THEN** a tooltip appears with the Hebrew translation and niqqud transliteration
- **AND** the tooltip disappears when the hover ends

#### Scenario: Tap toggles tooltip on touch

- **GIVEN** the device does NOT report hover capability
- **WHEN** the user taps a word
- **THEN** the tooltip becomes visible
- **AND** a subsequent tap outside the word hides the tooltip

#### Scenario: Words without a known meaning render plain

- **WHEN** a word in the story text has no matching entry in `story.words[]` (after lowercasing and stripping punctuation)
- **THEN** the word is still rendered, no tooltip is shown
- **AND** clicking the word still speaks it via TTS

### Requirement: Playing a story highlights words in sync with TTS

The system SHALL provide a 🔊 play button that speaks all sentences of the current story as a single utterance, at the current `state.speechRate`, in the language indicated by `ttsLang()`.

While speaking, the system SHALL highlight the word currently being spoken by adding an `active` CSS class to its `<span>`. The highlight SHALL clear when the utterance ends or errors.

If the browser does not emit `SpeechSynthesisUtterance.onboundary` events, the system SHALL still play the audio; the absence of highlighting is acceptable degradation.

#### Scenario: Playback highlights words

- **GIVEN** a browser that emits `onboundary` events
- **WHEN** the user taps the 🔊 button
- **AND** TTS reaches char index `n` corresponding to the third word
- **THEN** the third word's `<span>` has the class `active`
- **AND** no other word has the class `active`

#### Scenario: Highlight clears at end

- **WHEN** TTS finishes the utterance
- **THEN** no `<span>` has the class `active`

#### Scenario: Speech rate is honoured

- **GIVEN** the user has selected `×0.5` via the speed pill
- **WHEN** the user plays a story
- **THEN** the utterance's `rate` is `0.5`

### Requirement: Pron lint covers STORIES_EN

The lint script (`scripts/check_pron.js`) SHALL include `STORIES_EN` in its target list and flag any pron value containing Hebrew letters but no niqqud diacritic, exactly as it does for `VOCAB_EN` and `BUILTIN_SENTENCES_EN`.

#### Scenario: Lint clean after stories ship

- **WHEN** `node scripts/check_pron.js` is run
- **THEN** the exit code is `0`
- **AND** stdout reports `All N pron values look niqqud-bearing.` where `N` includes the pron values from `STORIES_EN`
