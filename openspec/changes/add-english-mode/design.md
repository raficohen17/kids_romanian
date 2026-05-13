# Design: add-english-mode

## Context

The Romanian app is built around a single target language baked into TTS, the built-in corpus, and the practice copy. Adding English means making the "target language" a parameter rather than an assumption. The kid is still Hebrew-native; only the language she's learning toggles.

## Decisions

### Decision 1: Language is a single dimension, scoped per profile

**Choice.** Add a single string column `language` (values: `'ro'` or `'en'`) to `vocab`, `sentences`, and `progress`. Profile state in JS adds `state.language`. Switching the toggle changes that state and reloads the data.

**Alternative considered**: nest a `languages` table with rich metadata. Rejected — overkill for 2 languages with similar structure.

### Decision 2: Independent curriculum, not translations

**Choice.** English Unit 1 ≠ Romanian Unit 1. Each language gets a curriculum that makes sense for a Hebrew speaker learning THAT language, not a 1-to-1 word-for-word mapping.

**Rationale**:
- Hebrew→Romanian and Hebrew→English have different "first 200 words" — verb conjugations, common loanwords, alphabet challenges all differ.
- Pinning English to a Romanian template would force awkward unit themes.
- The kid is learning two language systems, not the same words twice.

**Alternative considered**: auto-translate the Romanian corpus to English. Rejected because Romanian-pedagogy ordering won't match how English is typically introduced.

### Decision 3: Hebrew (L1) is hardcoded

**Choice.** UI strings, button labels, pronunciation guide explanations stay Hebrew. Only L2 (target) toggles.

**Rationale**: the user is one specific family; Hebrew-as-L1 is a safe assumption for this app's life. Supporting multiple L1s is a wholly different project (i18n stack, RTL/LTR for some L1s, localized pronunciation conventions per L1, …).

### Decision 4: Per-(profile, language) progress

**Choice.** `progress.profile_id` is no longer unique. The primary key becomes `(profile_id, language)`. Maya can have one progress row for Romanian (`('maya', 'ro')`) and one for English (`('maya', 'en')`), with independent score/streak/unit-unlocks.

**Migration**: existing rows get `language = 'ro'`. The PK changes from `profile_id` to `(profile_id, language)` — a small but careful SQL migration.

#### Why not store both in one row?

A wide row `progress(profile_id, ro_score, ro_streak, en_score, en_streak, ...)` would be smaller in the DB but harder to extend (adding a third language = schema change). Composite-key is the right shape.

### Decision 5: Per-language family vocab and sentences

**Choice.** `vocab.language` and `sentences.language`. RLS still scopes by `family_id`. Practice modes filter by `(family_id, language)` for user-added rows, plus the built-in corpus tagged with the matching language.

**Alternative considered**: a single global vocab pool, with each row tagged. Same shape effectively; the only call to make is whether to enforce "language is required" in the schema. We default to `'ro'` for backward-compat.

### Decision 6: TTS lang switches with state

**Choice.** `speak()` reads `state.language` and picks `'ro-RO'` or `'en-US'`. The browser falls back to whatever voice is installed for that locale.

**Edge case**: a kid on a system that doesn't have an `en-US` voice gets silence or a default voice. Acceptable; she can read the transliteration. We don't ship our own TTS audio files.

### Decision 7: Header pill for the toggle

**Choice.** The auth bar grows a third pill: language flag + name. Click → toggle modal:

```
┌─────────────────────────────┐
│  שפת הלימוד                 │
│                             │
│   🇷🇴 רומנית   🇬🇧 אנגלית   │
│   (active)                  │
└─────────────────────────────┘
```

Tapping a flag updates `state.language`, reloads progress for that language, swaps the built-in corpus reference, and re-renders.

**Alternative considered**: a tab-bar mode. Rejected — too much real estate for a binary choice that doesn't change practice mode.

### Decision 8: Language switching is fast and lossless

**Choice.** When the kid flips from Romanian to English, no save is needed (progress is auto-debounced). The English progress row loads from Supabase (or initializes if first time). She's switched in <500ms.

**Score / streak display**: updates immediately to reflect English. Her Romanian score didn't disappear; she'll see it again when she flips back.

### Decision 9: Default language is Romanian for existing profiles

**Choice.** Migration: every existing profile's session starts in `'ro'`. The toggle is opt-in for English. New profiles also default to Romanian (until/unless we add a profile-creation step that asks).

### Decision 10: Guest mode supports both languages

**Choice.** Even unauthed guests can flip the toggle. The English Starter Pack (~25 words) is built into `index.html`, parallel to the Romanian one. Score/streak in localStorage gets a language suffix: `ro-kids-stats-ro`, `ro-kids-stats-en`.

## Data Model Changes

```
vocab
  ... existing columns ...
  language     text not null default 'ro' check (language in ('ro','en'))   ← NEW

sentences
  ... existing columns ...
  language     text not null default 'ro' check (language in ('ro','en'))   ← NEW

progress
  profile_id   uuid not null references profiles(id) on delete cascade
  language     text not null default 'ro' check (language in ('ro','en'))   ← NEW
  score        int default 0
  best_streak  int default 0
  seen         int default 0
  max_unlocked_unit int default 1                                          (added by add-curriculum-units)
  updated_at   timestamptz default now()
  primary key (profile_id, language)                                       ← CHANGED from profile_id alone
```

Built-in constants in `index.html`:

```js
const VOCAB_RO = [...];        // existing 25 starter
const SENTENCES_RO = [...];    // existing 200
const VOCAB_EN = [...];        // new ~25 starter
const SENTENCES_EN = [...];    // new ~200

const UNITS_RO = [...];        // 10 Romanian units (from add-curriculum-units)
const UNITS_EN = [...];        // 10 English units (this change)

function getVocab() {
  return state.language === 'en' ? VOCAB_EN.concat(userVocab) : VOCAB_RO.concat(userVocab);
}
```

## RLS

RLS does not need to change — `family_id` scope handles security. The `language` column is just a filter applied client-side and in SELECTs. No new policy required.

## Migration

```sql
-- 1. Add language columns to vocab and sentences
alter table public.vocab     add column language text not null default 'ro';
alter table public.sentences add column language text not null default 'ro';
alter table public.vocab     add constraint vocab_lang_check     check (language in ('ro','en'));
alter table public.sentences add constraint sentences_lang_check check (language in ('ro','en'));

-- 2. Migrate progress to composite key
alter table public.progress add column language text not null default 'ro';
alter table public.progress add constraint progress_lang_check check (language in ('ro','en'));
alter table public.progress drop constraint progress_pkey;
alter table public.progress add primary key (profile_id, language);
```

Steps 1 and 2 are idempotent — re-running is safe (the `default 'ro'` covers existing rows; the PK swap fails noisily if already done, which is a feature).

## UX Flow

```
[Sign in, pick profile] → ROMANIAN by default
                              │
                              ▼
                      ┌───────────────────┐
                      │ Header pill:      │
                      │ 🇷🇴 רומנית        │  ← tap to toggle
                      └─────────┬─────────┘
                                │ tap
                                ▼
                      ┌───────────────────┐
                      │ language picker   │
                      │ 🇷🇴   🇬🇧         │
                      └────────┬──────────┘
                               │ pick English
                               ▼
                  - state.language = 'en'
                  - loadFamilyData() refetches for 'en'
                  - state.score/streak/seen reset to
                    the English progress row (or zeros)
                  - state.currentUnit defaults from English's
                    max_unlocked_unit
                  - built-in corpus references EN constants
                  - speak() uses 'en-US' lang code
                  - re-render
```

## Trade-offs

| Trade-off | Resolution |
|---|---|
| English curriculum is more content to author | Same scale as Romanian; AI-assist + review. Punt to phased rollout: ship the system with a minimal English starter pack, fill in units over time. |
| Composite PK migration on `progress` is mildly fragile | Tested locally; one-shot SQL with idempotency. Documented in tasks.md. |
| Browsers without `en-US` voice fall back silently | Acceptable — same fallback story as `ro-RO`. The transliteration column is always shown. |
| Toggle in header adds visual weight | Two pills (profile + language) is still manageable. Could collapse to a dropdown later. |
| Family dictionary doesn't auto-mirror | If a parent adds "חתול = Pisică" in Romanian, English mode won't auto-get "חתול = Cat". Acceptable: families adding their own vocab usually know which language they're targeting. Manual add per language. |
