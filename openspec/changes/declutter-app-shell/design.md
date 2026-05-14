# Design: declutter-app-shell

## Context

First decluttering pass shipped: auth bar collapsed to a profile chip, secondary modes hid in `⋯`. The kid and tutor pushed back on two things:

- **The labels are gone.** On iPad there is no hover, so `title` is dead. The practice row reads as seven decorative emojis. A 9-year-old can memorize them, but for a tutor opening the app the first time, nothing announces what each tab does.
- **The screen is still cluttered.** Below the modes bar, the category filter renders ~26 chips on 4-5 wrapped rows, most of them displaying the same default `🏷️` tag emoji because only a handful of categories are in the emoji map. The eye sees a wall of identical tag icons.

The goal of this revision is **visible labels** and **fewer always-on chips on screen**, without losing one-tap access to the daily modes.

## Goals / Non-Goals

**Goals**
- Every primary control reads correctly without hover.
- Default screen state shows ≤ 1 row of chrome (modes pills) above the practice card.
- All categories reachable in ≤ 2 taps with no scrolling wall.
- Every category has its own emoji; nothing falls back to a generic tag.

**Non-Goals**
- No data migration.
- No new mode types.
- No mobile-specific code paths; tabs stay flex-wrapped.
- No per-profile or per-role hiding beyond existing admin/auth gates.

## Decisions

### Decision 1: Practice tabs are pill-shaped, emoji + label

Reverses the icon-only choice from pass 1. Reason: on touch the label was effectively hidden, which the user explicitly called out. Pill tabs with `emoji + Hebrew word` are bigger, but seven of them still wrap to at most two rows and the kid can read them.

```
🎴 כרטיסיות   🎯 חידון   🔊 הקשבה   🧩 התאמה
🗣️ משפטים    📕 סיפורים  💬 שיחה   ☰ עוד
```

Active state: filled `--accent`, white text. Inactive: white surface, `--line` border. Hover/focus: border becomes `--accent`. Pressed: `scale(0.96)`.

**Alternative considered**: keep icon-only but add a permanent label strip below the row. Rejected — adds height, doesn't read as one component.

### Decision 2: `⋯` becomes `☰ עוד`

Three dots are convention but ambiguous (drag handle? more? loading?). The hamburger icon plus the Hebrew word "עוד" reads as "more". Same popover behavior, same width, same admin red-dot.

### Decision 3: Category filter becomes a single trigger + popover

The chip-row pattern works for 5 categories; at ~26 it's a wall. The category trigger is one button:

```
🌈 קטגוריה: הכול ▾
```

Tapping opens a `.shell-popover` (the same primitive used for the profile and `☰ עוד` menus) listing every category as a row:

```
┌────────────────────────────────────┐
│ 🌈  הכול                    264   │
│ ────────────                       │
│ 👋  ברכות                     8   │
│ 👨‍👩‍👧  אנשים                   12   │
│ 🎨  צבעים                    11   │
│ 🍽️  אוכל                      14   │
│ 🔢  מספרים                   10   │
│ 🏠  בית                       9   │
│   …                                │
└────────────────────────────────────┘
```

Selecting a category sets `state.category`, closes the popover, and updates the trigger label to show the chosen category's emoji + name. Tap-outside / `Escape` close like the other shell popovers.

**Counts**: shown in the right column. Lightweight — single pass over the active language's vocab on popover open.

**Alternative considered**: keep the chip row but require the user to swipe horizontally. Rejected — discoverability bad on iPad, breaks two-handed scanning. Categories deserve a real menu now that there are this many.

### Decision 4: Every category gets an emoji; no `🏷️` fallback

The `BUILTIN_CAT_EMOJI` map is extended to cover every category in the built-in RO and EN vocab. Mapping is hand-picked:

```
ברכות 👋   אנשים 👨‍👩‍👧   צבעים 🎨   אוכל 🍽️   שונות ✨
מספרים 🔢   כינויים 👥   מילות קישור 🔗   משפחה 👨‍👩‍👧‍👦   מקום 📍   זמן ⏰
נימוסים 🙏   בית 🏠   תיאורים 🔍   צורות 🔷   גדלים 📏   חיות 🐾   גוף 💪
בית ספר 🎒   חוץ 🌳   מזג אוויר 🌦️   טבע 🌿   בריאות 🩺   רגשות 😊   פעלים 🏃
בסיס 🌱
```

Custom user-added categories fall back to the **current unit's emoji** rather than `🏷️`. That is still distinctive and matches the curriculum context the kid is in.

### Decision 5: Profile chip slims by one piece

The chip currently shows `<emoji> <name> · <flag> · <speed> · <unit>`. Four pieces is reading-heavy and the speed is rarely glanceable. Drop speed from the face; it remains inside the popover where it lives anyway. New face:

```
🌟 איילה · 🇷🇴 · 🎨 יחידה 3
```

Guest sees `🇷🇴 · יחידה 1` + sign-in button.

### Decision 6: No new state fields

Category-popover open/close lives in DOM only (same pattern as profile/more popovers). `state.category` already exists. The category trigger reads from `state.category` and `getCategoryEmoji(state.category)`.

## Risks / Trade-offs

- **Pill tabs may wrap to two rows on narrow iPads.** Acceptable — they did before, just with less information. At < 560px width the labels hide via CSS and we fall back to icons (with `title` for desktop hover).
- **One extra tap to change category.** Previously a chip was one tap; now it's open popover, tap row. The category control was visually heaviest part of the page; trading one tap for that is a clear win.
- **Custom category fallback to unit emoji could collide visually with the unit indicator.** Mild; the unit indicator is in the chip and the category emoji is in a different surface. Custom categories are also rare in this app.
- **Hand-picked emoji map can drift if new categories appear.** Mitigated by the unit-emoji fallback — drift never produces the generic tag again.

## Migration / Compatibility

- No data migration. `state.category` semantics unchanged.
- `localStorage` keys unchanged.
- Tutor instructions: "tap קטגוריה to filter" (single trigger) instead of "scroll through chips".
- The `.chip` class can stay for any non-filter usage (guide page, etc.); the filter row stops using it.
