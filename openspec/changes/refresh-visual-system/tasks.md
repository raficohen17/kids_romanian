# Tasks: refresh-visual-system

## 1. Tokens

- [ ] 1.1 Define CSS custom properties on `:root`: `--canvas`, `--surface`, `--accent`, `--reward`, `--ink`, `--muted`, `--line`, `--danger`, `--radius-{sm,md,lg}`, `--shadow-{sm,md}`, `--transition`.
- [ ] 1.2 Replace every hard-coded color hex in the file with a `var(--*)` reference. Inventory first with `grep -nP '#[0-9a-fA-F]{3,6}' index.html` to drive this.
- [ ] 1.3 Remove every `linear-gradient(...)` from the stylesheet. Pick the right token per selector (most become `--surface` or `--accent`).

## 2. Typography

- [ ] 2.1 Add a `<link>` for Nunito (weights 400, 700) in the `<head>` with `display=swap`.
- [ ] 2.2 Update the body font stack: `"Heebo", "Nunito", "Arial Hebrew", -apple-system, sans-serif`.
- [ ] 2.3 Define the type scale via CSS variables or utility classes: 0.9 / 1.0 / 1.15 / 1.4 / 2.0 rem.
- [ ] 2.4 Remove italic and font-weight-other-than-400/700 from the stylesheet.
- [ ] 2.5 Set body line-height 1.5; headlines 1.3.

## 3. Body & layout shell

- [ ] 3.1 Replace the body background rainbow with `var(--canvas)`.
- [ ] 3.2 Update the page header / title block to use the new type scale and ink color.
- [ ] 3.3 Pages that previously had per-mode tinted backgrounds keep `--surface` everywhere; rely on motion + accent stripe for distinction.

## 4. Button system

- [ ] 4.1 Define `.btn` (primary, accent fill, white text), `.btn-secondary` (surface fill, ink text, line border), `.btn-danger` (surface fill, danger text + border).
- [ ] 4.2 Map all existing variants (`.btn.speak`, `.btn.shuffle`, `.btn.prev`, `.match-btn`, etc.) to one of the three.
- [ ] 4.3 Apply consistent paddings (12px/18px) and `--radius-md` to every button.
- [ ] 4.4 Add the `:active { transform: scale(0.96); }` interaction.
- [ ] 4.5 Disabled state: 40% opacity, no transform, `cursor: not-allowed`.

## 5. Card / surface treatment

- [ ] 5.1 Cards (`.card`, `.story-card`, `.sentence-card`, chat-list wrappers) use `--surface` with `--shadow-sm` and `--radius-lg`.
- [ ] 5.2 The active practice mode's card has a 4px `--accent` stripe at the top edge (a `::before` element).
- [ ] 5.3 Dividers use `--line` (1px) instead of colored borders.

## 6. Icon system

- [ ] 6.1 Inline 6 Lucide SVG icons in a hidden `<svg style="display:none">` sprite at the top of `<body>` (`x`, `arrow-left`, `settings-2`, `refresh-cw`, `send`, `log-out`).
- [ ] 6.2 Add a small `.icon` CSS class (20×20, stroke currentColor, inline-block).
- [ ] 6.3 Replace chrome-action emoji with `<svg class="icon"><use href="#icon-name"/></svg>` in chrome locations:
  - Close on overlays
  - Sign-out button (currently 🚪)
  - Settings entry-points
  - Chat reset (currently 🗑️) — choose `refresh-cw` to signal "new conversation"
  - Send button on chat composer
- [ ] 6.4 Leave content emoji (mode tabs, vocab cards, story bubbles) untouched.

## 7. Motion

- [ ] 7.1 Standard transitions on color / background / border / transform use `var(--transition)`.
- [ ] 7.2 Soften confetti: reduce particle count ~50%, fade duration ~1.2s, particle palette only `--accent` + `--reward`.
- [ ] 7.3 Card-enter on mode change: 200ms fade + 4px up-slide. No bounce / spring.
- [ ] 7.4 The `+10 ⭐` callout uses `--reward` and a quick scale-up-then-back animation.

## 8. Verify

- [ ] 8.1 Visual pass on every mode (Flashcards, Quiz, Listen, Match, Sentences, Stories, Chat). Confirm no leftover gradients, no rainbow body, consistent typography, consistent buttons.
- [ ] 8.2 Confetti still triggers on correct quiz/match answers and uses the new palette.
- [ ] 8.3 Lucide icons render correctly LTR even in the RTL document.
- [ ] 8.4 Nunito loads (check Network tab); fallback works during the swap window.
- [ ] 8.5 No regression in keyboard tab order or focus rings (add a visible focus state if missing).

## 9. Ship

- [ ] 9.1 Commit on a fresh branch off main; PR with before/after screenshots of at least Flashcards + Stories + Chat.
