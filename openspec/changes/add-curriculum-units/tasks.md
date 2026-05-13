# Tasks: add-curriculum-units

Two clearly distinct work streams: **content authoring** (the 200 words + 600 sentences) and **system wiring** (units, gating, picker UI). They can be parallelized.

## Phase 1 — Schema + state

- [ ] 1.1 Migration SQL: add `max_unlocked_unit int default 1` to `progress` table; existing rows default in
- [ ] 1.2 Update `supabase/schema.sql` to include the new column (for fresh installs)
- [ ] 1.3 `loadFamilyData()` reads `max_unlocked_unit` into JS state
- [ ] 1.4 `saveProgressDebounced()` persists `max_unlocked_unit`
- [ ] 1.5 `state.currentUnit` initialized from `max_unlocked_unit` after profile selection

## Phase 2 — Unit constants + content tagging

- [ ] 2.1 Define `const UNITS = [{n, name, emoji, threshold}, ...]` in `index.html` with all 10 entries
- [ ] 2.2 Audit existing `VOCAB` and `BUILTIN_SENTENCES`: confirm none have `unit` field (Starter Pack = `unit: null`)

## Phase 3 — Unit 1 content (40 words + 60 sentences)

- [ ] 3.1 Author 20 Unit 1 thematic vocab entries (greetings & basic phrases)
- [ ] 3.2 Author 20 numbers 1-20 with `cat: 'מספרים', unit: 1`
- [ ] 3.3 Author 60 Unit 1 sentences using only Unit 1 vocab + Starter Pack
- [ ] 3.4 Tag all 40 + 60 with `unit: 1`

## Phase 4 — Units 2-10 content (180 words + 540 sentences)

- [ ] 4.1 Unit 2: 20 vocab + 60 sentences (theme TBD — e.g., family & people)
- [ ] 4.2 Unit 3: 20 + 60 (e.g., animals)
- [ ] 4.3 Unit 4: 20 + 60 (e.g., food & meals)
- [ ] 4.4 Unit 5: 20 + 60 (e.g., body & health)
- [ ] 4.5 Unit 6: 20 + 60 (e.g., home & rooms)
- [ ] 4.6 Unit 7: 20 + 60 (e.g., school)
- [ ] 4.7 Unit 8: 20 + 60 (e.g., outdoors & weather)
- [ ] 4.8 Unit 9: 20 + 60 (e.g., feelings & opinions)
- [ ] 4.9 Unit 10: 20 + 60 (e.g., past/future tenses & narration)
- [ ] 4.10 Each unit's sentences SHOULD reuse words from the same and earlier units (and Starter Pack) for cumulative reinforcement

**Note**: content generation is the dominant cost. AI-assist + manual review is the expected workflow. Pronunciation transliteration must match the existing Hebrew style.

## Phase 5 — Filter changes

- [ ] 5.1 Add `unitFiltered()` helper that returns vocab/sentences for `state.currentUnit`
- [ ] 5.2 Update `filtered()` (used by flashcards/quiz/match/listen) to call `unitFiltered`
- [ ] 5.3 Update `renderSentences()` order/filter to call `unitFiltered`
- [ ] 5.4 Existing category-chip filter composes on top of unit filter

## Phase 6 — Unit picker UI

- [ ] 6.1 Add `<button data-mode="units">📚 יחידות</button>` to modes
- [ ] 6.2 `renderUnits()`: 10 tiles with locked/unlocked styling and threshold hints
- [ ] 6.3 `attachUnitsEvents()`: click → set `state.currentUnit` → route back to last practice mode
- [ ] 6.4 Add a "current unit" pill to the auth/header area
- [ ] 6.5 Clicking the pill opens the unit picker

## Phase 7 — Unlock logic

- [ ] 7.1 In `updateStats()` (or wherever score is bumped): recompute `max_unlocked_unit` from `score`
- [ ] 7.2 If unlock happened: render a small overlay/toast "🎉 יחידה N נפתחה!"
- [ ] 7.3 Persist via the debounced progress save

## Phase 8 — Reset behavior

- [ ] 8.1 `uResetProgress` (admin tab) resets `max_unlocked_unit` to 1 along with score/streak/seen

## Phase 9 — Tests + smoke

- [ ] 9.1 Parse-check JS still passes
- [ ] 9.2 Manual: create a fresh profile, verify Unit 1 default
- [ ] 9.3 Manual: rack up 500 points, verify Unit 2 unlocks
- [ ] 9.4 Manual: switch to Unit 2 then back to Unit 1, verify pool shrinks
- [ ] 9.5 Manual: sibling profile has independent `max_unlocked_unit`
- [ ] 9.6 `openspec validate add-curriculum-units --strict` passes

## Dependencies + parallelism

```
1 ──┬──► 5 ──► 6 ──► 7 ──► 8 ──► 9
2 ──┘
3, 4 (content) ──► can start any time, gates only Phase 9 smoke
```

Content authoring (Phase 3 + 4) is the longest tail and is fully parallel to schema/UI work.
