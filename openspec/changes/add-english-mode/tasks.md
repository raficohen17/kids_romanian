# Tasks: add-english-mode

Assumes `add-curriculum-units` has been applied (units already exist). If not, the unit-related items below need to be deferred or trimmed.

## Phase 1 — Schema migration

- [ ] 1.1 Add `language` column to `vocab` (default `'ro'`, check constraint)
- [ ] 1.2 Add `language` column to `sentences` (default `'ro'`, check constraint)
- [ ] 1.3 Add `language` column to `progress` (default `'ro'`, check constraint)
- [ ] 1.4 Drop existing `progress_pkey` (was `profile_id`); add new PK on `(profile_id, language)`
- [ ] 1.5 Backfill existing rows with `language = 'ro'` (covered by default; verify count)
- [ ] 1.6 Update `supabase/schema.sql` for fresh-install parity

## Phase 2 — JS data plumbing

- [ ] 2.1 Introduce `state.language` (default `'ro'`)
- [ ] 2.2 Split `VOCAB` constant into `VOCAB_RO` (existing 25 starter) and `VOCAB_EN` (new starter)
- [ ] 2.3 Split `BUILTIN_SENTENCES` into `BUILTIN_SENTENCES_RO` and `BUILTIN_SENTENCES_EN`
- [ ] 2.4 Define `UNITS_EN` array (10 entries with English-curriculum metadata)
- [ ] 2.5 Update `getVocab()` / `getSentences()` / `getUnits()` to return the language-appropriate corpus
- [ ] 2.6 `loadFamilyData()` filters by `state.language` and loads the matching progress row
- [ ] 2.7 `saveProgressDebounced()` writes to the `(profile_id, language)` row

## Phase 3 — TTS

- [ ] 3.1 `speak()` reads `state.language` and sets `lang` to `'en-US'` or `'ro-RO'`
- [ ] 3.2 Voice preference: prefer any installed `en-*` or `ro-*` voice

## Phase 4 — Language toggle UI

- [ ] 4.1 Add language pill to the auth bar (between profile name and sign-out)
- [ ] 4.2 Click → opens a language picker overlay (2 tiles: 🇷🇴 / 🇬🇧)
- [ ] 4.3 Selection: updates `state.language`, persists to localStorage `ro-kids-last-language-<profile_id>`, reloads data via `loadFamilyData()`, re-renders
- [ ] 4.4 On profile load, read `localStorage` last-language and apply

## Phase 5 — User-added content language tagging

- [ ] 5.1 `syncVocabFull()` includes `language: state.language` in each upserted row
- [ ] 5.2 `syncSentencesFull()` includes `language: state.language`
- [ ] 5.3 Bulk import handler tags rows with the active language
- [ ] 5.4 Manage tab UI: optional small hint "מילים יתווספו ל[שפה הנוכחית]"

## Phase 6 — English Starter Pack content

- [ ] 6.1 Author ~25 English starter words (basic Hebrew→English vocab)
- [ ] 6.2 Author ~200 English starter sentences

## Phase 7 — English Unit content (10 × 20 + 10 × 60 = 200 + 600)

- [ ] 7.1 Define theme arc (e.g., Unit 1 = greetings/numbers, Unit 2 = family, ...)
- [ ] 7.2 Author Units 1-10 vocab (parallel to Phase 4 of `add-curriculum-units`, but for English)
- [ ] 7.3 Author Units 1-10 sentences
- [ ] 7.4 Tag everything with `language: 'en'` and the appropriate `unit`

## Phase 8 — Guest-mode language support

- [ ] 8.1 Guest stats split: `ro-kids-stats-ro` and `ro-kids-stats-en` localStorage keys
- [ ] 8.2 `loadGuestStats()` reads the key matching `state.language`
- [ ] 8.3 Guest's last-used language persisted to `ro-kids-last-language-guest`

## Phase 9 — Tests + smoke

- [ ] 9.1 Parse-check JS still passes
- [ ] 9.2 Manual: toggle between languages, verify stats display swaps
- [ ] 9.3 Manual: add a word in English mode, switch to Romanian, verify it's hidden
- [ ] 9.4 Manual: TTS reads English with English voice (or browser default)
- [ ] 9.5 Manual: guest mode toggle persists across reload
- [ ] 9.6 `openspec validate add-english-mode --strict` passes

## Dependencies

```
Phase 1 ──► Phase 2 ──► Phase 4 ──► Phase 9
              │            │
              ▼            ▼
           Phase 3      Phase 5
              │
              ▼
           Phase 8

Phase 6 + 7 (content authoring) — parallel, gates Phase 9 smoke
```

Order assumes `add-curriculum-units` is applied. If implemented before that change, Phase 7 is trimmed (no unit tagging) and revisited later.
