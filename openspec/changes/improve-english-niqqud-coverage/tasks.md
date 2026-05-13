# Tasks: improve-english-niqqud-coverage

## 1. Lint script (gatekeeper, do this first)

- [x] 1.1 Create `scripts/check_pron.js` — zero-dependency Node script that scans `index.html` for `pron:"..."` inside `VOCAB_EN` and `BUILTIN_SENTENCES_EN` and flags Hebrew-containing prons with no niqqud diacritic.
- [x] 1.2 Add an `EXEMPT` whitelist constant inside the script (initially empty).
- [x] 1.3 Add `"lint:pron": "node scripts/check_pron.js"` to `package.json`.
- [x] 1.4 Run lint, capture the baseline offender count. Baseline turned out to be **34 of 1,906** (not the ~700 originally estimated — earlier mass-replace passes covered more than expected).

## 2. Canonical EN_PRON_DICT

- [ ] 2.1 Add `const EN_PRON_DICT = { … }` constant inside `index.html`. _Deferred:_ baseline offenders were only 34, so a direct replace-map in `/tmp/fix_niqqud_v3.py` was enough. The dict is still a good follow-up when authoring new content; revisit if the lint starts flagging fresh content.
- [ ] 2.2 Cross-check `EN_PRON_DICT` entries against `VOCAB_EN` to ensure no contradictions. _(Blocked by 2.1.)_

## 3. Bulk niqqud sweep — sentence-level pron

- [x] 3.1 Wrote `/tmp/fix_niqqud_v3.py` — scoped regex substitution against `pron:"..."` only (so `he:"..."` Hebrew translations are untouched).
- [x] 3.2 Applied the sweep to the `BUILTIN_SENTENCES_EN` block.
- [x] 3.3 Re-ran `npm run lint:pron`, offender count dropped to 0.

## 4. Bulk niqqud sweep — per-word breakdown pron

- [x] 4.1 Same script — it matches every `pron:"..."` whether at sentence top-level or inside `words[]`.
- [x] 4.2 Lint clean.

## 5. Chain-regression repair

- [x] 5.1 Identified `"נאַין"` (5 occurrences) as the only material chain-regression for "nine". `"באַי"`, `"פאַיב"`, `"פאַיין"`, etc. all came up 0.
- [x] 5.2 Applied a corrective regex pass scoped to `pron:"..."` to fix `"נאַין" → "נַאיין"`.
- [ ] 5.3 Spot-check in the browser. _Pending user smoke-test — file is a static HTML, no dev server needed; open `index.html` directly._

## 6. Long-tail manual cleanup

- [x] 6.1 Lint after sweep showed 0 offenders — no long tail.
- [x] 6.2 N/A.
- [x] 6.3 `npm run lint:pron` exits 0 with `All 1906 pron values look niqqud-bearing.`

## 7. Verify in the running app

- [ ] 7.1 Open `index.html` locally, switch to English mode, browse Flashcards through Units 1–10 and the Starter Pack.
- [ ] 7.2 Switch to Sentences mode, browse a sample across all units.
- [ ] 7.3 Inspector check for `undefined` or Romanian text leakage.

_All three are pending a manual smoke-test from the user._

## 8. Ship

- [x] 8.1 Commit `scripts/check_pron.js`, `package.json`, and `index.html` content updates in coherent chunks.
- [x] 8.2 Push to the feature branch.
- [ ] 8.3 Open PR. PR description includes before/after lint counts (34 → 0).
