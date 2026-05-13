# english-mode Specification Delta

## ADDED Requirements

### Requirement: Every English pron field has Hebrew niqqud

Every English vocab entry (`VOCAB_EN`) and every English sentence entry (`BUILTIN_SENTENCES_EN`) — including the sentence-level `pron` AND each entry in the sentence's `words` breakdown — SHALL contain Hebrew niqqud (one or more of the diacritic codepoints: patah ַ, segol ֶ, hiriq ִ, tsere ֵ, holam וֹ, qubuts ֻ, shewa ְ, qamatz ָ, dagesh ּ) where the underlying English word has a phonetic mapping.

Exceptions: prons where every Hebrew character is a vowel letter already (e.g., "יוּ" for "you", "סִי" for "see") are considered already-niqqud-bearing as long as one diacritic is present.

#### Scenario: Every vocab entry has niqqud

- **WHEN** `VOCAB_EN` is iterated
- **THEN** every entry's `pron` value contains at least one niqqud diacritic codepoint

#### Scenario: Every sentence-level pron has niqqud

- **WHEN** `BUILTIN_SENTENCES_EN` is iterated
- **THEN** every entry's `pron` value contains at least one niqqud diacritic codepoint

#### Scenario: Every word-breakdown pron has niqqud

- **WHEN** `BUILTIN_SENTENCES_EN[i].words` is iterated for any sentence
- **THEN** every word entry's `pron` value contains at least one niqqud diacritic codepoint

### Requirement: Build-time lint catches bare-Hebrew pron

The repository SHALL include a script (e.g., `scripts/check_pron.js`) that:

- Scans `index.html` for `pron:"..."` strings inside the `VOCAB_EN` and `BUILTIN_SENTENCES_EN` arrays.
- Flags any pron value that contains Hebrew characters but no niqqud diacritic codepoint.
- Prints a summary: total entries, count of offenders, first ~10 offenders with surrounding context.
- Exits with a non-zero status when offenders are found.

The script SHALL be runnable as a single command (`node scripts/check_pron.js`) with no dependencies beyond Node's standard library.

#### Scenario: Lint passes when all pron have niqqud

- **WHEN** all pron values contain niqqud
- **AND** `node scripts/check_pron.js` is run
- **THEN** the exit code is 0
- **AND** stdout reports "All N pron values look niqqud-bearing."

#### Scenario: Lint fails on a regressed pron

- **WHEN** a contributor adds a new entry with `pron:"הלו"` (no niqqud)
- **AND** `node scripts/check_pron.js` is run
- **THEN** the exit code is non-zero
- **AND** stderr lists the offending entry's context

### Requirement: Consistent transliteration of common English words

Common English words used across multiple sentences SHALL use the same Hebrew niqqud spelling everywhere they appear. Specifically:

- "Hello" → "הֶלוֹ"
- "Bye" → "בָּאי"
- "Thank you" → "ת'ֶנְק יוּ"
- "Please" → "פְּלִיז"
- "I" → "אַי"
- "You" → "יוּ"
- "Cat" → "קֶט"
- "Dog" → "דוֹג"
- "Big" → "בִּיג"
- "Small" → "סְמוֹל"
- Numbers 1–20 → fixed niqqud spellings established in `VOCAB_EN`

A small `EN_PRON_DICT` constant in `index.html` (or a separate JSON imported into the build/lint script) SHALL hold the canonical list. The lint MAY warn (not fail) if a pron deviates from the canonical spelling.

#### Scenario: Same word, same spelling everywhere

- **WHEN** the word "Cat" appears in any `pron` field across vocab + sentences
- **THEN** its Hebrew transliteration is "קֶט" in every occurrence

### Requirement: Repair chain-regressions

Specific transliterations that were corrupted by the substring-replacement script SHALL be corrected:

- "נאַין" / "נאַין" (current, mis-shortened) → "נַאיין" for "nine"
- "פַאיין" (current) → "פַאיין" if "fine" is intended; otherwise pick a single spelling and apply throughout
- "אַי" (when standing for "I") should NOT appear in the middle of multi-letter English words like "nine" — its presence there is a sign of chained substitution

Implementation MAY do this as a final corrective replace-pass or as a manual review per affected entry; either way, the lint requirement above MUST pass after the fix.

#### Scenario: "Nine" is consistently spelled

- **WHEN** `pron` fields containing "nine" or its sentence usages are inspected
- **THEN** the niqqud spelling is "נַאיין" everywhere
- **AND** no instances of "נאַין" remain

