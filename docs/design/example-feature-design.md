<!--
title: User Notification System Design
status: proposed
owner: platform-team
created: 2024-09-10
last-updated: 2024-09-10
services: [users-service, api-gateway, web-client]
-->

# User Notification System Design

<!--
  TEMPLATE NOTE:
  This is an example design document for a fictional notification feature on the
  Acme Corp platform. Replace with your actual feature. Design docs are written
  BEFORE or DURING implementation — they capture intent, not just outcome.
-->

## Problem Statement

Acme users have no way to receive real-time updates about events relevant to them (e.g., a payment completing, a new message, a promotional offer). Currently, users must poll the API or refresh the page to see state changes. This creates poor UX and excess API traffic.

## Goals

- Users receive real-time in-app notifications without polling
- Notifications are persisted so users can see them after page reload
- The system handles at least 1,000 concurrent connected clients
- Implementation does not require changes to `payments-service` or other upstream services

## Non-Goals

- Push notifications to mobile devices (deferred to a future phase)
- Email or SMS notifications (separate system, separate plan)
- Notification preferences / mute settings (v2)
- Analytics on notification open rates (v2)

## Design Overview

Introduce a `notifications-service` that receives events from upstream services via a message queue (SQS) and delivers them to connected web clients via WebSocket. The web client maintains a persistent WebSocket connection to the notifications service. Upstream services publish events by calling an internal HTTP endpoint on the notifications service — no direct queue access required from upstream services.

## Detailed Design

### Data Model

Notifications are stored in PostgreSQL in the `notifications` table:

```sql
CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     TEXT NOT NULL,
    type        TEXT NOT NULL,          -- e.g. 'payment_complete', 'new_message'
    payload     JSONB,                  -- event-specific data
    read_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_unread
    ON notifications (user_id, created_at DESC)
    WHERE read_at IS NULL;
```

Notifications are not deleted — they are marked read. The index on unread notifications supports the common query pattern (fetch unread for user).

### API Changes

**New service: `notifications-service`**

`POST /internal/notify` (internal only, `X-Internal-Service-Key` required)
```json
{
  "user_id": "user-123",
  "type": "payment_complete",
  "payload": { "amount": 99.00, "currency": "USD" }
}
```

`GET /v1/notifications` (JWT auth via api-gateway)
Returns paginated list of notifications for the authenticated user.

`POST /v1/notifications/{id}/read` (JWT auth)
Marks a notification as read.

`GET /v1/notifications/ws` (JWT auth, upgrades to WebSocket)
WebSocket endpoint for real-time delivery.

**Changes to existing services:**

`payments-service` adds a call to `POST /internal/notify` after a payment completes successfully. No other service changes required.

### Flow Diagram

```
Payment completes
       │
       ▼
payments-service
  POST /internal/notify
       │
       ▼
notifications-service
  1. Persists to PostgreSQL
  2. Looks up active WebSocket connection for user_id
  3. Delivers via WebSocket if connected
       │
       ▼
Web client
  Receives notification, updates UI badge
```

### Error Handling

- If `notifications-service` is unavailable when `payments-service` tries to notify: log the error, do not fail the payment. Notifications are best-effort; payment integrity is primary.
- If the user is not connected via WebSocket: persist the notification only. Client will fetch on next connection.
- If WebSocket delivery fails: mark delivery as failed in the DB; do not retry (client fetches on reconnect).

## Alternatives Considered

**1. Server-Sent Events (SSE) instead of WebSocket**

SSE is simpler for unidirectional server-to-client delivery, which is all we need here. However, we may want bidirectional communication in a future version (e.g., client acknowledging receipt). WebSocket keeps the option open at minimal additional complexity.

**2. Direct SQS access from upstream services**

Having `payments-service` publish directly to SQS decouples it from `notifications-service` availability but introduces SQS as a new dependency for `payments-service`. Using an internal HTTP call to `notifications-service` keeps SQS as an internal implementation detail — `payments-service` doesn't need to know or care about the queuing strategy.

## Open Questions

- What is the retention policy for read notifications? (30 days? 90 days?)
- Do we need notification categories or priority levels in v1?
- Should the WebSocket endpoint be on `notifications-service` or proxied through `api-gateway`?

## Related Documents

- [architecture/overview.md](../architecture/example-system-topology.md) — system topology (api-gateway proxy pattern)
- [adr/ADR-0001-example.md](../adr/ADR-0001-example.md) — JWT authentication model (gateway-level auth applies here)

## Change Log

| Date | Author | Description |
|---|---|---|
| 2024-09-10 | platform-team | Initial draft |
