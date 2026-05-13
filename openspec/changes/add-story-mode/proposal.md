# Change: add-story-mode

## Why

The kid has flashcards, sentences, quiz, listen, and match — all useful for short bursts of practice. The next gap is **reading practice on connected text**: short stories of 2–3 sentences where context links words together. Specifically the tutor wants something that:

- Reads the story aloud and **visually marks the current word** so the kid follows along.
- Lets the kid **hover (desktop) or tap (touch)** any word to see its Hebrew meaning + niqqud transliteration.
- Has stories paired with the same unit gating as the rest of the app, in both Romanian and English.

## What Changes

- New `📕 סיפורים` mode tab (between Sentences and Units).
- New `STORIES_RO` and `STORIES_EN` arrays. Each story is `{ id, titleHe, emoji, unit?, theme, sentences[], words[] }`. Each sentence is `{ ro, he, pron }`. The top-level `words[]` is the hover-lookup pool (per-language).
- Initial corpus: **22 stories per language** = 2 Starter + 2 per Unit (1–10), each 2–3 sentences, with hand-niqqud-fied transliterations.
- Story renderer wraps every word in an interactive `<span class="story-word">`:
  - Hover (desktop) / tap (touch) shows a Hebrew + pron tooltip.
  - Click also speaks the individual word via existing `speak()`.
- 🔊 Play button speaks the full story (all sentences concatenated) using a single `SpeechSynthesisUtterance` and binds `onboundary` to highlight the current word.
- Per-word highlighting falls back gracefully on browsers where `onboundary` is unsupported — the story still plays, no word is highlighted.
- Speech rate honours the existing `state.speechRate` pill.
- Lint extends to `STORIES_EN` so niqqud coverage doesn't regress when stories are added.

## Out of Scope (follow-ups)

- **Comprehension questions** after each story. Could be a "story quiz" mode later.
- **User-authored stories** in the Manage tab. Currently STORIES is built-in only.
- **Per-story progress tracking** (read/unread). Stories are presented in array order; shuffle is per-session.
- **Audio sprite** for native pronunciation. We still rely on browser TTS, with the new word-boundary highlighter as the only educational lift.
- **Length > 3 sentences**. Keeping each story tight by design — sustained attention is a separate problem.

## Impact

- **Modified**: `index.html` — new state fields (`storyIdx`, `storyOrder`, `storyPlaying`), new CSS for `.story-card / .story-word / .story-tooltip`, new mode dispatch, ~250 lines of inline data.
- **Modified**: `scripts/check_pron.js` — adds `STORIES_EN` to the lint target list.
- **No schema or auth impact.** Stories are not persisted per-user; no Supabase tables touched.
- **No build step impact.** Still a single-file static HTML.
