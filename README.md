# Romanian for Kids 🇷🇴

A single-file web app for practicing Romanian vocabulary and sentences between tutor lessons.

Built for my 9-year-old daughter — Hebrew interface, RTL, no build step. Open `index.html` in any modern browser.

## Features

- **5 practice modes** — flashcards, multiple-choice quiz, listening (text-to-speech), matching pairs, and a pronunciation guide
- **200+ sentences** with word-by-word breakdowns, organized to repeat dictionary words across many contexts
- **Speech synthesis** — words and sentences are read aloud using the browser's `ro-RO` voice
- **Extensible dictionary** — add words and sentences from the UI, or bulk-upload a Markdown table / JSON file from the user tab
- **Local persistence** — score, streak, and user-added vocabulary are saved to `localStorage`
- **Export / import backup** — full state to JSON, restorable on another device

## Run it locally

Open the file directly:

```sh
open index.html
```

Or serve over HTTP if your browser blocks anything:

```sh
python3 -m http.server 8000
# then visit http://localhost:8000
```

## Clone

```sh
git clone git@github.com:raficohen17/kids_romanian.git
```

Or with HTTPS:

```sh
git clone https://github.com/raficohen17/kids_romanian.git
```

## Deploy to Vercel

The repo includes a `vercel.json` so import is one-click:

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import `raficohen17/kids_romanian`
3. Accept the defaults — Vercel detects a static site and serves `index.html`

Every push to `main` redeploys automatically.

## Auth + multi-family backend (optional)

The app runs in **guest mode** by default — anyone can practice with the built-in 25 words and 200 sentences; progress is stored in `localStorage`.

To enable sign-in, kid profiles, server-side persistence, and the contact-form invite flow, follow [`SETUP.md`](./SETUP.md). It's a ~10-minute Supabase setup: create a project, paste `supabase/schema.sql`, configure an auth hook, drop your keys into `config.js`. The free tier covers many families' worth of data.

## Adding more vocabulary

Two paths:

1. **One word at a time** — open the `📝 הוסיפי` tab and fill the form.
2. **Bulk upload** — open the `👤 שלי` tab → Admin section → paste a Markdown table or JSON, preview, and merge.

The admin section is gated by a 4-digit parent PIN (set on first visit, stored in `localStorage`). This is a soft lock to keep kids from accidentally wiping data — not real security.

Markdown table format (categories are sticky — empty cell inherits the previous category):

```markdown
| קטגוריה | עברית | רומנית | הגייה | הערות |
| :--- | :--- | :--- | :--- | :--- |
| **חיות** | חתול | Pisică | פִּיסִיקָה | בנקבה |
|         | סוס  | Cal    | קָאל     |       |
```

## Credit

Vibe-coded with [Claude Code](https://claude.com/claude-code).
