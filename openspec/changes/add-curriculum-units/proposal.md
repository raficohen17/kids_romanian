# Change: add-curriculum-units

## Why

Today the Romanian corpus is a flat 25 built-in words + 200 built-in sentences. The kid practices the whole pool at once. As she learns, the same easy words keep appearing alongside the new ones, diluting the new-word reinforcement. We need a **progression**: small batches the kid unlocks one at a time, with the previous content always available so nothing is lost.

The structure mirrors how her tutor teaches — one focused lesson per week, building on what came before.

## What Changes

- Add **10 curriculum units**, each containing **20 new words + 60 new sentences**
- **Unit 1 additionally** contains numbers 1–20 (40 effective words in Unit 1)
- **Starter Pack** (existing 25 words + 200 sentences) stays available across all units — nothing is removed or replaced
- **User-added vocab/sentences** stay available across all units — additions in the manage tab don't disappear when switching units
- **Unlock progression**: Unit 1 free; each subsequent unit unlocks at +500 points (200 points buys Unit 2, 1000 buys Unit 3, …, 4500 buys Unit 10)
- **Cumulative practice**: when the kid is "in" Unit N, the practice pool is Starter Pack + user-added + units 1 through N
- **Always go back**: the kid can re-select any previously unlocked unit (e.g., go back to Unit 2 to drill specifically)
- **Per-profile progression**: each kid profile tracks her own unit-unlock state; siblings progress independently
- **Unit selector UI**: a tab or modal showing 10 tiles (unlocked / locked with hint) plus a "current unit" indicator in the header
- **Locked units are visible but disabled** — show the unlock threshold so the kid sees the carrot

## Out of Scope (future)

- **Per-unit completion certificates / badges** — only a "max unit unlocked" state for now; achievements can come later
- **Unit themes for English mode** — handled by the `add-english-mode` proposal; this change is Romanian-only
- **Spaced repetition / SRS scheduling** — practice modes still use simple shuffle; SRS is a separate concern
- **Editing or hiding starter-pack content** per kid — starter is global, always on
- **Authoring UI for new units** — the 10 units are built into `index.html`; new units require code changes

## Impact

- **Built-in content**: 200 new words + 600 new sentences + numbers 1–20 added to `index.html` constants. Significant size growth (~1500 LOC for content arrays alone), but no new runtime dependencies.
- **Schema**: `progress` table gains a column for `max_unlocked_unit`. Existing `score` column doubles as the gating signal.
- **Data layer**: vocab/sentence constants gain a `unit` field (1–10 for new content, `null` for Starter Pack and user-added).
- **`index.html`**: filter functions in practice modes route through a unit-aware selector. UI adds a unit picker and a header indicator.
- **Spec**: new capability `curriculum-units`; `family-dictionary` capability gets a small MODIFIED Requirement to scope filtering by unit.
- **Migration**: existing profiles get `max_unlocked_unit = 1` (everyone starts at Unit 1, can practice what they had before via Starter Pack).
- **Estimated effort**: ~2–3 hours for the system; **content generation (the 200 words + 600 sentences) is the dominant cost** and likely needs an AI-assist pass with manual review.
