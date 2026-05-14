# Design: declutter-app-shell

## Context

The current top-of-page region has organic growth pains:

- The auth bar accreted a pill for every new setting (language, speed, unit) plus profile + sign-out + switch.
- The modes bar accreted a button for every new mode (chat being the most recent), and admin adds another at runtime.
- All controls share equal visual weight even though usage frequency varies by 100× (Flashcards every session vs. Manage maybe once a month).

The kid lives inside one practice card at a time. Everything around that card competes for attention. The goal is to make the practice card the protagonist and let chrome recede.

## Goals / Non-Goals

**Goals**
- Cut the always-visible interactive element count roughly in half (~17 → ~9).
- Preserve every existing capability — nothing is removed, just relocated.
- Keep one-tap access to the 7 daily practice modes.
- Settings (language, speed, unit shortcut) live behind a single chip menu so they don't take screen real estate when not in use.
- Touch targets stay generous for a 9-year-old.

**Non-Goals**
- No changes to mode internals (Stories rendering, Chat composer, etc.).
- No changes to data models, RLS, or backend functions.
- No mobile-specific code paths; flex wrapping is enough.
- No removal of features.

## Decisions

### Decision 1: Practice modes stay icon-only; secondary modes hide in `⋯`

We keep the practice modes as primary tabs because they are the kid's daily flow. Removing labels from those tabs is the chrome-shrink:

- The kid memorizes the 7 emojis fast (already does — flashcards/stories/chat are the regulars).
- `aria-label` + `title` keep accessibility and discoverability for new users / tutors.
- Active state uses a filled accent rounded rectangle so the current mode is obvious without color-coding each tab.

Secondary modes (units, guide, manage, user, requests) go behind `⋯` because:

- They're invoked weekly or less.
- They include actions tutors do (Manage) and the kid never does — putting them in a menu hides them from her without locking her out.

**Alternative considered**: keep all modes visible but smaller. Rejected — even at 80% size the bar wraps on iPad, and the kid's eye still has to scan 11 items.

### Decision 2: Auth bar collapses into one chip + popover

The four pills today (`lang`, `speed`, `unit`, profile) each cost real estate, but only `profile` and (rarely) `lang` are tapped during a session. The other two are set-once-per-week.

The chip pattern (Material 3 / iOS) collapses identity + active-context into a single tap target. Tapping opens a popover with the same controls organized into:

```
┌─────────────────────────┐
│  שפה:    🇷🇴   🇬🇧       │
│  מהירות:  ×1  ×0.9 ×0.75 ×0.5 │
│  ─────────────             │
│  → 📚 יחידות              │
│  ─────────────             │
│  🔄 החלפת פרופיל         │
│  🚪 יציאה                │
└─────────────────────────┘
```

Speed becomes a row of small buttons (not the cycling pill it is today). Cycling is fewer pixels but worse discoverability; in a popover where space is free we list all four.

**Trade-off**: changing speed now costs one extra tap (open chip, pick value). Acceptable — kids set speed once and forget. The popover stays open until tap-outside.

### Decision 3: Popover ≠ modal

The popover is a light overlay anchored to the chip, dismissed by tap-outside or `Escape`. It's not a modal — the rest of the screen stays scrollable and visible. This matches kids' apps better than a full-screen sheet for what is essentially a settings dropdown.

### Decision 4: `⋯` is also a popover, not a separate page

Same UX language as the profile popover. Two tiny popovers in the shell. They share a `.shell-popover` class for one transition / one outside-click handler.

### Decision 5: No new state fields

The popover open/close lives in a local DOM variable, not `state`. Persisting "popover is open" through a re-render is unnecessary; popovers close on any action. `state` already holds language and speedRate; nothing new to add.

### Decision 6: Admin entry stays runtime-added

The `applyModeVisibility()` function currently injects a `[data-mode="requests"]` button when `auth.isAdmin`. With the new design that injection happens inside the `⋯` popover instead of in the modes bar. Same pattern, smaller footprint. Notification dot stays.

## Risks / Trade-offs

- **Discoverability of `⋯`**: a tutor reading "how do I add a word?" might not realize Manage is behind it. Mitigation: title="עוד" and the menu rows have explicit Hebrew labels.
- **Tap-target regression** if practice tabs shrink too much. Mitigation: explicit `min-width: 48px; min-height: 48px;` per tab.
- **Speed-pill loyalty**: the cycling speed pill is fast for adults but the popover lists all values which is friendlier for a 9-year-old. Mild change.
- **Animation budget**: two popovers + the existing modes bar = small animation surface. Keep transitions cheap (`transform` + `opacity`, no layout).

## Migration / Compatibility

- No data migration.
- `localStorage` keys (`ro-kids-language`, `ro-kids-speech-rate`) keep working — the new popover reads and writes the same keys.
- No URL changes; modes are still hash-less and `state.mode` driven.
- Tutor instructions ("tap Manage to add a word") need updating: now "tap the ⋯ menu, then Manage".
