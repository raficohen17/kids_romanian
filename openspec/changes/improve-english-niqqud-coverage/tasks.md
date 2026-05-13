# Tasks: improve-english-niqqud-coverage

## 1. Lint script (gatekeeper, do this first)

- [ ] 1.1 Create `scripts/check_pron.js` — zero-dependency Node script that scans `index.html` for `pron:"..."` inside `VOCAB_EN` and `BUILTIN_SENTENCES_EN` and flags Hebrew-containing prons with no niqqud diacritic.
- [ ] 1.2 Add an `EXEMPT` whitelist constant inside the script (initially empty).
- [ ] 1.3 Add `"lint:pron": "node scripts/check_pron.js"` to `package.json`.
- [ ] 1.4 Run lint, capture the baseline offender count (expected ~700+). Save the count in commit message for reference.

## 2. Canonical EN_PRON_DICT

- [ ] 2.1 Add `const EN_PRON_DICT = { … }` constant inside `index.html` near the top of the English-data block. Cover the ~80 most-frequent English words used in sentences (pronouns, articles, numbers 1–20, common verbs, common nouns, days, weather, family).
- [ ] 2.2 Cross-check `EN_PRON_DICT` entries against `VOCAB_EN` to ensure no contradictions.

## 3. Bulk niqqud sweep — sentence-level pron

- [ ] 3.1 Write a one-shot Python script (e.g. `/tmp/add_niqqud_v3.py`) using `EN_PRON_DICT` as the replacement table, ANCHORED with surrounding quotes/spaces to prevent mid-word substitution.
- [ ] 3.2 Apply the sweep to the `BUILTIN_SENTENCES_EN` block only.
- [ ] 3.3 Re-run `npm run lint:pron`, expect the offender count to drop sharply.

## 4. Bulk niqqud sweep — per-word breakdown pron

- [ ] 4.1 Reuse the same script to sweep the `words` arrays within each sentence (same `pron:"..."` pattern, different surrounding context).
- [ ] 4.2 Re-run lint, expect another large drop.

## 5. Chain-regression repair

- [ ] 5.1 Identify all chain-regressions by grepping for known broken patterns (`נאַין`, `באַי`, `פאַיב`, etc.).
- [ ] 5.2 Apply a corrective-pass replace table to fix them all.
- [ ] 5.3 Spot-check 10 random sentences in the browser to confirm the pron renders correctly.

## 6. Long-tail manual cleanup

- [ ] 6.1 Run lint, take the remaining offenders list (should be < ~50).
- [ ] 6.2 Hand-edit each remaining offender — these are rare/unique words not in `EN_PRON_DICT`.
- [ ] 6.3 Run lint, confirm exit code 0 and "All N pron values look niqqud-bearing." message.

## 7. Verify in the running app

- [ ] 7.1 Open `index.html` locally, switch to English mode, browse Flashcards through Units 1–10 and the Starter Pack. Confirm pron looks right.
- [ ] 7.2 Switch to Sentences mode, browse a sample across all units. Confirm sentence-level and word-breakdown prons both render with niqqud.
- [ ] 7.3 Use the browser inspector to confirm no `undefined` rendering, no leakage of Romanian text.

## 8. Ship

- [ ] 8.1 Commit `scripts/check_pron.js`, the `package.json` change, and the `index.html` content updates in coherent chunks (lint first, content second).
- [ ] 8.2 Push to `feat/english-niqqud-completion` (or whichever branch is active).
- [ ] 8.3 Open PR. PR description should include the before/after lint counts.
