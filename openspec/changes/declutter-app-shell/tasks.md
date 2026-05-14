# Tasks: declutter-app-shell

## 1. Modes bar — practice icons + ⋯ menu

- [ ] 1.1 Restructure `.modes` HTML: practice modes (`flash`, `quiz`, `listen`, `match`, `sentences`, `stories`, `chat`) as icon-only buttons; remove their Hebrew text node and keep the emoji in `textContent`.
- [ ] 1.2 Add `aria-label` and `title` attributes to every practice tab so the Hebrew label is still announced and tooltip-visible.
- [ ] 1.3 Update CSS so practice tabs are at least 48×48px and use a rounded square; active tab gets an accent fill.
- [ ] 1.4 Add a `⋯` trigger button at the end of `.modes`. Builds a `.shell-popover` listing `units`, `guide`, `manage`, `user` (and `requests` when `auth.isAdmin`) with their Hebrew labels.
- [ ] 1.5 Update `applyModeVisibility()` to add/remove the `requests` row inside the popover instead of appending a tab to the bar.
- [ ] 1.6 Clicking a row in the popover sets `state.mode` and runs `render()` exactly as the old tabs did; popover closes after a row click.

## 2. Auth bar — profile chip + popover

- [ ] 2.1 Remove the separate `lang-pill`, `speed-pill`, `unit-pill` rendering paths.
- [ ] 2.2 Build a single `.profile-chip` that shows `<emoji> <name> · <flag> · יחידה <n>`. For guest mode show only `🔓 כניסה` and skip the popover.
- [ ] 2.3 Build a `.profile-popover` opened by tapping the chip with these rows:
  - Language toggle (two big flag buttons; currently-active flag has the accent fill)
  - Speech speed (four small buttons for `×1 / ×0.9 / ×0.75 / ×0.5`; active speed highlighted)
  - "→ 📚 יחידות" deep-link
  - "🔄 החלפת פרופיל"
  - "🚪 יציאה"
- [ ] 2.4 Reuse existing handlers: `switchLanguage(newLang)`, the existing speed setter logic (currently in `wireSpeedPill`), `auth.view = 'picker'`, `signOut`.
- [ ] 2.5 Persist `speechRate` to `localStorage` exactly as today.
- [ ] 2.6 Tap-outside or `Escape` closes the popover.

## 3. Shared shell-popover primitive

- [ ] 3.1 Single CSS class `.shell-popover` for both popovers (anchored to its trigger, light shadow, rounded corners, 250ms fade-in via opacity + small translateY).
- [ ] 3.2 Single outside-click handler that closes whichever popover is open.
- [ ] 3.3 Keyboard: `Escape` closes; trigger has `aria-expanded` toggled.

## 4. Clean up

- [ ] 4.1 Remove unused CSS rules for `.lang-pill`, `.speed-pill`, `.unit-pill` (or repoint them to the new chip styles if reused).
- [ ] 4.2 Remove the `wireLangPill`, `wireSpeedPill`, `wireUnitPill` helpers; their behaviour now lives in popover row handlers.
- [ ] 4.3 Make sure `renderAuthBar()` still re-renders on auth state changes (sign-in, sign-out, profile select).

## 5. Verify

- [ ] 5.1 Open the app as guest; confirm modes bar has 6 practice tabs (no chat) + ⋯; auth bar shows only `🔓 כניסה`.
- [ ] 5.2 Sign in, select a profile; confirm chat tab appears, chip shows `<emoji> <name> · <flag> · יחידה N`.
- [ ] 5.3 Tap the chip; confirm popover opens, language toggle works, speed selection persists, sign-out works, switch-profile works.
- [ ] 5.4 Tap ⋯; confirm Units / Guide / Manage / User are reachable and the popover closes after a selection.
- [ ] 5.5 As admin, confirm 📥 בקשות appears inside ⋯ and the red-dot badge still works.
- [ ] 5.6 Keyboard: Tab through controls; Escape closes popovers.
- [ ] 5.7 Re-load the page; confirm no visible state regression (active mode preserved, language preserved, speed preserved).

## 6. Ship

- [ ] 6.1 Commit on a fresh branch off main; PR.
