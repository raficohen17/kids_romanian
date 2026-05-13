# Design: add-story-mode

## Context

A 9-year-old learning a foreign language reads short connected text very differently from how she reads individual flashcards. We needed a mode that:

1. Plays a sentence-length passage so the ear hears connected speech, not isolated words.
2. Visually marks the word being spoken so eye-tracking stays in sync.
3. Lets the kid hover/tap any unfamiliar word to see Hebrew meaning + niqqud transliteration without breaking flow.

The existing Sentences mode is close but covers one sentence at a time and reveals the full Romanian only after a click — it's "test yourself" UX, not "read along" UX.

## Goals / Non-Goals

**Goals**
- Mode tab with story navigation (prev / play / next / shuffle).
- 22 stories per language at launch, unit-gated like sentences.
- Word-level highlighting synced to TTS.
- Hover (desktop) + tap (touch) tooltip with Hebrew + niqqud.
- Per-word click also speaks just that word (reuse existing `speak()`).
- Lint guarantees no regression of pron niqqud quality.

**Non-Goals**
- No user-authored stories yet — content is built-in.
- No comprehension scoring / progress tracking. Reading the story is the reward.
- No native-recorded audio — browser TTS only.
- No reflow when the speed pill changes mid-playback (just restart).

## Decisions

### Decision 1: One utterance per story, not one per sentence

We concatenate `sentences[].ro` with single spaces into a single `SpeechSynthesisUtterance`. `onboundary` fires with `charIndex` in that joined text. We pre-compute a flat `positions[]` array of `{ start, end, wordIdx }` covering every word, and look up the active word on each boundary event.

**Rationale.** Per-sentence utterances would require chaining `onend → speak next` which has audible gaps and complicates the highlight reset. One utterance plays smoothly and the highlight is driven by a single boundary stream.

**Trade-off.** Browser support for `onboundary` is patchy. We accept that on Firefox it may fire infrequently or not at all — the story still plays. No fallback animation; missing highlight is graceful degradation.

### Decision 2: Tokenize on the fly, don't ship a tokenized blob

The story data ships only the raw `ro` string per sentence + a flat `words[]` array of `{ ro, he, pron }` for hover lookup. The renderer tokenizes each sentence with `/(\p{L}+(?:['']\p{L}+)?)/gu` and looks up each word in a normalized map.

**Rationale.** Authoring stories is already labor-intensive (44 pron strings × niqqud). Adding a per-word index inline doubles the work. On-the-fly tokenization is essentially free at render time and matches whatever the speech synth sees.

### Decision 3: words[] is the hover pool, not a strict 1:1 list

A word that doesn't have a `words[]` entry renders as plain text (no tooltip, no special highlight on hover). This means authors only need to gloss the *interesting* words — articles, prepositions, conjugations of "to be" can be skipped.

**Rationale.** "Every word translated" hurts more than it helps for a 9-year-old: the wall of tooltips becomes noise. Glossing 4–6 content words per story is the right density.

### Decision 4: Hover vs tap — branch on `matchMedia('(hover:hover)')`

CSS uses `@media (hover:hover) { .story-word:hover .story-tooltip { opacity:1; } }` so desktop gets the tooltip on hover with no JS. On touch devices (where `(hover:hover)` is false), JS toggles a `.tap-open` class on click which the CSS also matches.

**Rationale.** Pure-CSS hover on desktop is reliable and fast. Touch needs explicit tap-toggle because mobile browsers fake hover on first tap, which would leave the tooltip stuck.

**Trade-off.** A hybrid device (touchscreen laptop) might confuse the heuristic; we accept that for now since the kid uses one consistent device.

### Decision 5: One `EXEMPT` whitelist in the lint, no per-block carve-outs

The pron lint scans `VOCAB_EN`, `BUILTIN_SENTENCES_EN`, and `STORIES_EN` with the same niqqud-presence check. If a story's pron legitimately has no diacritic (e.g., a proper noun like "Maya"), we'd add it to `EXEMPT`. Initial whitelist is empty.

**Rationale.** Consistency across the EN corpus is the goal. Three different rules would erode trust in the gate.

## Risks / Trade-offs

- **Risk: `onboundary` is unreliable cross-browser.** Mitigation: graceful no-op. If we ever need true reliability, we'd switch to one-utterance-per-sentence with measured timing fallback.
- **Risk: Romanian niqqud accuracy.** I authored these without a fluent Romanian editor. Mitigation: the tutor will correct over time; the lint at least keeps the niqqud *present*, not necessarily *perfect*. Track corrections via PRs as the daughter learns.
- **Trade-off: Inline data vs separate JSON file.** Inline keeps the no-build promise; the cost is `index.html` size growth (~280 lines for stories). Acceptable while < 6,500 lines total.
- **Trade-off: 2 stories per unit is shallow.** For a year of practice we'd probably want 5+ per unit. The next iteration can double the corpus per the user's pace.

## Migration / Compatibility

- No schema changes — purely additive content + UI.
- Existing users land on Flashcards as before; Stories mode is opt-in via the new tab.
- Speech-rate pill (`state.speechRate`) is shared across all TTS callsites, including the new `playStory`. No new persisted state.
