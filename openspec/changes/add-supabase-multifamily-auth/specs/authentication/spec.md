# authentication Specification Delta

## ADDED Requirements

### Requirement: Magic-link sign-in for parents

The system SHALL allow parents to sign in via Supabase's email magic-link flow (`supabase.auth.signInWithOtp`). Sign-in MUST be passwordless. No password field SHALL be shown anywhere in the UI.

The sign-in entry point SHALL be reachable from guest mode via a "Sign in to save" call-to-action. After submitting an email, the user SHALL see a confirmation message instructing them to check their inbox.

#### Scenario: Allowed email signs in

- **WHEN** a visitor enters `parent@example.com` in the sign-in form
- **AND** that email exists in the `allowed_emails` table
- **THEN** Supabase sends a magic link to that address
- **AND** clicking the link establishes a session in their browser
- **AND** the user is taken to the profile picker (or to first-profile setup if no family exists yet)

#### Scenario: Non-allowed email is rejected at signup

- **WHEN** a visitor enters an email NOT present in `allowed_emails`
- **THEN** the Supabase Auth Hook rejects the sign-up before sending the magic link
- **AND** the UI displays a message inviting them to request access via the contact form

#### Scenario: Returning user lands directly in their account

- **WHEN** a previously signed-in user opens the app
- **AND** their Supabase session is still valid (refresh token not expired)
- **THEN** the guest UI SHALL NOT appear
- **AND** the user is taken straight to the profile picker

### Requirement: Sign-out clears session and returns to guest

The system SHALL provide a sign-out action accessible from the profile picker and from any signed-in view. Sign-out MUST call `supabase.auth.signOut()` and clear any cached profile state in JavaScript memory.

#### Scenario: User signs out

- **WHEN** a signed-in user clicks "Sign out"
- **THEN** the Supabase session is cleared
- **AND** the app returns to the public guest landing
- **AND** subsequent app interactions show built-in corpus only with no save buttons

#### Scenario: Sign-out preserves localStorage guest progress

- **WHEN** a signed-in user signs out
- **THEN** any score/streak written to localStorage during prior guest visits remains intact
- **AND** the next guest-mode session resumes from that localStorage state

### Requirement: Single admin via user metadata

The system SHALL recognize exactly one administrative user, identified by `auth.users.raw_user_meta_data ->> 'role' = 'admin'`. Admin-only operations (reading `access_requests`, inserting into `allowed_emails`) SHALL be gated by this check in RLS policies.

The admin flag SHALL NOT be settable from the client UI. It MUST be applied manually via the Supabase dashboard or SQL editor.

#### Scenario: Admin user sees access requests

- **WHEN** the admin user is signed in
- **THEN** their session is authorized by RLS to SELECT from `access_requests`
- **AND** they can see all rows regardless of `status`

#### Scenario: Non-admin family parent cannot see access requests

- **WHEN** a non-admin authenticated user attempts to SELECT from `access_requests`
- **THEN** RLS returns zero rows
- **AND** no error or partial data leaks to the client

### Requirement: Session persistence across page reloads

The system SHALL use Supabase's default session storage (persistent in `localStorage` via the SDK) so that page reload does NOT log the user out.

#### Scenario: Page reload preserves session

- **WHEN** a signed-in user reloads the page
- **THEN** the app detects the existing session via `supabase.auth.getSession()`
- **AND** restores them to their last-selected profile (or profile picker if none selected this session)
- **AND** no magic-link round-trip is required
