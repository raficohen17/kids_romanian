# Change: improve-english-niqqud-coverage

## Why

The English curriculum (introduced by `add-english-mode`) ships with Hebrew transliterations in the `pron` field of every vocab and sentence entry — but coverage and quality are uneven. After branch `feat/english-niqqud`:

- **VOCAB_EN** (225 flashcard entries): 100% covered with proper niqqud.
- **BUILTIN_SENTENCES_EN** (1,662 pron fields total, sentence-level + word-breakdown): ~57% covered (950 fields touched by the mass-replace pass).
- **The remaining ~700 fields** are bare Hebrew letters with no diacritics — hard for a 9-year-old to read out loud, especially when text-to-speech doesn't fire.
- **A handful of chain-replacement regressions** exist (e.g., "נאיין" → "נאַין" instead of "נַאיין") because substring replacements cascaded in unintended orders.

The Romanian content uses careful niqqud throughout (e.g., "בּוּנָה", "מָה קְיָאמָה") and that quality bar is what the English content should match.

## What Changes

- **Complete pron coverage**: every `pron:"..."` field in `BUILTIN_SENTENCES_EN` SHALL have Hebrew niqqud where the transliterated English word has a phonetic mapping.
- **Repair chain-regressions** from the v1/v2 mass-replace passes (the "נאיין" / "ריט" / "אַי-versus-אַיי" cases).
- **Consistent transliteration style** across vocab and sentences — same English word always produces the same niqqud spelling. The agreed style:
  - `/æ/` (cat) → אֶ or אֵ (e.g., "Cat" = "קֶט")
  - `/i:/` (see) → אִי
  - `/aɪ/` (I) → אַי or אַיי (preserve double yod inside multi-letter words)
  - `/eɪ/` (say) → אֵיי
  - `/ʌ/` (cup) → אָ
  - `/ʊ/` (look) → וּ
  - `/u:/` (boot) → וּ
  - `/o/` (go) → וֹאוּ
  - schwa → ֶ
- **Source-of-truth lookup**: introduce a small `EN_PRON_DICT` constant (English word → canonical Hebrew niqqud transliteration) used by both the script and any new content authoring. Reduces drift.
- **Lint check**: add a tiny build-time script (`scripts/check_pron.js` or a node one-liner) that:
  - Greps `BUILTIN_SENTENCES_EN` and `VOCAB_EN` for `pron:"..."` lacking niqqud diacritics (no `ַ ֶ ִ ֵ ֹ ֻ ְ ָ ּ`).
  - Reports the count and first 10 offenders.
  - Exits non-zero if any are found — so future content additions can't regress.

## Out of Scope (future)

- **Native-speaker audio recordings** to replace browser TTS. Niqqud is the textual aid for the kid; replacing TTS is a much larger product change.
- **Other target languages** (German, Spanish, etc.). This is English-only.
- **Right-to-left phonetic alphabets** (e.g., IPA in Hebrew text). Plain Hebrew niqqud is enough for a 9-year-old.
- **Rewriting Romanian pron** — Romanian content is already at the desired quality.

## Impact

- **Modified**: `index.html` — only the `pron` field values inside `BUILTIN_SENTENCES_EN` and (if needed) `VOCAB_EN`. No structural/code changes.
- **New**: `scripts/check_pron.js` (or `make pron-check`) — a lint that fails the build if bare-Hebrew pron sneaks in.
- **No schema/auth/Supabase impact** — this is pure content-quality work.
- **Estimated effort**: ~2–3 hours of authoring + lint setup; the linter is the durable defense against regression.
