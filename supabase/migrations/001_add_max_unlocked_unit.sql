-- Migration 001: add max_unlocked_unit to progress
-- Run this once on an existing Supabase project (already-installed schema).
-- For fresh installs, schema.sql already includes the column.

alter table public.progress
  add column if not exists max_unlocked_unit int not null default 1;
