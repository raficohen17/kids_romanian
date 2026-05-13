-- Migration 002: add language column + composite PK to progress
-- Run this once on existing Supabase projects.
-- For fresh installs, schema.sql will include the composite key going forward.

-- 1. Add language column, default existing rows to Romanian
alter table public.progress
  add column if not exists language text not null default 'ro' check (language in ('ro','en'));

-- 2. Swap primary key from profile_id to (profile_id, language)
-- (Idempotent: skip if already done)
do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'progress_pkey'
      and pg_get_constraintdef(oid) = 'PRIMARY KEY (profile_id)'
  ) then
    alter table public.progress drop constraint progress_pkey;
    alter table public.progress add primary key (profile_id, language);
  end if;
end$$;
