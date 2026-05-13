# Design: add-chat-mode

## Context

The app today is purely a static HTML page hosted by Vercel + a Supabase backend for auth/data. There is no Vercel serverless function and `openspec/project.md` calls that out explicitly ("no Vercel Functions, no email service"). Chat changes that — we need a server side that can hold the OpenRouter API key, validate Supabase JWTs, and call the LLM.

The kid practices in cycles: a unit unlocks vocabulary and sentences, she practices, the unit gates a story or quiz, the tutor reviews. Chat is the missing "produce" step: she generates text instead of recognizing it. The crucial constraint from the tutor's perspective is **stay close to her current vocabulary**, with new words as occasional teaching beats — not a flood.

## Goals / Non-Goals

**Goals**
- A signed-in kid can chat with an LLM partner in her active target language.
- The LLM heavily prefers words in her current in-scope vocab.
- Any out-of-vocab word the LLM uses becomes a hover/tap word with Hebrew + niqqud, just like in Stories.
- Auth is enforced server-side. The OpenRouter key never leaves the function.
- History persists per-profile + per-language in Supabase.

**Non-Goals**
- No voice / STT.
- No images.
- No streaming responses.
- No multi-user chat.
- No background generation or push.
- No long-running session memory beyond N most-recent turns.

## Key Decisions

### Decision 1: Vercel Function as proxy, not a separate backend

Add `/api/chat.js` next to `index.html`. Vercel auto-routes anything in `api/` as a serverless function. It:

1. Reads `OPENROUTER_API_KEY` from `process.env`.
2. Verifies the `Authorization: Bearer <jwt>` header against Supabase's public `SUPABASE_URL` + `anon` key by calling `auth.getUser(token)`. Reject if invalid.
3. Loads the active profile's family scope (so the function can also enforce "this profile_id belongs to this user").
4. Reads (or trusts) the vocab snapshot from the request body. Bound the size — reject if `vocab_snapshot.length > 500` to avoid DoS.
5. Builds the OpenRouter prompt and calls the chat completions endpoint.
6. Annotates out-of-vocab words by running a tiny second LLM pass that returns `[{ro, he, pron}]` for any word not in the snapshot.
7. Writes both the user's and LLM's messages to `chat_messages` server-side.

**Rationale.** Browser direct → leaks key. Supabase Edge Function → another deploy surface and Deno runtime. Vercel function is colocated with the HTML, deploys with the same `git push`, uses the same Node ecosystem, and Vercel's free tier covers our volume.

**Trade-off.** Deviates from `openspec/project.md` ("no Vercel Functions"). The cost is one function — minimal new ops. Once this lands, `project.md` should be updated to allow `api/` functions; we'll update it as part of the apply.

### Decision 2: Soft vocab constraint via system prompt, annotation step for new words

The system prompt looks like:

> You are a friendly Romanian/English chat partner for a 9-year-old Hebrew speaker named Maya. She has been learning {language} and knows roughly these words: {list of {ro, he} from her in-scope vocab}. Use these words whenever possible. You MAY introduce a few new useful words but keep it simple. Reply in {language} only. 1–3 sentences max.

If the model is well-instructed, this works. If it slips outside vocab, we don't block — we annotate. A second call (or a tool-use call in the same turn) extracts any out-of-vocab word and produces `{ ro, he, pron }`. That annotation is what the client renders as a hoverable tooltip.

**Rationale.** Hard re-prompting on every reply doubles cost and produces stiff Romanian. The kid encountering a new word with a tooltip is the actual desired learning event.

**Alternative considered.** Token-level filtering with constrained sampling. Not supported by OpenRouter at this layer; would require a custom model. Out of scope.

### Decision 3: Persistence schema

```
chat_messages
  id           uuid primary key
  profile_id   uuid not null references profiles
  language     text not null check (language in ('ro','en'))
  role         text not null check (role in ('user','assistant'))
  body         text not null
  reply_words  jsonb not null default '[]'  -- only for assistant rows
  created_at   timestamptz default now()
  -- indexed by (profile_id, language, created_at desc)

chat_quotas
  profile_id   uuid primary key references profiles
  day          date not null
  count        int not null default 0
  -- composite primary key would be (profile_id, day); simpler form here
```

RLS: a profile's messages are visible only to the family that owns the profile (same pattern as `progress`). The Vercel function uses the user's JWT to read/write so RLS applies naturally.

**Rationale.** Matches the existing per-profile + per-language sharding used by `progress`. No new admin tooling needed. `reply_words` is denormalized JSONB so the client can render tooltips without a second fetch.

### Decision 4: Render LLM bubbles using the existing story-word component

The Stories mode already has hover/tap word interactions, niqqud tooltips, and TTS-onboundary highlighting. We reuse those primitives. The kid's bubbles are plain text (no per-word tooltip — she wrote them, she knows what she meant). The LLM's bubbles get the full treatment.

**Rationale.** Two visual languages would be confusing. One mental model: "yellow when speaking, hover for meaning" works everywhere.

### Decision 5: Translate button per LLM bubble

Each LLM bubble has a small 🇮🇱 button that toggles a Hebrew translation under the original. The Hebrew is requested as part of the same `/api/chat.js` response (a `reply_he` field), so no second call.

**Rationale.** Lower friction than highlighting every word, and matches the user's "target language only" input preference — she sees Romanian first, falls back to Hebrew only if stuck.

## Risks / Trade-offs

- **Annotation cost**: doubling the LLM call to extract new words doubles tokens. Mitigation: ask for the annotation in the *same* JSON-mode reply, e.g. ask the model to return `{reply: ..., new_words: [...], reply_he: ...}` in one shot.
- **Vocab snapshot size**: at full Unit 10 the kid will have ~245 vocab + ~800 sentences. Sending all that on every turn is wasteful. Mitigation: send only `getVocab()` (not sentences) and cap at 500. Sentences inform context too but tokenizing them every turn is heavy.
- **Cost ceiling**: 60 messages/day × Haiku-class model × ~1k tokens/turn ≈ pennies/day. Acceptable.
- **Latency**: one LLM call per turn = 1–3 seconds. Fine for a chat UX with a typing indicator.
- **Model choice**: default to a Haiku-class model via OpenRouter (`anthropic/claude-haiku-4-5` or equivalent). Configurable via env var.
- **Auth coupling**: if Supabase JWT verification fails we don't fall back to "guest chat" — we just hide the tab. Avoids accidentally exposing the key to anyone with the page.

## Migration / Compatibility

- New tables only — additive. No backfill.
- The chat tab is hidden until the user is signed-in AND a profile is selected, so existing flows are unchanged.
- Existing modes use no backend; this is the first one that does. After this lands, `openspec/project.md` should drop the "no Vercel Functions" line.
- No change to `state.language`, `state.currentUnit`, or any other persisted state.

## Open Questions

- **Cold-start latency** on Vercel Hobby tier: probably ~300ms-1s, acceptable for chat.
- **Whether the annotation step needs niqqud lint**: probably not for v1 — niqqud quality is the LLM's responsibility for chat. We could lint later if the tutor flags drift.
- **Streaming responses**: would improve perceived latency. Defer to v2 unless turn-around feels sluggish.
