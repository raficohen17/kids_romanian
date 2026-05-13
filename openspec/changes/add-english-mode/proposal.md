# Change: add-english-mode

## Why

The kid is Hebrew-native and learning Romanian. The same app shape — 10 curriculum units, practice modes, family-shared dictionary, per-profile progress — works just as well for learning English. Adding an English mode multiplies the app's utility without rebuilding the engine. For families that learn both languages, it's the same household pattern at zero new infrastructure cost.

## What Changes

- Add a **language toggle** in the auth/header area: `🇷🇴 רומנית / 🇬🇧 אנגלית`
- Each profile tracks **independent state per language**: score, streak, seen, current unit, max_unlocked_unit are scoped to (profile, language)
- **Per-language family dictionary**: vocab and sentences gain a `language` column; user-added Romanian words don't appear in English mode, and vice versa
- **Independent English curriculum**: 10 English units, each 20 new words + 60 new sentences. NOT translations of the Romanian curriculum — built around what makes sense for a Hebrew-speaking kid learning English (different basics, e.g., "the", "a/an", common pronouns appear early)
- **English Starter Pack**: a small parallel pack (~25 words + ~200 sentences) so guests / pre-unit-1 kids have something to play with
- **TTS swap**: `SpeechSynthesis` lang switches from `ro-RO` to `en-US` (or `en-GB`) based on selected language
- **Hebrew UI stays Hebrew**: the kid still reads buttons, instructions, and pronunciation guides in Hebrew. Only the target language (L2) changes.
- **Progress visibly switches**: when the kid flips the toggle, the score/streak in the stats panel reflects her English progress, not Romanian
- **PIN, profiles, families** unchanged — the language is a per-session view, not a separate identity

## Out of Scope (future)

- **Auto-translation between modes** — adding the same concept in both pools is manual (or via bulk import per language)
- **Mixed-language sentences** — every sentence is in one target language
- **Voice selection UX** — uses browser default `en-US`/`ro-RO`; no per-user voice picker
- **L1 ≠ Hebrew** — Hebrew is hardcoded as the source language; supporting English-speakers learning Romanian (etc.) is a separate change
- **Cross-language analytics** — no "you've learned X words across all languages" stats; each language is its own world

## Impact

- **Built-in content**: 200+ new English words and 600+ new English sentences in `index.html` (parallel to Romanian content). Plus an English Starter Pack (~25 / ~200).
- **Schema**: `vocab`, `sentences`, and `progress` get a `language` text column (default `'ro'`). New composite uniqueness: progress is keyed on `(profile_id, language)` instead of just `profile_id`.
- **`index.html`**: state and data layer become language-aware. `state.language` drives which built-in corpus is in scope, which language code TTS uses, and which `progress` row is loaded.
- **Migration**: existing `progress` rows get `language = 'ro'`. Existing vocab/sentences likewise.
- **Spec**: new capability `english-mode`; `family-dictionary`, `families`, and `curriculum-units` capabilities all get small MODIFIED Requirements to scope their data by language.
- **Estimated effort**: ~4 hours system wiring; **content authoring (the English curriculum) is the dominant cost** — same content-generation challenge as the Romanian curriculum.

## Relationship to `add-curriculum-units`

This proposal **assumes curriculum-units is applied first** (it borrows the unit model). If applied first, English has its own 10 units; if applied without curriculum-units, English would still work but as a flat corpus.

The cleanest sequence is: **apply curriculum-units → apply english-mode**. The English proposal's spec deltas assume units exist.

If implemented in the other order, the English deltas should be trimmed (no unit fields) and revisited after units land.
