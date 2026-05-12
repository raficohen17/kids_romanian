# guest-mode Specification Delta

## ADDED Requirements

### Requirement: Public app loads without authentication

The system SHALL be fully reachable by any visitor without requiring sign-in. The default landing state SHALL be guest mode. The Supabase JS SDK SHALL load but no auth or data calls SHALL fire until the user signs in or submits the contact form.

#### Scenario: Anonymous visitor opens the URL

- **WHEN** a visitor opens the site without any prior session
- **THEN** the page renders the practice UI with the built-in 25 words and 200 sentences
- **AND** no Supabase HTTP requests fire (DevTools Network tab confirms)
- **AND** a "Sign in to save" call-to-action is visible

#### Scenario: Cleared cache returns to guest

- **WHEN** a previously signed-in user clears their browser storage and reloads
- **THEN** the app loads in guest mode
- **AND** their previous server-side data is untouched on Supabase and will be available again on sign-in

### Requirement: Built-in corpus accessible in guest mode

Guest mode SHALL expose all 25 built-in words, all 200 built-in sentences, the pronunciation guide, and all five practice modes (flashcards, quiz, listening, matching, sentences). These come from JavaScript constants in `index.html`, not from Supabase.

#### Scenario: All practice modes work for guests

- **WHEN** an unauthenticated visitor navigates between the 5 practice modes
- **THEN** each mode loads with the built-in corpus
- **AND** the listening mode uses `SpeechSynthesis` (`ro-RO`) as normal
- **AND** the pronunciation guide table renders

### Requirement: Score and streak persist in localStorage for guests

Guest score, streak, and seen-count SHALL be persisted to `localStorage` under a dedicated key. They SHALL be read on page load and written on each correct answer or session end.

This data SHALL NOT sync to Supabase. It SHALL vanish if the user clears site data.

#### Scenario: Guest answers correctly, score increments locally

- **WHEN** a guest answers a quiz item correctly
- **THEN** the score increments in JS state
- **AND** the updated score is written to localStorage
- **AND** no Supabase write occurs

#### Scenario: Guest reloads, progress restored from localStorage

- **WHEN** a guest with score 30 reloads the page
- **THEN** the app reads the stored value
- **AND** the stats display "30 points"

#### Scenario: Guest clears site data, progress lost

- **WHEN** a guest clears browser storage
- **AND** reopens the app
- **THEN** the score resets to 0
- **AND** there is no way to recover this guest progress (by design — there's no server record)

### Requirement: Save and add features disabled for guests

In guest mode, the following operations SHALL be disabled or surface a sign-in prompt:

- Adding a word from the "Add" form
- Adding a sentence from the "Add" form
- Bulk import (Markdown / JSON)
- Editing or deleting existing words
- Accessing the admin/user tab admin section

The sign-in prompt SHALL be a non-blocking call-to-action, not a hard wall — guests can still practice freely.

#### Scenario: Guest clicks "Add word"

- **WHEN** an unauthenticated visitor opens the add-word UI
- **THEN** the form fields are visible but disabled, or
- **OR** a clear "Sign in to save your words" message replaces the form
- **AND** no row is INSERTed anywhere even if the visitor manipulates the DOM

#### Scenario: Guest sees sign-in CTA without nagging

- **WHEN** a guest is on the practice tab
- **THEN** a "Sign in to save progress" banner or link is visible
- **AND** the banner does not modally interrupt practice
- **AND** dismissing it persists the dismissal for the session (optional polish)

### Requirement: Guest sees the contact-form entry point

Guest mode SHALL surface the access-request contact form (e.g., as a footer link or a dedicated CTA elsewhere). The form is the only way for outsiders to request being added to `allowed_emails`.

#### Scenario: Guest finds and submits the contact form

- **WHEN** a guest scrolls to the footer
- **THEN** they see a "Request access for your family" link
- **AND** clicking it opens the contact form modal
- **AND** submission is anon-role INSERT into `access_requests` (see access-requests spec)
