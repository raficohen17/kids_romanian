# Design: improve-english-niqqud-coverage

## Context

The English curriculum was added in `add-english-mode` with 225 vocab + 1,662 pron fields across 800+ sentences (sentence-level + per-word breakdowns). All flashcards and sentence cards render the Hebrew `pron` field directly to the child — that text IS the pronunciation hint, since browser TTS doesn't always fire and isn't reliable in noisy environments.

After the `feat/english-niqqud` branch:

- `VOCAB_EN` (225/225): fully niqqud-bearing. Manually authored.
- `BUILTIN_SENTENCES_EN` (950/1,662 pron fields ≈ 57%): partially niqqud-bearing from two Python substring-replacement passes (`/tmp/add_niqqud.py` v1+v2).
- Remaining ~700 pron fields: bare Hebrew letters (e.g., `pron:"אנד"` instead of `pron:"אֶנְד"`).
- Known chain-replacement regressions where a short pattern matched mid-word and corrupted longer transliterations (e.g., `"איי"` → `"אַי"` cascading into `"נאיין"` → `"נאַין"`).

The goal: bring sentence pron quality to the same bar as vocab pron and lock that bar in with a lint check.

## Goals / Non-Goals

**Goals**
- 100% of `pron:"..."` fields in `VOCAB_EN` and `BUILTIN_SENTENCES_EN` contain at least one Hebrew niqqud diacritic.
- Same English word produces the same Hebrew niqqud transliteration everywhere (vocab + sentence-level + per-word breakdown).
- A simple `node scripts/check_pron.js` lints the file and fails on bare-Hebrew pron — runnable locally and from Vercel's build hook if we choose to wire it later.
- Chain-replacement regressions fixed.

**Non-Goals**
- No native-speaker audio recordings.
- No IPA, no other target languages.
- No changes to Romanian content — already at the desired quality bar.
- No restructuring of the `BUILTIN_SENTENCES_EN` schema. Pure content edits.
- Not wiring the lint into Vercel/CI yet — just the script. Wiring can follow once it's green.

## Decisions

### Decision 1: A canonical EN_PRON_DICT lookup, not freeform editing

A small JS constant in `index.html` (or a sibling `en_pron_dict.js`) maps the ~80 most-common English words used in sentences to their canonical Hebrew niqqud spelling. The dict is the source of truth.

**Rationale.** The bug we're fixing was caused by ad-hoc substring replacement applied in an unsafe order. Centralizing the spellings in a dict means: (a) a single place to change a spelling project-wide, (b) the lint can compare actual pron values against canonical ones and warn on drift, (c) authoring new content gets faster.

**Alternative considered.** Just hand-edit the remaining ~700 fields. Faster short-term, but offers no defense against the next contributor (or me) reintroducing the same spelling drift.

### Decision 2: Lint script is plain Node, no dependencies

`scripts/check_pron.js` reads `index.html` as text, walks both `VOCAB_EN` and `BUILTIN_SENTENCES_EN` blocks by locating their `const … = [` start and matching `\n];` end (same approach used by `/tmp/add_niqqud.py`), and applies a single regex per `pron:"..."` field.

Niqqud detection regex: `/[ְ-ׇּׁׂ]/` (Hebrew points/diacritics block, excluding cantillation marks).

A pron is an "offender" if it:
- Contains at least one Hebrew letter (`/[א-ת]/`)
- AND contains zero niqqud codepoints from the regex above

Exits 1 with a count + first 10 offenders printed; exits 0 with `All N pron values look niqqud-bearing.` on success.

**Rationale.** Zero deps means it runs from a fresh `git clone` with just Node. Two-line invocation in any CI we add later.

### Decision 3: Fix chain-regressions with a corrective table, then commit the lint as gatekeeper

The repair is a small manual replace-table (mirroring `/tmp/add_niqqud.py`) but applied AFTER the bare→niqqud sweep, and explicitly targeting known regressions:

```
"נאַין" → "נַאיין"   (nine)
"איי " → (leave alone — already shortened to "אַי" where standalone)
"באַי " → "בָּאי "   (bye, when followed by space)
…
```

Then add the lint and commit it green. Future regressions are caught at lint time.

**Rationale.** A second mass-replace is the cheapest way to fix what the first one broke; the lint is the durable safeguard. Trying to write a "smart" tokenizer for Hebrew transliterations is out of proportion to the value (1,662 entries, single language, single audience).

### Decision 4: Lint runs from `npm run lint:pron`, not on every Vercel deploy (yet)

Add a `package.json` script entry. Don't wire it into Vercel's build command until the script has been green for a few iterations and we're sure it doesn't false-positive (e.g., on Romanian-origin entries that legitimately have no niqqud because the English version is a name like "USA").

**Rationale.** Don't break deploys while authoring. Earn the gating.

## Risks / Trade-offs

- **Risk: Hebrew word boundary detection is imprecise.** Substring replacement inside `pron:"..."` can still cascade. Mitigation: keep the corrective-pass replacements tightly anchored (include trailing punctuation/space/quote where possible), and run the lint after each change.
- **Risk: Lint false-positives on legit no-niqqud strings** (names, abbreviations). Mitigation: maintain an `EXEMPT` whitelist constant inside the lint script (initial list: empty; add as needed).
- **Trade-off: Authoring time vs. quality.** Hand-tuning ~700 entries is tedious. Mitigation: most are repetitions of common words covered by `EN_PRON_DICT`, so a final sweep using the dict as a replace-table should knock out the bulk. Manual review is for the long tail.

## Migration Plan

Not applicable — pure content quality work. No schema migration, no data migration, no Supabase touches. Users who already have personal vocab/sentences in their family scope are unaffected.

## Open Questions

- Should the lint also enforce the canonical spelling from `EN_PRON_DICT` (warn on drift), or only "at least some niqqud present"? **Tentative answer**: start with "any niqqud" gate, add canonical-spelling warning in a follow-up if drift becomes a real problem.
- Should we extract `EN_PRON_DICT` into a separate file for reuse? **Tentative answer**: keep inline in `index.html` for now. Single-file architecture is a project principle (no build step).
