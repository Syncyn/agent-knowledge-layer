<!--
title: User Notification System — Implementation Plan
status: draft
owner: platform-team
created: 2024-09-15
last-updated: 2024-09-15
services: [notifications-service, payments-service, api-gateway, web-client]
-->

# User Notification System — Implementation Plan

<!--
  TEMPLATE NOTE:
  This is an example for the fictional Acme Corp notification feature.
  Notice: every step has a specific Assignee (agent type), Effort estimate,
  explicit Dependencies (enabling parallel execution), and verifiable Acceptance Criteria.
  This format allows multiple agents to work on parallel steps without coordination overhead.
-->

## Goal

Build a real-time user notification system that delivers in-app notifications via WebSocket and persists them in PostgreSQL so users can see them after page reload.

## Background and Motivation

Users currently have no way to receive real-time updates about payment completions, new messages, or other events. This causes poor UX (users must refresh) and unnecessary API polling. The design document (`design/example-feature-design.md`) covers the full rationale and design choices.

## Scope

### In Scope

- `notifications-service`: new Go service with WebSocket delivery, PostgreSQL persistence, and internal HTTP endpoint
- `payments-service`: add call to `POST /internal/notify` after payment completion
- `api-gateway`: add proxy route for `/v1/notifications/*` and `/v1/notifications/ws`
- `web-client`: connect to WebSocket, display notification badge and dropdown

### Out of Scope

- Mobile push notifications (separate plan)
- Email/SMS notifications
- Notification preferences or mute settings (v2)
- Analytics on notification open rates (v2)

---

## Implementation Steps

### Step 1: Create notifications-service scaffold

**Assignee:** backend-developer

**Effort:** Medium

**Depends on:** (none — can start immediately)

**Description:**

Create the `notifications-service` Go service with the standard project layout. Set up the PostgreSQL schema, Chi router, and dependency injection. Do not implement business logic yet — just the scaffold and health check.

**Acceptance criteria:**
- `notifications-service/` directory exists at repo root with `cmd/api/main.go`
- `GET /healthz` returns `{"status": "healthy"}` with a running database connection
- Migration script creates the `notifications` table (see design doc for schema)
- Dockerfile builds and runs locally
- `GOWORK=off go build ./...` succeeds

---

### Step 2: Implement notification persistence and internal endpoint

**Assignee:** backend-developer

**Effort:** Medium

**Depends on:** Step 1

**Description:**

Implement `POST /internal/notify` that accepts a user ID, notification type, and JSON payload, persists to PostgreSQL, and returns 201. Implement `GET /v1/notifications` that returns the authenticated user's notifications, paginated, newest-first.

**Acceptance criteria:**
- `POST /internal/notify` with valid `X-Internal-Service-Key` persists a row and returns 201
- `POST /internal/notify` without the service key returns 401
- `GET /v1/notifications` returns notifications for the authenticated user only
- Pagination works: `?limit=20&before=<notification-id>` returns the correct page
- Service tests cover both endpoints with mock repository

---

### Step 3: Implement WebSocket delivery

**Assignee:** backend-developer

**Effort:** Large

**Depends on:** Step 2

**Description:**

Add `GET /v1/notifications/ws` WebSocket endpoint. When a notification is created via `POST /internal/notify`, check if the user has an active WebSocket connection and deliver the notification in real-time. Use a `sync.Map` for the connection registry (user ID → WebSocket connection).

**Acceptance criteria:**
- A connected WebSocket client receives notifications within 500ms of `POST /internal/notify`
- A user with no active WebSocket connection receives no error — notification is persisted only
- Multiple simultaneous WebSocket connections for the same user all receive the notification
- WebSocket auth: client sends JWT in first message; invalid JWT closes the connection

---

### Step 4: Wire payments-service to call notifications-service

**Assignee:** backend-developer

**Effort:** Small

**Depends on:** Step 2 (endpoint must exist to test against)

**Description:**

After a successful payment in `payments-service`, call `POST /internal/notify` on `notifications-service`. Use a fire-and-forget pattern: log errors but do not fail the payment if notification delivery fails.

**Acceptance criteria:**
- Successful payment triggers a notification with type `payment_complete` and payload `{amount, currency}`
- If `notifications-service` is unreachable, the payment still returns 200 to the caller
- The notification call is logged (info level on success, error level on failure)
- Unit test covers: notification called on success, notification failure does not fail payment

---

### Step 5: Add api-gateway routes for notifications

**Assignee:** backend-developer

**Effort:** Small

**Depends on:** Step 2

**Description:**

Add proxy routes in `api-gateway` for all notification endpoints. The gateway handles JWT auth and forwards `X-User-ID`. The WebSocket upgrade must be proxied correctly.

**Acceptance criteria:**
- `GET /v1/notifications` proxied to `notifications-service` with `X-User-ID` header
- `POST /v1/notifications/{id}/read` proxied correctly
- WebSocket upgrade at `/v1/notifications/ws` works end-to-end from client through gateway
- No JWT required for internal notifications endpoint (not exposed through gateway)

---

### Step 6: Web client notification UI

**Assignee:** frontend-developer

**Effort:** Large

**Depends on:** Step 5 (gateway routes must be in place)

**Description:**

Add notification bell icon to the app header. Connect to the WebSocket on app load. Display unread count badge. On click, open a dropdown showing the 10 most recent notifications with mark-as-read functionality.

**Acceptance criteria:**
- Bell icon appears in header with unread count badge
- Badge count decrements when notifications are marked read
- Dropdown shows notification type icon, message, and relative time
- WebSocket reconnects automatically on disconnect (exponential backoff, max 30s)
- Notifications fetched from REST API on initial load; new notifications arrive via WebSocket

---

### Step 7: Add notifications-service to docs

**Assignee:** documentation-engineer

**Effort:** Small

**Depends on:** Step 2 (to document accurate API surface)

**Description:**

Write `docs/services/notifications-service.md` and `docs/api/notifications-service.md`. Update `docs/architecture/overview.md` to include the new service. Add INDEX.md entries.

**Acceptance criteria:**
- `docs/services/notifications-service.md` covers responsibilities, dependencies, config vars
- `docs/api/notifications-service.md` documents all three endpoints with request/response examples
- `docs/architecture/overview.md` Mermaid diagram updated to include notifications-service
- `docs/INDEX.md` updated with new entries
- All frontmatter fields populated, status: `current`

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| WebSocket connection registry causes memory leak under high load | Low | High | Use connection TTL + cleanup goroutine; load test before production |
| payments-service notification call adds latency to payment flow | Low | Medium | Use goroutine for fire-and-forget with timeout; benchmark before and after |
| PostgreSQL notifications table grows unbounded | Medium | Low | Add cleanup job in Step 1 that purges notifications older than 90 days |

## Related Documents

- [design/example-feature-design.md](../design/example-feature-design.md) — full feature design with data model and alternatives
- [adr/ADR-0001-example.md](../adr/ADR-0001-example.md) — authentication model (gateway-level auth applies to this feature)
- [architecture/example-system-topology.md](../architecture/example-system-topology.md) — system topology

## Change Log

| Date | Author | Description |
|---|---|---|
| 2024-09-15 | platform-team | Initial plan |
