-- Romanian for Kids — Supabase schema
-- Run this in the Supabase SQL editor of a fresh project.
-- Order matters: tables → indexes → RLS → policies → functions → auth hook → grants.

-- ============================================================
-- Extensions
-- ============================================================
create extension if not exists "pgcrypto";

-- ============================================================
-- Tables
-- ============================================================

create table public.allowed_emails (
  email      text primary key,
  added_at   timestamptz not null default now(),
  added_by   uuid references auth.users(id)
);

create table public.families (
  id              uuid primary key default gen_random_uuid(),
  owner_user_id   uuid not null references auth.users(id) on delete cascade,
  name            text,
  created_at      timestamptz not null default now()
);

create unique index families_owner_unique on public.families(owner_user_id);

create table public.profiles (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references public.families(id) on delete cascade,
  name        text not null,
  emoji       text not null default '🌟',
  color       text not null default '#ba68c8',
  pin         text,
  created_at  timestamptz not null default now()
);

create index profiles_family_idx on public.profiles(family_id);

create table public.vocab (
  id                   uuid primary key default gen_random_uuid(),
  family_id            uuid not null references public.families(id) on delete cascade,
  he                   text not null,
  ro                   text not null,
  pron                 text,
  cat                  text,
  emoji                text not null default '✨',
  note                 text,
  added_by_profile_id  uuid references public.profiles(id) on delete set null,
  pack_id              uuid,                          -- reserved, future pack-sharing
  created_at           timestamptz not null default now()
);

create index vocab_family_idx on public.vocab(family_id);

create table public.sentences (
  id                   uuid primary key default gen_random_uuid(),
  family_id            uuid not null references public.families(id) on delete cascade,
  he                   text not null,
  ro                   text not null,
  pron                 text,
  emoji                text not null default '💬',
  theme                text,
  words                jsonb not null default '[]'::jsonb,
  added_by_profile_id  uuid references public.profiles(id) on delete set null,
  pack_id              uuid,                          -- reserved
  created_at           timestamptz not null default now()
);

create index sentences_family_idx on public.sentences(family_id);

create table public.progress (
  profile_id          uuid not null references public.profiles(id) on delete cascade,
  language            text not null default 'ro' check (language in ('ro','en')),
  score               int not null default 0,
  best_streak         int not null default 0,
  seen                int not null default 0,
  max_unlocked_unit   int not null default 1,
  updated_at          timestamptz not null default now(),
  primary key (profile_id, language)
);

create table public.access_requests (
  id           uuid primary key default gen_random_uuid(),
  email        text not null,
  name         text,
  message      text,
  status       text not null default 'pending'
               check (status in ('pending','approved','rejected')),
  created_at   timestamptz not null default now(),
  reviewed_at  timestamptz,
  notes        text
);

create index access_requests_status_idx on public.access_requests(status, created_at desc);

-- ============================================================
-- RLS — enable on every table
-- ============================================================
alter table public.allowed_emails  enable row level security;
alter table public.families        enable row level security;
alter table public.profiles        enable row level security;
alter table public.vocab           enable row level security;
alter table public.sentences       enable row level security;
alter table public.progress        enable row level security;
alter table public.access_requests enable row level security;

-- ============================================================
-- Helper: am I admin?
-- ============================================================
create or replace function public.is_admin()
returns boolean
language sql stable
as $$
  select coalesce(
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin',
    false
  );
$$;

-- ============================================================
-- Policies — families
-- ============================================================
create policy families_owner_select on public.families
  for select using (owner_user_id = auth.uid() or public.is_admin());

create policy families_owner_insert on public.families
  for insert with check (owner_user_id = auth.uid());

create policy families_owner_update on public.families
  for update using (owner_user_id = auth.uid())
  with check (owner_user_id = auth.uid());

create policy families_owner_delete on public.families
  for delete using (owner_user_id = auth.uid());

-- ============================================================
-- Policies — profiles (scoped via family)
-- ============================================================
create policy profiles_family_all on public.profiles
  for all using (
    exists (
      select 1 from public.families f
      where f.id = profiles.family_id and f.owner_user_id = auth.uid()
    )
    or public.is_admin()
  )
  with check (
    exists (
      select 1 from public.families f
      where f.id = profiles.family_id and f.owner_user_id = auth.uid()
    )
  );

-- ============================================================
-- Policies — vocab (scoped via family)
-- ============================================================
create policy vocab_family_all on public.vocab
  for all using (
    exists (
      select 1 from public.families f
      where f.id = vocab.family_id and f.owner_user_id = auth.uid()
    )
    or public.is_admin()
  )
  with check (
    exists (
      select 1 from public.families f
      where f.id = vocab.family_id and f.owner_user_id = auth.uid()
    )
  );

-- ============================================================
-- Policies — sentences (mirror vocab)
-- ============================================================
create policy sentences_family_all on public.sentences
  for all using (
    exists (
      select 1 from public.families f
      where f.id = sentences.family_id and f.owner_user_id = auth.uid()
    )
    or public.is_admin()
  )
  with check (
    exists (
      select 1 from public.families f
      where f.id = sentences.family_id and f.owner_user_id = auth.uid()
    )
  );

-- ============================================================
-- Policies — progress (scoped via profile → family)
-- ============================================================
create policy progress_family_all on public.progress
  for all using (
    exists (
      select 1
      from public.profiles p
      join public.families f on f.id = p.family_id
      where p.id = progress.profile_id and f.owner_user_id = auth.uid()
    )
    or public.is_admin()
  )
  with check (
    exists (
      select 1
      from public.profiles p
      join public.families f on f.id = p.family_id
      where p.id = progress.profile_id and f.owner_user_id = auth.uid()
    )
  );

-- ============================================================
-- Policies — access_requests (anon INSERT, admin SELECT/UPDATE)
-- ============================================================
create policy access_requests_anon_insert on public.access_requests
  for insert
  to anon, authenticated
  with check (true);

create policy access_requests_admin_select on public.access_requests
  for select using (public.is_admin());

create policy access_requests_admin_update on public.access_requests
  for update using (public.is_admin()) with check (public.is_admin());

-- ============================================================
-- Policies — allowed_emails (admin only)
-- ============================================================
create policy allowed_emails_admin_all on public.allowed_emails
  for all using (public.is_admin()) with check (public.is_admin());

-- ============================================================
-- Auth Hook: reject sign-ups for emails not in allowed_emails
-- Register in Dashboard → Authentication → Hooks → "Before User Created"
-- ============================================================
create or replace function public.check_allowed_email(event jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  email_to_check text;
begin
  email_to_check := lower(event -> 'user_metadata' ->> 'email');
  if email_to_check is null then
    email_to_check := lower(event ->> 'email');
  end if;
  if email_to_check is null then
    email_to_check := lower(event -> 'user' ->> 'email');
  end if;

  if not exists (select 1 from public.allowed_emails where lower(email) = email_to_check) then
    return jsonb_build_object(
      'error', jsonb_build_object(
        'http_code', 403,
        'message', 'Email not on invite list. Request access via the contact form.'
      )
    );
  end if;
  return event;
end;
$$;

grant execute on function public.check_allowed_email(jsonb) to supabase_auth_admin;

-- ============================================================
-- Bootstrap helper: insert admin email + (after first sign-in) set role
-- Replace the email below with your own before running.
-- ============================================================
-- insert into public.allowed_emails(email) values ('raficohen17@gmail.com')
-- on conflict do nothing;
--
-- After signing in once with your magic link, run:
--   update auth.users
--   set raw_user_meta_data = jsonb_set(
--     coalesce(raw_user_meta_data, '{}'::jsonb), '{role}', '"admin"'
--   )
--   where email = 'raficohen17@gmail.com';
