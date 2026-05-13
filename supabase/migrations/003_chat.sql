-- ============================================================
-- Migration 003 — Chat mode
--
-- Adds two tables for the LLM-backed Stories chat feature:
--
--   chat_messages — per-profile, per-language conversation log.
--   chat_quotas   — per-(profile, day) message counter for rate-limiting.
--
-- Idempotent: safe to run more than once.
-- ============================================================

create table if not exists public.chat_messages (
  id           uuid primary key default gen_random_uuid(),
  profile_id   uuid not null references public.profiles(id) on delete cascade,
  language     text not null check (language in ('ro','en')),
  role         text not null check (role in ('user','assistant')),
  body         text not null,
  reply_words  jsonb not null default '[]'::jsonb,
  reply_he     text,
  created_at   timestamptz not null default now()
);

create index if not exists chat_messages_profile_lang_idx
  on public.chat_messages (profile_id, language, created_at desc);

create table if not exists public.chat_quotas (
  profile_id   uuid not null references public.profiles(id) on delete cascade,
  day          date not null,
  count        int  not null default 0,
  primary key (profile_id, day)
);

alter table public.chat_messages enable row level security;
alter table public.chat_quotas   enable row level security;

-- ============================================================
-- Policies — chat_messages (scoped via profile → family)
-- Mirrors progress_family_all in schema.sql.
-- ============================================================
drop policy if exists chat_messages_family_all on public.chat_messages;
create policy chat_messages_family_all on public.chat_messages
  for all using (
    exists (
      select 1
      from public.profiles p
      join public.families f on f.id = p.family_id
      where p.id = chat_messages.profile_id and f.owner_user_id = auth.uid()
    )
    or public.is_admin()
  )
  with check (
    exists (
      select 1
      from public.profiles p
      join public.families f on f.id = p.family_id
      where p.id = chat_messages.profile_id and f.owner_user_id = auth.uid()
    )
  );

-- ============================================================
-- Policies — chat_quotas (same pattern)
-- ============================================================
drop policy if exists chat_quotas_family_all on public.chat_quotas;
create policy chat_quotas_family_all on public.chat_quotas
  for all using (
    exists (
      select 1
      from public.profiles p
      join public.families f on f.id = p.family_id
      where p.id = chat_quotas.profile_id and f.owner_user_id = auth.uid()
    )
    or public.is_admin()
  )
  with check (
    exists (
      select 1
      from public.profiles p
      join public.families f on f.id = p.family_id
      where p.id = chat_quotas.profile_id and f.owner_user_id = auth.uid()
    )
  );
