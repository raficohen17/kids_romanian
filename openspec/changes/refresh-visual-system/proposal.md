# Change: refresh-visual-system

## Why

Pass 1 introduced a token system (`--accent: forest-green`, `--reward: saffron`, `--canvas: warm-off-white`) and removed gradients on cards and the body. The user pushback:

- **It's not pleasing to the eye.** Forest green as the primary accent reads institutional next to a kid's app full of emoji; saffron yellow against warm cream goes muddy; the canvas is so beige the page loses contrast.
- **The refresh is half-done.** The `<h1>` is still `#d81b60` pink, stat cards still use `#fde7f2` pink and `#3949ab` indigo, the flashcard's `.he` text is `#4527a0` purple and `.ro` text is `#c2185b` pink, every hover border is `#ba68c8` purple. The new green accent fights every leftover color.
- **The accent doubles as "correct".** A green-fill active tab and a green confetti burst on a correct answer use the same color, so success doesn't *feel* like a reward — it feels like the UI moved.

Goal of this revision: a coherent, warm, playful palette that **reads as a kid's app without feeling like a 2014 kid's app**, applied to every surface (not just the few touched in pass 1), with the active state and the reward state visually distinct.

## What Changes

### Palette — indigo + coral, not green + saffron

```
--canvas:    #fbf6ee     warm cream (slightly warmer than pass 1)
--surface:   #ffffff     card / popover background
--accent:    #6750a4     indigo-violet — primary action / active tab
--accent-2:  #574293     darker indigo for hover
--accent-soft: #ede7f6   light wash for hovers, active row tint
--reward:    #ff7a59     warm coral — earned points, streaks, confetti
--reward-soft: #ffe7df   light coral wash for streak badges
--success:   #2e9c63     emerald — used ONLY in "correct!" toasts and confetti accents
--ink:       #1f1f1f     body text
--muted:     #6b6b6b     secondary text
--line:      #e7e3dc     dividers / subtle borders (warm grey, not cold)
--danger:    #c62828     reset / sign-out hints
```

The accent and the reward and success colors are the only saturated tones. **Each plays a distinct role**:
- **Accent** = "this is the active control / primary action". Tab fill, primary buttons, popover-row hover.
- **Reward** = "you earned something". Streak badge, score pop, confetti.
- **Success** = "your answer was correct". Correct-answer toast border / icon. Never appears on chrome.

### Sweep every leftover hex literal

Pass 1 left the header, stat cards, card text, popover hover borders, and many ad-hoc borders using the old purple/pink palette. This pass replaces them. Specific targets:

- `h1` color → `--accent`
- `.stat.score` background → `--accent`
- `.stat.streak` background → `--reward`
- `.stat.total` background → `--accent-soft` with `--ink` text (no more competing indigo `#3949ab`)
- `.card .he` color → `--ink` (let the Hebrew read as plain body text — emphasis comes from size)
- `.card .ro` color → `--accent` (the foreign word is the focal point)
- `.card .pron` color → `--muted`
- `.mode-tab:hover` border → `--accent`
- `.profile-chip:hover` border → `--accent`
- `.shell-popover-row:hover` background → `--accent-soft`
- `.shell-popover-pill.active` background → `--accent`
- `.unit-tile.current` border → `--reward`, background → `--reward-soft`
- `.emoji-tile.selected` border → `--accent`, background → `--accent-soft`
- `.chip.active` background → `--accent-soft`, border → `--accent`
- `.pin-card` border → `--line`; `.pin-card h3` color → `--accent`
- `.auth-bar .ab-primary` → already `--accent`, keep
- All `box-shadow` glow colors using `rgba(126, 87, 194, ...)` → `rgba(103, 80, 164, ...)` (the new accent in transparent form)

### Typography stays

`Heebo` + `Nunito`, weights 400/700, `font-display: swap`, line-height 1.5. No change.

### Button system stays

`.btn` / `.btn-secondary` / `.btn-danger` from pass 1 keep their shapes. Only their colors update via the token sweep.

### Motion stays

150ms ease, `scale(0.96)` on active. Confetti palette now `--reward` + `--success` (was `--accent` + `--reward`) so the green stays meaningful as "correct".

### Mode-active stripe stays accent

4px `--accent` stripe at the top of the active card. With the new indigo, the stripe is warmer and reads as a brand mark, not a "go" signal.

### Icon system stays

Lucide line icons for chrome (`refresh-cw`, `log-out`, `users`, `x`, `send`, `settings`), emoji for content. Inlined SVG, `currentColor`, 20×20.

## Out of Scope (future)

- **Dark mode.**
- **Per-mode brand colors.** Active state still single-accent indigo.
- **Replacing emoji with icons in content.** Stays.
- **Animated mascot / illustrations.** Out of scope.
- **Sound / haptics.** Separate concern.

## Impact

- **Modified**: `index.html` — `:root` token block updated; every selector that used a hard-coded pink/purple/forest-green hex remapped to a token; confetti palette JS swapped from green/saffron to coral/emerald; favicon untouched.
- **No JS logic changes** beyond the confetti palette.
- **No data, auth, backend, or schema changes.**
- **No new external dependencies.** Google Fonts links unchanged.

## Risks

- **Indigo + coral may feel less "playful" to a kid than rainbow.** Mitigated by keeping emoji-heavy content, warm cream canvas, and the coral reward color popping on confetti.
- **Tutor / parent muscle memory.** Less of a problem than pass 1's rainbow→green jump because indigo is closer to the old purple muscle-memory.
- **Sweeping hex literals risks missing one.** Mitigated by a single explicit grep pass at the end and visiting every mode in the verify step.
