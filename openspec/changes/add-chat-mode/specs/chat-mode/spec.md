# chat-mode Specification Delta

## ADDED Requirements

### Requirement: Chat mode is visible only when authenticated

The system SHALL show a `💬 שיחה` tab in the mode bar ONLY when both of the following hold:

- A Supabase session exists (`auth.session` truthy).
- A profile is currently selected (`auth.currentProfile` truthy).

When either condition is false, the tab SHALL NOT be rendered. Guests browsing the app SHALL NOT see chat at all.

#### Scenario: Guest sees no chat tab

- **WHEN** the page loads without a signed-in user
- **THEN** the mode bar contains no `💬 שיחה` button

#### Scenario: Signed-in profile sees chat tab

- **WHEN** the user is signed in AND a profile is selected
- **THEN** the mode bar contains a `💬 שיחה` button positioned after `📕 סיפורים`

#### Scenario: Profile switcher hides chat between profiles

- **GIVEN** the chat tab is currently visible
- **WHEN** the user opens the profile picker (`auth.currentProfile` becomes null)
- **THEN** the chat tab SHALL be hidden until a profile is re-selected

### Requirement: Chat sends are routed through the Vercel function

The frontend SHALL NOT call OpenRouter directly. Every chat send SHALL go to `POST /api/chat` with:

- Header: `Authorization: Bearer <supabase access token>`
- JSON body: `{ profile_id, language, message_text, vocab_snapshot, recent_messages }`

The function SHALL:

- Reject the request with HTTP 401 if the Authorization token is missing or invalid.
- Reject with HTTP 403 if `profile_id` does not belong to the authed user's family.
- Reject with HTTP 429 if the profile's daily message count exceeds the configured cap.
- Reject with HTTP 400 if `vocab_snapshot.length > 500`.
- Otherwise call OpenRouter once, write the user's and assistant's messages to `chat_messages`, increment `chat_quotas`, and return `{ reply_text, reply_words: [...], reply_he }`.

The OpenRouter API key SHALL be read from `process.env.OPENROUTER_API_KEY` and SHALL NOT appear in any response body or header.

#### Scenario: No browser access to the API key

- **WHEN** the user sends a chat message
- **AND** the network tab in DevTools is open
- **THEN** no request body, header, or response body contains the OpenRouter API key

#### Scenario: Unauth'd send is rejected

- **WHEN** a client POSTs `/api/chat` without an Authorization header
- **THEN** the response status is 401
- **AND** no OpenRouter call is made

#### Scenario: Rate limit returns 429

- **GIVEN** a profile has sent 60 messages today
- **WHEN** the profile attempts to send the 61st
- **THEN** the response status is 429
- **AND** the message is NOT written to `chat_messages`

### Requirement: Chat replies use the kid's current vocabulary

The system SHALL include the kid's in-scope vocabulary snapshot in every chat request. The snapshot is built from `getVocab().filter(inUnitScope)` and contains at least `{ro, he}` for each entry.

The system prompt SHALL instruct the model to prefer those words. The model MAY introduce new words; any word in the reply that is NOT in the snapshot SHALL be returned in `reply_words: [{ro, he, pron}]` so the frontend can render it as a hoverable tooltip with niqqud.

#### Scenario: In-vocab reply has no new_words

- **GIVEN** the kid is at Unit 3
- **AND** her vocab snapshot contains `apă`, `casă`, `mamă`
- **WHEN** the LLM replies "Mama este în casă"
- **THEN** the reply's `reply_words` is empty
- **AND** the bubble has no special-tooltip styling

#### Scenario: Out-of-vocab word gets a tooltip

- **WHEN** the LLM replies with a sentence containing `frumoasă` (not in snapshot)
- **THEN** `reply_words` contains `{ro:"frumoasă", he:"יפה", pron:"פרוּמוֹאסָה"}`
- **AND** the rendered word has a hover/tap tooltip showing the Hebrew + niqqud
- **AND** the rendered word also speaks on click via `speak()`

### Requirement: LLM bubbles support play, hover, and Hebrew toggle

Each LLM message bubble in the UI SHALL provide:

- A 🔊 play button that speaks the entire bubble using the existing word-boundary highlighter (yellow `.active` class on the current word, same component as Stories).
- Per-word hover (or tap on touch devices) for any word in `reply_words` — showing Hebrew + niqqud tooltip, same UX as Stories.
- A 🇮🇱 toggle that reveals/hides the Hebrew translation (`reply_he`) of the bubble under the original text.

The kid's own bubbles SHALL NOT have any of these affordances — her text renders plain.

#### Scenario: LLM bubble plays with highlighting

- **WHEN** the user taps 🔊 on an LLM bubble
- **THEN** TTS speaks the full text in the active language at `state.speechRate`
- **AND** the currently-spoken word has the class `active`
- **AND** the highlight clears when TTS ends

#### Scenario: Toggle reveals Hebrew

- **WHEN** the user taps 🇮🇱 on an LLM bubble
- **THEN** a Hebrew translation block appears below the original text
- **AND** a second tap hides it

#### Scenario: Kid's bubble is plain

- **WHEN** the user looks at a bubble they themselves sent
- **THEN** the bubble has no 🔊 button, no 🇮🇱 toggle, no per-word tooltips

### Requirement: History persists per-profile per-language

The system SHALL persist every chat message in the `chat_messages` Supabase table with `profile_id`, `language`, `role`, `body`, `reply_words`, and `created_at`. Loading the chat tab SHALL fetch the most recent ~30 messages for the active `(profile_id, language)` pair, ordered ascending by `created_at`.

Switching language or profile SHALL clear the in-memory message list and re-fetch from the database.

#### Scenario: Reload preserves history

- **GIVEN** the kid has sent 5 messages and seen 5 replies in Romanian
- **WHEN** she reloads the page and re-enters the chat tab
- **THEN** all 10 messages appear in order

#### Scenario: Language is scoped

- **GIVEN** there are 10 Romanian messages in history
- **WHEN** the kid switches to English mode and opens the chat tab
- **THEN** the message list is empty (no Romanian messages shown)
- **AND** previously sent English messages, if any, appear in their own thread

#### Scenario: RLS prevents cross-family reads

- **WHEN** any client attempts to `select` from `chat_messages` for a profile not in their family
- **THEN** Supabase returns zero rows
