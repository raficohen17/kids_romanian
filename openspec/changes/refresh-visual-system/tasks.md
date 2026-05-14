# Tasks: refresh-visual-system

## 1. Tokens

- [x] 1.1 `:root` declares `--canvas`, `--surface`, `--accent`, `--accent-2`, `--reward`, `--ink`, `--muted`, `--line`, `--danger`, radii, shadows, `--transition`.
- [ ] 1.2 **Revision**: token values changed — `--accent` → indigo `#6750a4`, `--reward` → coral `#ff7a59`, add `--accent-soft #ede7f6`, `--reward-soft #ffe7df`, `--success #2e9c63`; `--line` warmed to `#e7e3dc`; canvas warmed to `#fbf6ee`.
- [x] 1.3 All `linear-gradient(...)` removed from the stylesheet.

## 2. Typography

- [x] 2.1 Google Fonts link present for Heebo + Nunito with `display=swap`.
- [x] 2.2 Body font stack `"Heebo", "Nunito", ...`.
- [x] 2.3 Body `line-height: 1.5`.

## 3. Body & layout shell

- [x] 3.1 Body background `var(--canvas)`.
- [ ] 3.2 `h1` color → `var(--accent)`.
- [ ] 3.3 `.panel` shadow softened (`var(--shadow-md)`); border-radius unified.

## 4. Stat cards

- [ ] 4.1 `.stat.score` → `var(--accent)` bg, white text.
- [ ] 4.2 `.stat.streak` → `var(--reward)` bg, white text.
- [ ] 4.3 `.stat.total` → `var(--accent-soft)` bg, `var(--ink)` text.

## 5. Button & chip / pill sweep

- [ ] 5.1 `.btn` hover → `var(--accent-2)`; primary fill `var(--accent)` (already).
- [ ] 5.2 `.mode-tab:hover` border → `var(--accent)`; `:hover` removes the purple `#ba68c8`.
- [ ] 5.3 `.mode-more`, `.profile-chip`, `.shell-popover-pill`, `.shell-popover-row` all swap purple/pink for tokens.
- [ ] 5.4 `.chip.active` → `var(--accent-soft)` bg, `var(--accent)` border (used by guide page only after the declutter revision).
- [ ] 5.5 `.btn-secondary:hover` and `.btn-danger:hover` already use accent/danger tokens — verify no leftover hex.

## 6. Card / flashcard text

- [ ] 6.1 `.card .he` → `var(--ink)`.
- [ ] 6.2 `.card .ro` → `var(--accent)`.
- [ ] 6.3 `.card .pron` → `var(--muted)`.
- [ ] 6.4 `.card .note` → `var(--muted)` (italic preserved).
- [ ] 6.5 `.card::before` stripe → `var(--accent)` (already).

## 7. Profile + auth + units + emoji-picker

- [ ] 7.1 `.profile-chip:hover` border → `var(--accent)`; expanded bg → `var(--accent-soft)`.
- [ ] 7.2 `.pin-card` border → `var(--line)`; `.pin-card h3` color → `var(--accent)`.
- [ ] 7.3 `.unit-tile.current` border → `var(--reward)`, bg → `var(--reward-soft)`; `.unit-tile.unlocked:hover` border → `var(--accent)`.
- [ ] 7.4 `.emoji-tile:hover` border → `var(--accent)`; `.emoji-tile.selected` bg → `var(--accent-soft)`, border → `var(--accent)`.
- [ ] 7.5 `.auth-bar .ab-btn:hover` border → `var(--accent)`; `.ab-primary` already uses `var(--accent)`.

## 8. Confetti / motion

- [ ] 8.1 Confetti palette JS swapped from green/saffron to coral/emerald (`--reward` + `--success`).
- [x] 8.2 Standard transitions use `var(--transition)`.
- [x] 8.3 Buttons `:active { transform: scale(0.96) }`.

## 9. Sweep verification

- [ ] 9.1 Grep for the legacy purple/pink hex list; only matches inside the favicon SVG `data:` URL are allowed.
- [ ] 9.2 Visual pass on every mode: flashcards, quiz, listen, match, sentences, stories, chat, guide, manage, user, units, requests.
- [ ] 9.3 Confetti still triggers on correct answers and uses the new palette.

## 10. Ship

- [ ] 10.1 Committed alongside the declutter-app-shell revision.
