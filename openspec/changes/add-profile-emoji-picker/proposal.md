# Change: add-profile-emoji-picker

## Why

Today profile creation and emoji editing use a `prompt()` dialog asking for a freeform emoji string. That:

- requires the user to know how to type/paste an emoji (hostile on iPad without a keyboard)
- accepts any text, leading to broken or off-brand emojis ("hi" as a profile emoji is technically valid)
- gives no inspiration — the parent / kid stares at a blank text field

A small curated dropdown of 20 kid-friendly emojis replaces the prompt with a visual picker. Pick → done.

## What Changes

- Define a constant **`PROFILE_EMOJIS`** of 20 curated emojis suitable for kid profile avatars (animals, sparkles, nature — gender-neutral, culturally neutral)
- Replace the `prompt("אימוג'י (אופציונלי):", ...)` call in `createProfileFlow()` with an **emoji-picker modal**: a 5×4 grid of emoji tiles
- Replace the same prompt in `manageProfilesFlow()` (change emoji) with the same picker
- Picker UX:
  - Tile size big enough for finger taps on iPad (~60×60px)
  - Currently-selected emoji highlighted
  - Tap-to-select, no "OK" button needed (selection commits and closes)
  - "ביטול" button to leave without changing
- The kid's existing custom emoji (if she set one via some other path) is preserved — the picker just doesn't show non-curated values, but the stored value can be anything

## Out of Scope (future)

- **Letting the parent extend the list** with custom emojis — keep curated for now
- **Color customization** alongside emoji — separate change
- **Animated/GIF avatars** — emoji-only
- **Multiple emoji combinations** (e.g., 🦋✨) — single emoji per profile
- **Emoji categories or search** — 20 is small enough that a flat grid is fine

## Impact

- **No schema change**. Profile.emoji column stays text; the picker just constrains the UI input.
- **`index.html`**: ~40 lines added (constant + render function + event handlers + small CSS). The two `prompt()` calls become picker openings.
- **Spec**: extends `families` capability — modifies the existing "Add a profile" and "Manage profiles" requirements to specify the picker UX.
- **Estimated effort**: ~30 minutes.
