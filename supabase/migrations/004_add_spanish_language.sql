-- Migration 004: expand language CHECK constraints to include Spanish ('es').
--
-- Tables affected:
--   progress.language       — existing rows ('ro' | 'en')
--   chat_messages.language  — existing rows ('ro' | 'en')
--
-- Approach: drop the existing CHECK constraints, recreate with the wider set.

-- progress
alter table public.progress
  drop constraint if exists progress_language_check;
alter table public.progress
  add constraint progress_language_check
  check (language in ('ro','en','es'));

-- chat_messages
alter table public.chat_messages
  drop constraint if exists chat_messages_language_check;
alter table public.chat_messages
  add constraint chat_messages_language_check
  check (language in ('ro','en','es'));
