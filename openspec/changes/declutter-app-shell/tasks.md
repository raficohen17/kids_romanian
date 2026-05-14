# Tasks: declutter-app-shell

## 1. Modes bar — practice icons + ⋯ menu

- [x] 1.1 Practice modes are icon-only `<button class="mode-tab" aria-label="..." title="...">` elements.
- [x] 1.2 `aria-label` and `title` carry the Hebrew name.
- [x] 1.3 `.mode-tab` is 52×52px with active fill on `var(--accent)`.
- [x] 1.4 `⋯` trigger builds a `.shell-popover` listing units/guide/manage/user (and requests when admin).
- [x] 1.5 `applyModeVisibility()` no longer appends a tab; it refreshes the popover and toggles a `.has-badge` dot on ⋯.
- [x] 1.6 Row click activates the mode and closes the popover.

## 2. Auth bar — profile chip + popover

- [x] 2.1 The separate `lang-pill` / `speed-pill` / `unit-pill` rendering paths are gone; CSS for those classes was removed.
- [x] 2.2 A single `.profile-chip` shows `<emoji> <name> · <flag> · <speed> · <unit>`. Guest sees the same chip without the name plus a `🔓 כניסה` sign-in button.
- [x] 2.3 Tapping the chip opens a popover with language pills, speed pills, units shortcut, switch-profile, and sign-out.
- [x] 2.4 Reuses `switchLanguage`, the existing speed-rate setter, `auth.view = 'picker'`, and `signOut`.
- [x] 2.5 Speed persists in `ro-kids-speech-rate` localStorage as before.
- [x] 2.6 Tap-outside and `Escape` close the popover.

## 3. Shared shell-popover primitive

- [x] 3.1 Single `.shell-popover` CSS class with 150ms fade + 4px slide.
- [x] 3.2 Single global outside-click handler closes whichever popover is open.
- [x] 3.3 `Escape` closes; trigger `aria-expanded` toggled by open/close logic.

## 4. Clean up

- [x] 4.1 `.lang-pill` / `.speed-pill` / `.unit-pill` CSS rules removed.
- [x] 4.2 `wireLangPill` and `wireSpeedPill` deleted; `wireUnitPill` removed; `updateUnitPill` kept as a small re-render shim for legacy callers.
- [x] 4.3 `renderAuthBar()` rebuilds the chip on every auth state change.

## 5. Verify (user smoke-test)

- [ ] 5.1 Guest: modes bar shows practice tabs + ⋯; auth bar shows chip + sign-in.
- [ ] 5.2 Signed-in profile: chat tab appears; chip shows identity + context.
- [ ] 5.3 Chip popover: language / speed / units / switch profile / sign-out all work.
- [ ] 5.4 ⋯ popover: units / guide / manage / user reachable and close after selection.
- [ ] 5.5 Admin sees 📥 בקשות in ⋯ and the badge dot when there are pending requests.
- [ ] 5.6 Keyboard tab order works; Escape closes popovers.
- [ ] 5.7 Reload preserves language, speed, profile.

## 6. Ship

- [x] 6.1 Branched off main; PR pending.
