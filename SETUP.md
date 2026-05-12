# Supabase Setup

The app works without any backend — open `index.html` and you get guest mode with the built-in 25 words + 200 sentences. To enable sign-in, family profiles, server-side persistence, and the invite-by-contact-form flow, follow the steps below. ~10 minutes one-time.

## 1. Create a Supabase project

1. Sign up / sign in at [supabase.com](https://supabase.com)
2. **New project** → pick any name, set a strong database password (you won't need it for the app), choose the closest region
3. Wait ~2 minutes for provisioning
4. From **Project Settings → API**, copy:
   - **Project URL** (e.g. `https://abcdefgh.supabase.co`)
   - **anon public key** (the `eyJ...` JWT — safe to publish; RLS is the real security)

## 2. Run the schema

1. Open **SQL Editor** in your Supabase dashboard
2. Open `supabase/schema.sql` from this repo, paste the whole thing, click **Run**
3. You should see "Success. No rows returned." Tables, RLS, policies, and the auth-hook function are now installed.

## 3. Configure the Auth Hook

Supabase needs to call the `check_allowed_email` function to reject sign-ups for emails that aren't on your invite list.

1. Go to **Authentication → Hooks**
2. Add hook: **Before User Created**
3. **Hook function**: `public.check_allowed_email`
4. Save

## 4. Add yourself to `allowed_emails`

In the SQL Editor:

```sql
insert into public.allowed_emails(email) values ('raficohen17@gmail.com')
on conflict do nothing;
```

(Replace with your own email.)

## 5. Configure auth providers

1. **Authentication → Providers → Email**
2. Make sure **Enable Email provider** is on
3. **Disable** "Confirm email" (magic link IS the confirmation — toggle off the second confirmation step)
4. **Disable** "Allow new users to sign up" — your hook handles this; keeping the global flag off adds defense in depth
5. Under **Authentication → URL Configuration**, set your **Site URL** to your Vercel domain (or `http://localhost:8080` for local testing)

## 6. Sign in once to provision your user row

1. In a fresh browser tab, open your deployed app (after step 7 below)
2. Click **Sign in**, enter your admin email
3. Check your inbox, click the magic link
4. You should land back on the app, signed in

## 7. Promote yourself to admin

Now that your `auth.users` row exists, give it the admin role. Back in the SQL Editor:

```sql
update auth.users
set raw_user_meta_data = jsonb_set(
  coalesce(raw_user_meta_data, '{}'::jsonb), '{role}', '"admin"'
)
where email = 'raficohen17@gmail.com';
```

Sign out and sign back in once so the new JWT carries `role: admin`. Now the **Requests** tab is visible to you, and `access_requests` / `allowed_emails` are writable.

## 8. Plug the keys into the app

1. Copy `config.example.js` → `config.js` (which is gitignored)
2. Paste your **Project URL** and **anon key** into the values
3. Reload the app

```js
// config.js  — committed example shows the shape; this file holds your real values
window.APP_CONFIG = {
  SUPABASE_URL:      "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "eyJ...your-anon-key...",
};
```

## 9. Approve another family

1. They visit your URL, scroll to the footer, click **Request access**, fill the form
2. A red dot appears on your **Requests** tab (Realtime)
3. Click **Approve** → their email is inserted into `allowed_emails`
4. They sign in with magic link → it goes through the auth hook → they're in

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| "Email not on invite list" when signing in | You haven't run step 4, or the auth hook isn't wired (step 3) |
| Magic link email never arrives | Check spam; verify email provider enabled (step 5) |
| "Requests" tab not visible after sign-in | Step 7 wasn't run, or you didn't sign out/in to refresh the JWT |
| Console: `Cannot read properties of undefined (reading 'SUPABASE_URL')` | `config.js` missing or has a typo (step 8) |
| RLS denying queries you expect to work | Your auth.uid() doesn't match the row's owner; or you're in guest mode |
| Realtime indicator not firing | Realtime must be enabled per-table in **Database → Replication** for `access_requests` |

## Migrating your existing localStorage

The data layer doesn't auto-migrate. If you've already added words on this device:

1. While signed out (or before configuring `config.js`), open the user/admin tab
2. Click **Export backup** → saves a JSON file
3. Configure Supabase (steps 1–8 above), sign in, pick a profile
4. Open user/admin → **Import backup** → upload the JSON → words land in your family pool

## Cost reality

Supabase free tier covers ~10,000 families' worth of data and 50K monthly auth users. You'll never approach the limits at family scale. The project pauses after 7 days of zero traffic; first request wakes it in under a second.
