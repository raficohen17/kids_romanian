# Tasks: add-chat-mode

## 1. Supabase schema + RLS

- [ ] 1.1 Add a migration `supabase/migrations/003_chat.sql` that creates `chat_messages` and `chat_quotas` tables with the schema in `design.md`.
- [ ] 1.2 Add RLS policies so a profile can only `select` / `insert` its own rows; the family owner can `select` all of their family's profiles' chats (for tutor review).
- [ ] 1.3 Index `(profile_id, language, created_at desc)` on `chat_messages`.
- [ ] 1.4 Apply the migration locally via Supabase Studio; commit the SQL.

## 2. Vercel serverless function `/api/chat.js`

- [ ] 2.1 Add `api/chat.js`. Reject anything that's not POST. Read body as JSON. Reject if `vocab_snapshot.length > 500`.
- [ ] 2.2 Extract `Authorization: Bearer <token>`; call `supabase.auth.getUser(token)`. Reject 401 if invalid.
- [ ] 2.3 Verify the `profile_id` belongs to the authed user's family. Reject 403 if not.
- [ ] 2.4 Build the system prompt: language pin + vocab list + 1–3 sentences cap.
- [ ] 2.5 Call OpenRouter chat completions in JSON mode, asking for `{reply, new_words:[{ro,he,pron}], reply_he}`.
- [ ] 2.6 Validate the JSON reply; if malformed, retry once with a stricter instruction. After two failures return a friendly error string.
- [ ] 2.7 Insert the user's message and the assistant's message into `chat_messages` server-side (using the user's JWT so RLS applies).
- [ ] 2.8 Bump `chat_quotas` and reject with 429 if the daily cap is exceeded.
- [ ] 2.9 Add `vercel.json` (or in-file config) ensuring the function uses Node 18+.

## 3. Frontend mode + state

- [ ] 3.1 Add `💬 שיחה` button to the mode bar; render conditionally (`auth.session && auth.currentProfile`).
- [ ] 3.2 Add `state.chatMessages`, `state.chatPending`, `state.chatError` to `state`.
- [ ] 3.3 Add `renderChat()` and `attachChatEvents()` and wire into `render()`/dispatch.
- [ ] 3.4 On mode entry, fetch the last ~30 messages for `(profile_id, language)` from `chat_messages` and populate `state.chatMessages`.
- [ ] 3.5 On language switch or profile switch, clear `state.chatMessages` and re-fetch.

## 4. Chat UI

- [ ] 4.1 Scrolling message list. Kid bubbles right-aligned, LLM bubbles left-aligned.
- [ ] 4.2 LLM bubbles render text using the same `story-word` span machinery (hover/tap tooltip from `reply_words[]`).
- [ ] 4.3 LLM bubbles have a 🔊 play button using the existing `playStory`-style boundary highlighter, and a 🇮🇱 toggle for the Hebrew translation.
- [ ] 4.4 Composer: target-language input only; submit on Enter; disable while `state.chatPending`.
- [ ] 4.5 Show a typing indicator while waiting. Show `state.chatError` inline if the function returns an error.
- [ ] 4.6 Auto-scroll to the latest message on send/receive.

## 5. Wire frontend to `/api/chat.js`

- [ ] 5.1 Build the request body: `{ profile_id, language, message_text, vocab_snapshot, recent_messages }` (vocab snapshot from `getVocab().filter(inUnitScope)`, recent_messages from `state.chatMessages` last 10).
- [ ] 5.2 Send the Supabase JWT as `Authorization: Bearer ${session.access_token}`.
- [ ] 5.3 Append both the kid's and LLM's messages to `state.chatMessages` on success.
- [ ] 5.4 On 401, clear session and prompt re-login. On 429, show "you've hit your daily chat limit" message.

## 6. Env + config

- [ ] 6.1 Add `.env` to `.gitignore` (it is currently NOT ignored).
- [ ] 6.2 Add `OPENROUTER_API_KEY` to Vercel project env vars (no commit needed).
- [ ] 6.3 Add `OPENROUTER_MODEL` (default `anthropic/claude-haiku-4-5`) to env so we can swap models without redeploys.
- [ ] 6.4 Update `openspec/project.md` to drop the "no Vercel Functions" line and document `api/` as the backend home.

## 7. Validation

- [ ] 7.1 Manual: sign in, switch to chat mode, send a Romanian sentence, confirm the LLM replies in Romanian and that new words highlight + show tooltips.
- [ ] 7.2 Manual: switch language to English; confirm the chat history is empty for English (per-language scoping).
- [ ] 7.3 Manual: send 61 messages, confirm rate-limit kicks in.
- [ ] 7.4 Manual: sign out; confirm the chat tab disappears.
- [ ] 7.5 Manual: open DevTools network tab; confirm `OPENROUTER_API_KEY` never appears in any request.

## 8. Ship

- [ ] 8.1 Commit in chunks: migration → function → frontend → docs.
- [ ] 8.2 Open PR. PR description should include screenshots and the env vars Vercel needs.
