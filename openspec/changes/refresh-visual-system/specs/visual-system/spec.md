# visual-system Specification Delta

## ADDED Requirements

### Requirement: Single token palette drives all UI color

The stylesheet SHALL declare CSS custom properties on `:root` defining the entire visual palette:

- `--canvas`, `--surface`, `--accent`, `--reward`, `--ink`, `--muted`, `--line`, `--danger`
- Radii: `--radius-sm`, `--radius-md`, `--radius-lg`
- Shadows: `--shadow-sm`, `--shadow-md`
- Motion: `--transition`

Every UI selector SHALL reference these tokens via `var(--token)` rather than hard-coded color values.

#### Scenario: No hex literals in UI selectors

- **WHEN** the stylesheet is inspected
- **THEN** the only locations where `#xxxxxx` hex values appear are inside the `:root` `--*` declarations themselves
- **AND** no `color:`, `background:`, `border:` rule uses a raw hex

#### Scenario: Tokens cover the whole palette in use

- **WHEN** the stylesheet renders the app
- **THEN** every visible color on screen is one of the eight defined tokens

### Requirement: No gradients on UI elements

The stylesheet SHALL contain zero `linear-gradient(...)`, `radial-gradient(...)`, or `conic-gradient(...)` rules. All surfaces, buttons, pills, chips, badges, and the page background SHALL use solid colors from the palette.

#### Scenario: Gradient-free stylesheet

- **WHEN** the stylesheet is grepped for `gradient(`
- **THEN** no matches are returned

#### Scenario: Body is the canvas

- **WHEN** the document body renders
- **THEN** its computed `background-image` is `none`
- **AND** its `background-color` is `var(--canvas)`

### Requirement: Typography pairs Heebo with Nunito

Hebrew text SHALL render in Heebo; Latin text (Romanian and English) SHALL render in Nunito. The font stack `"Heebo", "Nunito", "Arial Hebrew", -apple-system, sans-serif` SHALL be declared on the body.

Nunito SHALL be loaded via a Google Fonts `<link>` in `<head>` with `display=swap` and weights `400` and `700`.

The stylesheet SHALL use only weights 400 and 700 and SHALL NOT use italic.

#### Scenario: Nunito link present

- **WHEN** `<head>` is inspected
- **THEN** there is a `<link rel="stylesheet">` whose `href` includes `fonts.googleapis.com` and `Nunito`
- **AND** the URL contains `display=swap`

#### Scenario: No italics

- **WHEN** the stylesheet is grepped
- **THEN** no rule includes `font-style: italic`

### Requirement: Three-shape button system

All buttons in the application SHALL use one of three CSS classes:

- `.btn` — primary, fill `var(--accent)`, text white
- `.btn-secondary` — fill `var(--surface)`, text `var(--ink)`, 1.5px border `var(--line)`
- `.btn-danger` — fill `var(--surface)`, text `var(--danger)`, 1.5px border `var(--danger)`

All buttons SHALL share:
- `border-radius: var(--radius-md)`
- Padding `12px 18px`
- `transition: var(--transition)` on background, color, border, transform
- `:active { transform: scale(0.96); }`
- Disabled state: 40% opacity, no transform, `cursor: not-allowed`

#### Scenario: Quiz "next" button uses primary

- **WHEN** the quiz feedback row appears after an answer
- **THEN** the "המשך ➡️" button has class `.btn`
- **AND** its computed background is the accent green

#### Scenario: Chat reset is destructive

- **WHEN** the chat toolbar renders with messages present
- **THEN** the reset button has class `.btn-danger`
- **AND** its computed border color is `var(--danger)`

#### Scenario: Pressed state shrinks

- **WHEN** the user presses any `.btn` (mousedown / touchstart)
- **THEN** the button's `transform` becomes `scale(0.96)` for ~100ms

### Requirement: Reward color is reserved for success moments

The `--reward` color SHALL be used ONLY for:

- Confetti particles
- The `+10 ⭐` score callout
- Earned unit badges (new unit unlocked)

It SHALL NOT be used on regular UI chrome (buttons, pills, tabs, borders, backgrounds outside the moments above).

#### Scenario: Buttons do not use reward color

- **WHEN** any `.btn`, `.btn-secondary`, or `.btn-danger` renders
- **THEN** its computed background and border are not `var(--reward)`

#### Scenario: Confetti uses the palette

- **WHEN** confetti triggers on a correct answer
- **THEN** every particle color is either `var(--accent)` or `var(--reward)`

### Requirement: Chrome icons use Lucide line icons; content stays emoji

Chrome controls (close, settings, reset, send, sign-out, back) SHALL render Lucide line icons inlined as `<svg>` using a hidden `<svg>` sprite + `<use href="#icon-name">` references. Icons SHALL be 20×20 with stroke `2` and color `currentColor`.

Content elements (mode tabs, vocabulary cards, story bubbles, story word chips, units grid, profile emoji) SHALL continue to use emoji glyphs unchanged.

#### Scenario: Chat reset uses a Lucide icon

- **WHEN** the chat reset button renders
- **THEN** its content is a `<svg>` with `<use href="#icon-refresh-cw"/>`, not the 🗑️ emoji

#### Scenario: Mode tabs keep emoji

- **WHEN** the modes bar renders
- **THEN** each practice tab's visible content includes its emoji (🎴, 🎯, 🔊, 🧩, 🗣️, 📕, 💬)

#### Scenario: Vocabulary cards keep emoji

- **WHEN** a flashcard renders
- **THEN** the card's emoji (e.g., 🍎) is still a Unicode emoji glyph, not an SVG

### Requirement: Motion is restrained and consistent

- All color, background, border, and transform transitions SHALL use `var(--transition)` (`150ms ease`).
- Buttons and chips SHALL scale to `0.96` on `:active`.
- Confetti SHALL use a softened palette (only `--accent` and `--reward`) and a duration ≤ 1.5s.
- Mode-card enter animations SHALL be a 200ms fade with a 4px up-slide and no spring.

#### Scenario: Standard transition duration

- **WHEN** the stylesheet is grepped for `transition:` rules with a numeric duration
- **THEN** all matches use `var(--transition)` (or another rule that references it)

#### Scenario: Card slide-in has no bounce

- **WHEN** the user switches modes
- **THEN** the new card's `animation-timing-function` is `ease` or `ease-out` (not a cubic-bezier with overshoot)

### Requirement: Active practice card has an accent stripe

When a practice mode is active, the rendered practice card SHALL have a 4px stripe at its top edge using `var(--accent)`. The stripe SHALL be implemented via a `::before` pseudo-element on the card (no per-mode color variants — same color for every active mode).

#### Scenario: Stories card has a stripe

- **WHEN** the Stories mode is active
- **AND** a story card renders
- **THEN** the card has a `::before` element 4px tall, full width, colored `var(--accent)`, positioned at the top edge of the card
