# Change: declutter-app-shell

## Why

The top of every screen now shows **~17 always-visible interactive elements**:

- Auth bar: language pill, speed pill, unit pill, profile chip, switch button, sign-out button.
- Modes bar: 7 practice modes + 4 non-practice modes (units, guide, manage, user) + admin `requests` when applicable.

The bar wraps to two lines on iPad and competes with the actual practice content. Daily-use modes (Flashcards, Stories, Chat) get the same visual weight as tools that the kid touches once a week (Guide, Manage, User).

Goal: keep one-tap access to daily-practice modes; collapse settings + rarely-used modes behind small surfaces so the practice card is the focal point.

## What Changes

### Modes bar

- Practice modes stay in the bar, **icon-only** (label moves to `title`/`aria-label`):
  - 🎴 Flashcards, 🎯 Quiz, 🔊 Listen, 🧩 Match, 🗣️ Sentences, 📕 Stories, 💬 Chat (auth-only).
- A new `⋯` button at the end opens a small dropdown holding the secondary modes:
  - 📚 יחידות, 📖 הגייה, 📝 הוסיפי, 👤 שלי, and (admin-only) 📥 בקשות.
- The active practice mode is indicated by an **accent fill**, not by changing color per mode.
- Tap targets are >= 44×44px; on touch devices the buttons grow slightly.

### Auth bar

- Replace the four separate pills + two buttons with **one profile chip**:
  - Format: `🌟 <name> · 🇷🇴 · יחידה 3`
  - Tapping the chip opens a small popover with:
    - Language toggle (🇷🇴 / 🇬🇧)
    - Speech speed selector (`×1 / ×0.9 / ×0.75 / ×0.5`)
    - "Open units" shortcut (deep-links to the יחידות mode)
    - 🔄 Switch profile
    - 🚪 Sign out
- Guest mode shows a simpler chip: a single `🔓 כניסה` button (no popover).

### Behaviour preserved

- All existing modes still reachable.
- Language switching still resets shuffles and reloads per-language progress.
- Speed setting still persists in `localStorage`.
- Profile switching still re-fetches family data and clears chat.
- Admin sees the 📥 בקשות entry in the ⋯ menu, with the existing red dot when there are pending requests.

## Out of Scope (follow-ups)

- **Visual palette / typography refresh.** That's a separate proposal (`refresh-visual-system`) so it can ship independently.
- **Mode-specific button cleanup** (e.g., Stories' prev/play/next/shuffle/per-sentence-🔊 cluster). Could be a third pass after the shell calms down.
- **Mobile-only breakpoints.** Layout adjusts naturally with flexbox; no per-device branching.
- **Hiding modes per-profile or per-role** beyond the existing admin/auth gates.
- **Configurable "favorite modes"** — order is fixed in code.

## Impact

- **Modified**: `index.html` — `.modes` HTML reordered; new `.modes-more` dropdown component (CSS + tiny JS); new `.profile-chip` + `.profile-popover` components; existing `lang-pill`, `speed-pill`, `unit-pill` removed and their wiring moved into the popover; `applyModeVisibility()` updates the ⋯ menu instead of toggling individual buttons.
- **Modified**: `applyModeVisibility()` logic — adds/removes the admin entry inside the dropdown rather than appending a new button to the bar.
- **No data, auth, or backend changes.** Pure UI shell refactor.
- **No new dependencies.**
