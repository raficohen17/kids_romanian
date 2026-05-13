# Design: add-curriculum-units

## Context

The current app exposes all built-in content at once. As the kid's vocabulary grows, the new words she's trying to internalize get crowded out by the basics she already knows — every quiz pulls from the full pool with equal probability. Her tutor's lessons are paced: a small batch of focused content per week. The app should mirror that.

## Decisions

### Decision 1: 10 units × 20 words × 60 sentences

**Choice.** Each unit holds exactly 20 new words and 60 new sentences. Total = 200 new words + 600 new sentences across all units.

**Rationale**: 20 words is what a strong week of tutoring covers; 60 sentences (3 per word average) is enough to surface the word in varied contexts without being overwhelming. 10 units gives ~10 weeks of structured content — past that, she'll have moved on or we'll add more.

### Decision 2: Starter Pack stays parallel, not absorbed

**Choice.** The existing 25 words + 200 sentences remain a "Starter Pack" — always available, never gated. They have `unit = null` (or `unit = 0` if a non-null value is needed).

**Alternative considered**: distribute the existing 25 into thematically-matching new units (greetings → Unit 1, colors → Unit 3, etc.). Rejected because:
- The 25 are already familiar to the kid; folding them into Unit 1 means she "unlocks" content she already knows
- The 200 existing sentences are tightly intertwined with the 25 words; splitting them by theme is fragile
- Parallel keeps the migration trivial — `unit = null` for legacy rows, no data juggling

**Trade-off**: Practice pool is slightly larger than strictly necessary (Starter Pack always included). Acceptable; the volume is small and overlap is desirable for retention.

### Decision 3: Unit 1 includes numbers 1–20

**Choice.** Unit 1 effectively has 40 words: its 20 thematic words PLUS numbers 1 through 20 as a distinct sub-batch.

**Rationale**: numbers are foundational — the kid will say her age, count, etc. very early. Tutors typically introduce them in the first lesson. Embedding in Unit 1 ensures they're practiced from the start without inflating other units.

**Implementation**: numbers live in the same vocab array, all tagged `unit = 1`, with `cat = 'מספרים'` so the existing category chip filtering still works. The "Unit 1 has 40 words" is internal; from the kid's view it's just "the first unit teaches you basics."

### Decision 4: Unlock at +500 points per unit, linear

**Choice.** Unit N unlocks when `score >= 500 * (N - 1)`. So:

| Unit | Threshold |
|---|---|
| 1 | 0 |
| 2 | 500 |
| 3 | 1000 |
| 4 | 1500 |
| 5 | 2000 |
| 6 | 2500 |
| 7 | 3000 |
| 8 | 3500 |
| 9 | 4000 |
| 10 | 4500 |

**Rationale**: Each correct answer = 10 points (existing scoring). 500 points = 50 correct answers = a comfortable session. Linear ramping means each unit feels equivalently earned — no surprise difficulty cliffs.

**Tunability**: the threshold table lives as a constant. We can adjust without schema changes.

**Alternative considered**: scaling thresholds (e.g., 500, 1000, 2000, 4000, …). Rejected: makes later units feel like a slog. Linear keeps motivation flat.

### Decision 5: Cumulative practice pool

**Choice.** When the kid is "in" Unit N, the practice pool for flashcards/quiz/match/listen/sentences is:

`Starter Pack ∪ user-added ∪ units 1 through N`

So Unit 5 practice includes Unit 1's animals plus Unit 5's whatever-new-content.

**Rationale**: prevents forgetting. The kid stays fluent in earlier material while learning new.

**Alternative considered**: "current unit only" mode for focused drilling. Punted to a future toggle — for now, cumulative is the only mode. If the kid wants to focus, she can flip the category filter or pick an earlier unit (which makes her pool smaller).

### Decision 6: Per-profile unit progression

**Choice.** `progress` table grows a `max_unlocked_unit` int column (default 1). Each kid tracks her own progression.

**Auto-advance**: whenever `score` crosses a threshold during practice, the app calculates the new max and updates the column. The kid sees a small celebration ("🎉 Unit N נפתחה!") and the unit selector refreshes.

**Manual revisit**: the unit selector shows all unlocked units; she clicks any to switch the "current unit" context.

### Decision 7: Unit metadata is code, not data

**Choice.** Unit definitions live in `index.html` as a constant:

```js
const UNITS = [
  { n: 1, name: "ברכות ומספרים", emoji: "👋", threshold: 0 },
  { n: 2, name: "...", emoji: "...", threshold: 500 },
  ...
];
```

Vocab and sentences reference units via the `unit` field on each row.

**Rationale**: 10 units, slow change rate, no admin UI for editing units. Keeping them in code = simpler than introducing a `units` table.

**Trade-off**: changing a unit's threshold or name requires a code change + redeploy. Acceptable for now; a `units` DB table is a future migration if we add unit authoring UI.

### Decision 8: UI placement

**Choice.** Unit selector lives as a **new mode tab**: `📚 יחידות`. It shows the 10 unit tiles plus a "current" indicator. Picking a unit changes `state.currentUnit` and re-renders practice modes.

The auth header gets a small **current-unit pill** (e.g., "🎒 יחידה 3") so the kid always sees where she is.

**Rationale**: reuses the existing mode-tab pattern. No new top-level navigation concept.

## Data Model Changes

```
progress
  profile_id           uuid PK FK profiles
  score                int default 0
  best_streak          int default 0
  seen                 int default 0
  max_unlocked_unit    int default 1                ← NEW
  updated_at           timestamptz

vocab  (built-in only — DB columns unchanged, but the in-code
        const gains a `unit` field per entry; the DB column
        could optionally be added later for symmetry)
  ... existing columns ...
  unit                 int nullable                  ← NEW (server side optional)

sentences  (mirror)
  ... existing columns ...
  unit                 int nullable                  ← NEW
```

For the built-in (in-code) content, every entry tags its unit:

```js
// existing starter-pack-style entries: no `unit` field (or null)
{ he: "שלום", ro: "Bună", pron: "...", cat: "ברכות", emoji: "👋" },

// new unit-1 entries:
{ he: "אחת", ro: "Unu", pron: "אונו", cat: "מספרים", emoji: "1️⃣", unit: 1 },
```

User-added rows from the manage tab keep `unit = null` and are always in the pool.

## Practice-mode filter

The `filtered()` selector grows to:

```js
function unitFiltered() {
  const u = state.currentUnit ?? 1;
  return getVocab().filter(w =>
    w.unit == null            // Starter Pack + user-added
    || w.unit <= u            // current and previous units
  );
}
```

Existing category-chip filtering composes on top of this — the kid can still narrow to "צבעים" inside Unit 3.

## Migration

- Existing profiles: `max_unlocked_unit = 1` (default).
- Existing built-in vocab/sentences: no migration; `unit` is added in code, defaults to `null` (Starter Pack).
- No data loss.

## Trade-offs

| Trade-off | Resolution |
|---|---|
| 200 + 600 new content entries inflate `index.html` | Acceptable — ~1500 LOC of pure data, no runtime impact. If it ever gets unwieldy, move to JSON loaded at runtime. |
| Cumulative pool gets big at Unit 10 | At Unit 10 the kid is well past beginner; 225+ words is fine for shuffle. |
| Unlock thresholds are guesses | Linear +500 is tunable per-deploy. We'll watch and adjust. |
| Unit content needs to be generated | Out of scope of this proposal; mentioned as "dominant cost" in proposal.md. AI-assist + manual curation. |
