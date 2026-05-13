# Tasks: add-profile-emoji-picker

Small UI change. One sitting.

- [ ] 1. Define `PROFILE_EMOJIS` constant in `index.html` with the 20 curated emojis
- [ ] 2. Add CSS for the emoji-picker modal: `.emoji-picker-modal`, `.emoji-grid`, `.emoji-tile`, `.emoji-tile.selected`
- [ ] 3. Write `openEmojiPicker({ current, onSelect, onCancel })` helper that renders the modal and wires events
- [ ] 4. Modify `createProfileFlow()`:
  - keep the name prompt
  - replace the emoji `prompt()` with `openEmojiPicker`
  - on cancel, default emoji to `'🌟'` and proceed with insert
- [ ] 5. Modify `manageProfilesFlow()` action 2 ("change emoji"):
  - replace the `prompt()` with `openEmojiPicker`
  - persist selection via existing `update profiles set emoji = ...`
- [ ] 6. Validate JS parses
- [ ] 7. Manual smoke: create a new profile with each different emoji; change a profile's emoji from manage flow; cancel-paths leave state unchanged
- [ ] 8. `openspec validate add-profile-emoji-picker --strict` passes
