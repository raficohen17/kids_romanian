-- Migration 005: per-language tagging for user-added vocab and sentences.
--
-- Before this migration, every row in `vocab` and `sentences` was implicitly
-- Romanian — the client filtered by `(v.language || 'ro') === state.language`
-- and the column did not exist, so adding custom words while in English (or
-- Spanish) mode never showed them in the practice modes after reload.
--
-- We default existing rows to 'ro' (matches the implicit assumption to date).

alter table public.vocab
  add column if not exists language text not null default 'ro'
  check (language in ('ro','en','es'));

alter table public.sentences
  add column if not exists language text not null default 'ro'
  check (language in ('ro','en','es'));

create index if not exists vocab_family_lang_idx on public.vocab(family_id, language);
create index if not exists sentences_family_lang_idx on public.sentences(family_id, language);
