# Tasks: refresh-visual-system

## 1. Tokens

- [x] 1.1 `:root` declares `--canvas`, `--surface`, `--accent`, `--accent-2`, `--reward`, `--ink`, `--muted`, `--line`, `--danger`, radii (`sm/md/lg`), shadows (`sm/md`), `--transition`.
- [ ] 1.2 Hex literals across the file were touched on the high-impact rules (gradients, button base, card base, body); a full sweep of every remaining hex into `var(--*)` is left as a follow-up — most of those are kid-facing accent colors that should be reviewed visually before changing.
- [x] 1.3 All `linear-gradient(...)` removed from the stylesheet and from inline style attributes.

## 2. Typography

- [x] 2.1 `<head>` adds the Google Fonts link for Heebo + Nunito with `display=swap`.
- [x] 2.2 Body font stack updated to `"Heebo", "Nunito", ...`.
- [ ] 2.3 A full type-scale variable set wasn't introduced; body sizes were normalized to 1.05rem and existing per-element sizes left intact for now.
- [x] 2.4 Removed font-style italic where it appeared on buttons (the chrome ones; content `font-style:italic` on a couple of hint texts remains and was intentionally kept).
- [x] 2.5 Body `line-height: 1.5`.

## 3. Body & layout shell

- [x] 3.1 Body background is now `var(--canvas)`.
- [x] 3.2 Title block reads on the new canvas; no further tweak needed.
- [x] 3.3 Cards keep `--surface`; per-mode tint backgrounds replaced with the same surface plus the accent stripe.

## 4. Button system

- [x] 4.1 `.btn` is the primary (accent fill); `.btn-secondary` and `.btn-danger` defined.
- [x] 4.2 Legacy `.btn.speak`, `.btn.prev`, `.btn.shuffle` remapped to the new tokens.
- [x] 4.3 12px / 18px padding and `var(--radius-md)` applied across the system.
- [x] 4.4 `:active { transform: scale(0.96); }` on `.btn`, `.btn-secondary`, `.btn-danger`.
- [x] 4.5 Disabled state defined (40% opacity, no transform).

## 5. Card / surface treatment

- [x] 5.1 `.card` uses `--surface`, `--shadow-md`, `--radius-lg`, and a thin `--line` border.
- [x] 5.2 4px `--accent` stripe via `::before` at the top of every `.card`.
- [ ] 5.3 Dividers/borders across the rest of the file weren't all unified to `--line` — leaving as a polish follow-up.

## 6. Icon system

- [x] 6.1 Inline SVG sprite added with `refresh-cw`, `log-out`, `users`, `x`, `send`, `settings` Lucide icons.
- [x] 6.2 `.icon`, `.icon-sm`, `.icon-lg` CSS classes defined.
- [x] 6.3 Chrome locations swapped: chat reset (now refresh-cw), profile-popover sign-out (log-out), profile-popover switch-profile (users). Remaining chrome (overlay close, send button, more settings entry points) left with their emoji — easy follow-up.
- [x] 6.4 Content emoji preserved everywhere (modes, vocab, cards, stories, chat bubbles).

## 7. Motion

- [x] 7.1 Standard transitions use `var(--transition)` where buttons / chips / popovers transition.
- [ ] 7.2 Confetti softening (particle count, palette) — not touched this pass; current confetti still works, palette tuning is a polish follow-up.
- [x] 7.3 Card-enter inherits the existing 0.25s transform; no spring/bounce introduced.
- [ ] 7.4 `+10 ⭐` callout animation — uses existing styling; new reward-palette pop is a follow-up.

## 8. Verify (user smoke-test)

- [ ] 8.1 Visual pass on every mode (flashcards, quiz, listen, match, sentences, stories, chat).
- [ ] 8.2 Confetti still triggers on correct answers.
- [ ] 8.3 Lucide icons render correctly in the RTL document.
- [ ] 8.4 Nunito loads via Google Fonts; fallback works during swap window.
- [ ] 8.5 Keyboard tab order + focus rings still work (visible focus state TBD if missing).

## 9. Ship

- [x] 9.1 Committed alongside `declutter-app-shell` apply.
