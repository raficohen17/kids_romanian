# Tasks: declutter-app-shell

## 1. Modes bar — pill tabs with labels

- [x] 1.1 Practice modes are icon-only `<button class="mode-tab" aria-label="..." title="...">` elements. *(pass 1)*
- [ ] 1.2 **Revision**: practice tabs become pill-shaped with `emoji + Hebrew label` (`🎴 כרטיסיות`, etc.). Active fills `--accent`; inactive is white + `--line` border.
- [ ] 1.3 Pill padding `10px 14px`, `border-radius: 999px`, min-height `44px`. At viewport `<= 560px` the label hides via CSS — icons only as a fallback.
- [ ] 1.4 The `⋯` trigger becomes `☰ עוד` (icon + Hebrew word). Popover behavior unchanged.
- [ ] 1.5 `applyModeVisibility()` keeps refreshing the popover and the `has-badge` dot on the `☰ עוד` trigger.

## 2. Category filter — single popover trigger

- [ ] 2.1 Remove the chip row from `.filter-row`. Replace `#filters` with one `<button class="category-trigger">` showing `<emoji> קטגוריה: <name> ▾`.
- [ ] 2.2 New `.shell-popover` for categories: rows of `<emoji> <name> <count>`. Selecting a row sets `state.category`, closes popover, re-renders.
- [ ] 2.3 Category trigger only renders when the active mode uses category filtering (existing `["guide","manage","sentences","user","units","requests"]` blocklist applies).
- [ ] 2.4 Trigger updates its own label when category changes (no full re-render needed).

## 3. Category emoji coverage

- [ ] 3.1 Extend `BUILTIN_CAT_EMOJI` to include every category appearing in built-in RO and EN vocab.
- [ ] 3.2 `getCategoryEmoji()` falls back to `unitOf(state.currentUnit).emoji` for unknown categories — never `🏷️`.
- [ ] 3.3 Verify the guide page (`<details>` per category) renders with the new emoji set.

## 4. Profile chip slim-down

- [x] 4.1 Profile chip rendered with `<emoji> <name> · <flag> · <speed> · <unit>`. *(pass 1)*
- [ ] 4.2 Remove the speed segment from the chip face; speed still lives in the popover.

## 5. Shared shell-popover primitive

- [x] 5.1 Single `.shell-popover` CSS class with 150ms fade + 4px slide.
- [x] 5.2 Single global outside-click handler closes whichever popover is open.
- [x] 5.3 `Escape` closes; trigger `aria-expanded` toggled by open/close logic.
- [ ] 5.4 Category popover is wired through the same outside-click + Escape paths.

## 6. Clean up

- [x] 6.1 `.lang-pill` / `.speed-pill` / `.unit-pill` CSS rules removed.
- [x] 6.2 `wireLangPill` and `wireSpeedPill` deleted.
- [ ] 6.3 `.chip` styles can stay (guide page uses them), but `.filter-row` becomes a single-trigger container.

## 7. Verify (user smoke-test)

- [ ] 7.1 Guest on iPad: modes bar shows seven pill tabs with Hebrew labels; auth bar shows chip + sign-in.
- [ ] 7.2 Signed-in profile: chat tab appears; chip shows identity + flag + unit.
- [ ] 7.3 Chip popover: language / speed / units / switch profile / sign-out all work.
- [ ] 7.4 `☰ עוד` popover: units / guide / manage / user reachable; admin sees 📥 בקשות + badge dot.
- [ ] 7.5 Category trigger: opens popover with every category showing a real emoji; selecting one updates the trigger label and filters; no `🏷️` anywhere on screen.
- [ ] 7.6 Default screen state: only one chrome row (the modes pills) above the practice card — no chip-wall.
- [ ] 7.7 Keyboard tab order works; Escape closes popovers.
- [ ] 7.8 Reload preserves language, speed, profile, category.

## 8. Ship

- [x] 8.1 Branched off main. Revision committed on top of pass-1 commit.
