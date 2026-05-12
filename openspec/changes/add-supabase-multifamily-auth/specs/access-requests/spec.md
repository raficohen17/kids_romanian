# access-requests Specification Delta

## ADDED Requirements

### Requirement: Guest contact form for access requests

The system SHALL provide a contact form, reachable from guest mode (e.g., a footer link "Want this for your family? Request access"), through which an unauthenticated visitor submits a name, email, and optional message. Submission SHALL INSERT a row into `access_requests` with `status = 'pending'`.

The admin's email address (`raficohen17@gmail.com`) SHALL NOT appear anywhere in the HTML, JS, or network traffic of the public app. All routing happens server-side via the `access_requests` table.

#### Scenario: Guest submits a valid request

- **WHEN** an unauthenticated visitor fills the form with `name="Yael"`, `email="yael@example.com"`, `message="cousin of Maya"`
- **AND** clicks Submit
- **THEN** a row is INSERTed into `access_requests`
- **AND** the form shows a "Thanks, we'll be in touch" confirmation
- **AND** the visitor's email is NOT mentioned to any other guest

#### Scenario: Admin email is not exposed in HTML

- **WHEN** any visitor views page source or inspects network requests
- **THEN** the literal string `raficohen17@gmail.com` SHALL NOT appear in the HTML, JS bundles, or any client-visible response

### Requirement: Anti-spam — honeypot and dwell time

The contact form SHALL include a hidden honeypot input field (CSS-hidden, off-screen, `tabindex="-1"`). If the honeypot is non-empty on submission, the client SHALL silently succeed without inserting a row.

The form SHALL also enforce a minimum dwell time: submissions occurring less than 3 seconds after the form first rendered SHALL be silently dropped.

Neither anti-spam path SHALL show an error to the visitor (to avoid teaching bots which signal tripped).

#### Scenario: Bot fills honeypot

- **WHEN** an automated submission populates the honeypot field
- **THEN** the form returns a success confirmation to the bot
- **AND** no row is INSERTed into `access_requests`

#### Scenario: Submission too fast

- **WHEN** a submission arrives less than 3 seconds after the form rendered
- **THEN** the submission is dropped
- **AND** the visitor sees the same "Thanks" confirmation

#### Scenario: Normal human submission passes

- **WHEN** a human takes 12 seconds to fill the form and leaves the honeypot empty
- **THEN** the row is INSERTed
- **AND** the "Thanks" confirmation appears

### Requirement: Anon-role INSERT permission, no read

The `access_requests` table SHALL grant `INSERT` to the anon role for the purpose of the public contact form. It SHALL NOT grant `SELECT`, `UPDATE`, or `DELETE` to anon. RLS SHALL deny all other operations to anon.

#### Scenario: Anon can insert but not read

- **WHEN** an unauthenticated client INSERTs a valid row into `access_requests`
- **THEN** the insert succeeds
- **AND** any subsequent SELECT by the same anon session returns zero rows
- **AND** no other family or non-admin authed user can SELECT either

### Requirement: Admin Requests tab with realtime updates

The system SHALL provide a "Requests" tab visible only to the admin user (Rafi). The tab SHALL list rows from `access_requests` sorted by `created_at` descending, showing email, name, message, status, and timestamps.

The tab SHALL subscribe to Supabase Realtime for `INSERT` events on `access_requests` and display a visual indicator (e.g., a red dot on the tab label) when new rows arrive while the admin is signed in.

#### Scenario: Admin sees pending requests

- **WHEN** the admin signs in and opens the Requests tab
- **THEN** all rows from `access_requests` are visible, newest first
- **AND** each row shows email, name, message snippet, status

#### Scenario: New request arrives while admin is on another tab

- **WHEN** the admin is signed in and a new row is INSERTed into `access_requests`
- **THEN** Realtime fires
- **AND** the "Requests" tab label gains a red dot indicator
- **AND** clicking the tab reveals the new row at the top of the list

#### Scenario: Non-admin parent does not see the Requests tab

- **WHEN** a non-admin authenticated parent's UI loads
- **THEN** the "Requests" tab is not rendered at all
- **AND** even if they construct the URL or call Supabase directly, RLS returns zero rows

### Requirement: Approve and reject actions

The admin SHALL be able to act on any pending request. "Approve" SHALL INSERT the requester's email into `allowed_emails` and UPDATE the row's `status` to `approved` with `reviewed_at = now()`. "Reject" SHALL UPDATE only the status to `rejected` and SHALL NOT insert into `allowed_emails`.

Optionally, the admin MAY add private `notes` on a request before or after acting.

#### Scenario: Approve adds email to allowed_emails

- **WHEN** the admin clicks "Approve" on a pending request with `email = yael@example.com`
- **THEN** a row with that email is INSERTed into `allowed_emails`
- **AND** the request's `status` is UPDATEd to `approved`
- **AND** `reviewed_at` is set to the current timestamp

#### Scenario: Reject does not grant access

- **WHEN** the admin clicks "Reject" on a pending request
- **THEN** the request's `status` is UPDATEd to `rejected`
- **AND** `allowed_emails` is NOT modified
- **AND** the requester's next sign-in attempt is rejected by the Auth Hook

#### Scenario: Approving a duplicate email is idempotent

- **WHEN** the admin clicks "Approve" on a request whose email already exists in `allowed_emails`
- **THEN** the operation does not error (`ON CONFLICT DO NOTHING`)
- **AND** the request's status is still updated to `approved`
