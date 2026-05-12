// Copy this file to `config.js` and fill in the values from your Supabase project.
// `config.js` is gitignored so it never reaches the public repo.
//
// Where to find these:
//   Supabase Dashboard → Project Settings → API
//
// Note: the anon key is *meant* to be public. Row-Level Security (RLS) is what
// actually protects your data, not the key. See supabase/schema.sql for policies.
window.APP_CONFIG = {
  SUPABASE_URL:      "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "eyJ...your-anon-key...",
};
