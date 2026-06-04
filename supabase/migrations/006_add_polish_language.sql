-- Migration 006: expand language CHECK constraints to include Polish ('pl').
--
-- Tables affected:
--   vocab.language          — added in 005 with check ('ro','en','es')
--   sentences.language      — added in 005 with check ('ro','en','es')
--   progress.language       — widened in 004 to ('ro','en','es')
--   chat_messages.language  — widened in 004 to ('ro','en','es')
--
-- Approach: drop the existing CHECK constraints, recreate with the wider set.
-- This is idempotent and correct whether or not 005 was already applied with
-- the narrower ('ro','en','es') set, so we do NOT mutate the earlier migration.

-- vocab (inline column check from 005 is named <table>_<column>_check)
alter table public.vocab
  drop constraint if exists vocab_language_check;
alter table public.vocab
  add constraint vocab_language_check
  check (language in ('ro','en','es','pl'));

-- sentences
alter table public.sentences
  drop constraint if exists sentences_language_check;
alter table public.sentences
  add constraint sentences_language_check
  check (language in ('ro','en','es','pl'));

-- progress
alter table public.progress
  drop constraint if exists progress_language_check;
alter table public.progress
  add constraint progress_language_check
  check (language in ('ro','en','es','pl'));

-- chat_messages
alter table public.chat_messages
  drop constraint if exists chat_messages_language_check;
alter table public.chat_messages
  add constraint chat_messages_language_check
  check (language in ('ro','en','es','pl'));
