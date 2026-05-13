# Tasks: add-story-mode

## 1. Mode scaffolding

- [x] 1.1 Add the `📕 סיפורים` tab between Sentences and Units in the mode bar.
- [x] 1.2 Add `storyIdx`, `storyOrder`, `storyPlaying` to `state`.
- [x] 1.3 Add render/dispatch wiring (`state.mode === 'stories'` → `renderStories()` + `attachStoryEvents()`).
- [x] 1.4 Reset `storyOrder`/`storyIdx` on language and unit switches; cancel any in-flight speech on transition.

## 2. Renderer + interactions

- [x] 2.1 `tokenizeStoryLine()` splits a Latin-script sentence into word + separator tokens with absolute char offsets.
- [x] 2.2 `buildStoryWordIndex()` builds a normalized `Map<word, {ro,he,pron}>` from `story.words[]` for hover lookup.
- [x] 2.3 `renderStories()` walks each sentence's tokens, emits `<span class="story-word" data-w="…">` per word, with a `<span class="story-tooltip">` child holding `{he, pron}`.
- [x] 2.4 CSS: `.story-card`, `.story-text`, `.story-word`, `.story-word.active`, `.story-word.tap-open`, `.story-tooltip`; hover-on-desktop via `@media (hover:hover)`.
- [x] 2.5 Per-word click speaks the individual word via existing `speak()`.

## 3. TTS playback with word highlighting

- [x] 3.1 `buildFullStoryText()` joins all sentences with single spaces, returning the joined text + per-sentence char offsets.
- [x] 3.2 `buildWordPositions()` produces a flat `positions[]` of `{ start, end, wordIdx }` whose indices match the `data-w` attributes emitted by the renderer.
- [x] 3.3 `playStory()` constructs a single `SpeechSynthesisUtterance`, sets `lang/voice/rate` from existing helpers, and binds `onboundary` → `setActiveStoryWord(positions[hit].wordIdx)`.
- [x] 3.4 Highlight clears on `onend` and `onerror`.

## 4. Lint coverage

- [x] 4.1 Extend `scripts/check_pron.js` targets to include `STORIES_EN`.
- [x] 4.2 Run `npm run lint:pron`, confirm exit 0 with all pron values niqqud-bearing.

## 5. Initial content

- [x] 5.1 Author 22 Romanian stories: 2 Starter + 2 per Unit (1–10), 2–3 sentences each, with niqqud-fied per-word breakdowns.
- [x] 5.2 Author 22 English stories with the same structure.
- [x] 5.3 Cross-check lint after content lands.

## 6. Smoke test (user)

- [ ] 6.1 Open `index.html`, switch to Stories mode. Confirm a story renders, the 🔊 button plays, and the current word lights up as TTS speaks.
- [ ] 6.2 Hover (desktop) and tap (mobile) over a few words. Confirm the tooltip shows Hebrew + niqqud.
- [ ] 6.3 Switch language between Romanian and English; confirm the story list and TTS voice change correctly.
- [ ] 6.4 Switch unit; confirm only stories tagged ≤ current unit (or Starter) appear.

## 7. Ship

- [x] 7.1 Commit feature + content + lint extension on a feature branch.
- [x] 7.2 Push and open PR.
