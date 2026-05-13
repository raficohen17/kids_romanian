# Tasks: add-chat-mode

## 1. Supabase schema + RLS

- [x] 1.1 Add a migration `supabase/migrations/003_chat.sql` that creates `chat_messages` and `chat_quotas` tables.
- [x] 1.2 RLS policies mirror `progress_family_all` — a profile's rows are visible only to the family owner (`f.owner_user_id = auth.uid()`), with admin override via `public.is_admin()`.
- [x] 1.3 Index `(profile_id, language, created_at desc)` on `chat_messages`.
- [ ] 1.4 Apply the migration in Supabase Studio. _**User action required** — I can't run SQL against your project. Open `supabase/migrations/003_chat.sql` and execute it in the SQL editor._

## 2. Vercel serverless function `/api/chat.js`

- [x] 2.1 `api/chat.js` rejects non-POST, parses JSON, rejects oversized `vocab_snapshot`.
- [x] 2.2 Verifies `Authorization: Bearer <token>` by calling Supabase `/auth/v1/user`; 401 on failure.
- [x] 2.3 Verifies `profile_id` ownership via a Supabase `select` using the user's JWT (RLS filters automatically); 403 if zero rows.
- [x] 2.4 Builds the system prompt: language pin + vocab list + 1–3 sentence cap + JSON-mode instructions.
- [x] 2.5 Calls OpenRouter chat completions with `response_format: {type:'json_object'}`. Default model `anthropic/claude-haiku-4-5`; override via `OPENROUTER_MODEL` env.
- [x] 2.6 Parses the JSON reply; returns 502 with detail on malformed output (no retry to keep cost low — empirically Haiku is reliable in JSON mode).
- [x] 2.7 Inserts both messages into `chat_messages` server-side using the user's JWT so RLS applies.
- [x] 2.8 Reads `chat_quotas` for today; rejects 429 if `count >= CHAT_DAILY_LIMIT` (default 60). Bumps quota after a successful turn via UPSERT (`Prefer: resolution=merge-duplicates`).
- [x] 2.9 No `vercel.json` change needed — Vercel auto-routes `/api/*` and the default Node runtime (18+) supports global `fetch`.

## 3. Frontend mode + state

- [x] 3.1 `💬 שיחה` button added to the mode bar with `data-auth-only hidden`. `applyModeVisibility()` toggles its `hidden` attribute based on `auth.session && auth.currentProfile`; if the kid was on chat mode and signs out, she's bounced back to flash.
- [x] 3.2 New state fields: `chatMessages`, `chatPending`, `chatError`, `chatLoaded`.
- [x] 3.3 `renderChat()` + `attachChatEvents()` + dispatch wiring in `render()`.
- [x] 3.4 First render triggers `fetchChatHistory()` (Supabase select scoped to active `profile_id` + `language`, 60 most-recent ascending).
- [x] 3.5 Language switch and profile switch both clear `chatMessages` and reset `chatLoaded` so the next chat entry re-fetches.

## 4. Chat UI

- [x] 4.1 Scrolling message list (`.chat-list`); user bubbles blue/left, LLM bubbles orange/right.
- [x] 4.2 LLM bubbles wrap each word as `.story-word` so the existing hover-on-desktop / tap-on-touch tooltip machinery shows Hebrew + niqqud from `reply_words[]`.
- [x] 4.3 LLM bubbles have a 🔊 button (`playChatBubble`, single-utterance with `onboundary` highlighting scoped via `data-w="chat-${msgIdx}-${wIdx}"` so multiple bubbles don't collide) and a 🇮🇱 toggle that reveals/hides `reply_he`.
- [x] 4.4 Composer is `<input dir="ltr" lang="ro|en">`, disabled while `state.chatPending`, submits on Enter.
- [x] 4.5 Animated three-dot typing indicator while pending; inline `.chat-error` for friendly error strings.
- [x] 4.6 `scrollChatToBottom()` is called after every send/receive.

## 5. Wire frontend to `/api/chat.js`

- [x] 5.1 `sendChatMessage()` builds `{ profile_id, language, message_text, vocab_snapshot, recent_messages }`; vocab snapshot is `getVocab().filter(inUnitScope).slice(0, 200).map(v => ({ro,he}))`; recent messages is the last 10 turns.
- [x] 5.2 `Authorization: Bearer ${auth.session.access_token}` header.
- [x] 5.3 On success, appends the assistant reply to `state.chatMessages`. The user message was optimistically appended before the call.
- [x] 5.4 401 → "אנא התחברי מחדש"; 429 → "הגעת למכסה היומית"; other 4xx/5xx → generic error string.

## 6. Env + config

- [x] 6.1 `.env` is in `.gitignore` (added in the previous PR).
- [x] 6.2 `.env.example` documents required vars (`OPENROUTER_API_KEY`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, optional `OPENROUTER_MODEL`, `CHAT_DAILY_LIMIT`).
- [ ] 6.3 Set `OPENROUTER_API_KEY` in Vercel project env. _**User action required** — paste it in the Vercel dashboard under Project Settings → Environment Variables._
- [x] 6.4 `openspec/project.md` updated: the "no Vercel Functions" line is gone; `/api/` is documented as the secret-holding proxy surface.

## 7. Validation (smoke-test by user)

- [ ] 7.1 Apply migration 003 in Supabase Studio.
- [ ] 7.2 Set `OPENROUTER_API_KEY` (and confirm `SUPABASE_URL`/`SUPABASE_ANON_KEY`) in Vercel env.
- [ ] 7.3 Deploy. Open the app signed-in, switch to `💬 שיחה`. Send a Romanian message; confirm a reply appears with niqqud tooltips on any new word.
- [ ] 7.4 Toggle 🇮🇱 on an LLM bubble; confirm Hebrew translation appears below.
- [ ] 7.5 Tap 🔊 on an LLM bubble; confirm words highlight as TTS speaks.
- [ ] 7.6 Switch language to English; confirm the chat history is per-language (empty if first English chat).
- [ ] 7.7 Sign out; confirm the chat tab disappears.
- [ ] 7.8 DevTools network tab: confirm the OpenRouter API key never appears in any request/response.

## 8. Ship

- [x] 8.1 Commit migration + function + frontend + docs.
- [x] 8.2 Push and open PR.
