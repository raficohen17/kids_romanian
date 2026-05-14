# Change: declutter-app-shell

## Why

The first pass collapsed the auth bar into a profile chip and the secondary modes into a `⋯` menu. Two regressions remain:

1. **Discoverability collapsed.** Practice tabs went icon-only with `title` + `aria-label` for the label. On the iPad — the kid's primary device — there is no hover, so the labels are effectively invisible. The kid sees 7 emojis and so does the tutor. The `⋯` menu has the same problem: three dots tell you nothing.
2. **The real clutter is still on screen.** The category filter row renders ~26 chips beneath the modes bar (numbers, pronouns, school, weather, body, time, …). Only 5 categories are mapped to emoji; the rest fall back to a generic `🏷️` tag, producing a wall of identical-looking chips that wraps to 4-5 rows on iPad. That wall is what makes the page feel cluttered after the first decluttering pass.

Goal of this revision: every primary control is **identifiable without hover**, and the category list stops dominating the screen by default.

## What Changes

### Modes bar — pill tabs, not icon-only

- Practice tabs become **pill-shaped buttons with emoji + Hebrew label** (e.g. `🎴 כרטיסיות`). Label visible at all times on tablet/desktop. Below `560px` viewport width the label hides via CSS only as a last resort.
- Active tab fills with `--accent` and white text. Inactive tabs are white with a 1.5px `--line` border.
- The `⋯` menu trigger becomes **`☰ עוד`** (icon + Hebrew word) so it reads as a menu, not a debug dot.
- Tap targets stay >= 44px tall. Tabs are `padding: 10px 14px`, `border-radius: 999px` — comfortable on touch.

### Category filter — collapsed into a single popover

- The 26-chip row goes away. By default the screen shows **no category chips** — the practice card and stats stand alone.
- A single **`🌈 קטגוריה: הכול ▾`** trigger sits where the chip row used to be. Tapping it opens a `.shell-popover` listing every category as a row (emoji + name + count of words).
- Selecting a category sets `state.category` and closes the popover. The trigger text updates to show the active filter, e.g. `🎨 קטגוריה: צבעים ▾`.
- The popover is reachable only on modes that use category filtering (flashcards, quiz, listen, match, stories) — already the existing visibility rule for `#filters`.

### Every category has an emoji — no `🏷️` fallback

- `BUILTIN_CAT_EMOJI` expanded from 5 entries to **every category that exists in the built-in vocab** (RO + EN). Falling back to the generic tag is what created the visual sameness; killing it removes the clutter even where categories are shown (the popover row, the guide page).
- If a user adds a custom category through Manage, it falls back to the **current unit's emoji** rather than `🏷️`. Still distinctive, never the generic tag.

### Profile chip — keep, but quieter

- The chip already exists and works. Two small polishes:
  - Drop the speed indicator from the chip face (it's not glanceable; the popover row is enough).
  - Chip face becomes `<emoji> <name> · <flag> · יחידה N` — three pieces of information, not four. Less to read.
- Guest chip stays as `<flag> · יחידה N` + sign-in button.

### Behaviour preserved

- All existing modes still reachable.
- Language switching still resets shuffles and reloads per-language progress.
- Speed setting still persists in `localStorage` and is still set from the profile popover.
- Profile switching still re-fetches family data and clears chat.
- Admin sees the 📥 בקשות entry in `☰ עוד`, with the existing red dot when there are pending requests.

## Out of Scope (follow-ups)

- **Per-mode brand color**. Active state stays single-accent.
- **Sticky-on-scroll modes bar**. The page is short; not needed.
- **Configurable favorite modes / favorite categories**. Order is fixed in code.
- **Category counts updating live as Manage adds custom words.** Counts recompute on each filter open; that's enough.

## Impact

- **Modified**: `index.html` — `.mode-tab` and `.mode-more` restyled to pill shape with labels; `.filter-row` → single `.category-trigger` button + reuse of `.shell-popover`; `renderFilters()` swapped from chip-row builder to trigger builder + popover refresher; `BUILTIN_CAT_EMOJI` table extended to cover every category in the corpus; `getCategoryEmoji()` falls back to current-unit emoji, not `🏷️`.
- **No data, auth, or backend changes.**
- **No new dependencies.**
