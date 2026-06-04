-- Migration 007: per-lesson progress for the new lesson structure.
--
-- Each unit now has 4 lessons; completing all 4 unlocks the next unit. We
-- persist the set of completed lesson keys (e.g. "u1l1", "u1l2", ...) per
-- (profile, language) row in `progress`.
--
-- Existing rows default to an empty array — those accounts keep their
-- score-based unlocks (the client grandfathers them via a score fallback).

alter table public.progress
  add column if not exists lessons jsonb not null default '[]'::jsonb;
