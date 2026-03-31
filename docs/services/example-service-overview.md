<!--
title: users-service Service Documentation
status: current
owner: platform-team
created: 2024-06-01
last-updated: 2024-11-15
services: [users-service]
-->

# users-service

<!--
  TEMPLATE NOTE:
  This is an example service doc for the fictional Acme Corp users-service.
  Notice the Callers and Calls sections — these are the most important parts
  for agents, because they prevent broken inter-service contracts.
  Also notice Known Issues — agents should know what's broken before they touch code.
-->

## Service Overview

| Field | Value |
|---|---|
| Language / Runtime | Go 1.23 |
| Repository | `users-service/` |
| Primary responsibilities | User profile CRUD, avatar upload (WebP conversion + S3 pre-signed URLs), account credits, connection management |
| Key internal dependencies | `shared-lib` — CORS middleware, database client constructors |
| Key external dependencies | PostgreSQL (users-db); S3 (acme-media bucket); `notifications-service` (internal HTTP) |

## Callers

Who calls this service and what they call:

| Caller | Endpoint / Purpose | Auth |
|---|---|---|
| `api-gateway` | All `/v1/*` routes (proxied from clients) | `X-User-ID` header forwarded after JWT verification |
| `payments-service` | `POST /internal/users/{id}/credits` — credit user after purchase | `X-Internal-Service-Key` |

## Calls

What this service calls:

| Dependency | Purpose | Auth |
|---|---|---|
| PostgreSQL (`users-db`) | Primary data store for profiles, credits, connections | Connection string (`DATABASE_URL`) |
| S3 (`acme-media` bucket) | Avatar image storage; service generates pre-signed upload URLs | AWS IAM role attached to ECS task |
| `notifications-service` | `POST /internal/notify` — notify user after credit received | `X-Internal-Service-Key` |

---

## Architecture Notes

### Layered structure

```
cmd/api/main.go          — entry point, Chi router setup, graceful shutdown
internal/
  auth/                  — reads X-User-ID from request context (does not verify JWT)
  config/                — environment variable loading
  db/                    — pgxpool connection and health check
  handler/               — HTTP handlers
  repository/
    interfaces.go        — UserRepository, CreditRepository interfaces
    postgres.go          — PostgreSQL implementations
  service/
    users.go             — user CRUD business logic
    credits.go           — credit management
    users_test.go        — service-level tests (package service, not package service_test)
```

### Repository interfaces pattern

`internal/repository/interfaces.go` defines `UserRepository` and `CreditRepository` interfaces. The service layer always accepts these interfaces, never the concrete PostgreSQL types. This is what enables mock-based service testing without a live database.

**When adding a new database operation:** add the method to the interface in `interfaces.go` first, then implement it in `postgres.go`, then use it in the service.

### Avatar upload flow

The service does not accept image uploads directly. Instead:

1. Client calls `POST /v1/users/me/avatar` → service returns a pre-signed S3 URL
2. Client uploads directly to S3
3. Client calls `POST /v1/users/me/avatar/confirm` → service updates the user's `avatar_url` in PostgreSQL

This avoids the service becoming a proxy for binary uploads. Image resizing and WebP conversion happen via a separate S3-triggered Lambda (not part of this service).

### Test approach

Service-layer tests use hand-written mock repositories (`testify/mock`). Handler-layer tests use `httptest.NewRequest` + `httptest.NewRecorder`. Integration tests against a real PostgreSQL instance are run in CI via a Docker Compose setup.

Key: test package is `package service` (not `package service_test`) — tests are in the same package as the code they test, giving access to unexported functions.

---

## Configuration

| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | Yes | — | PostgreSQL connection string. Example: `postgres://user:pass@host:5432/users-db` |
| `INTERNAL_SERVICE_KEY` | Yes | — | Shared secret for `X-Internal-Service-Key` validation on internal routes |
| `AWS_REGION` | Yes | — | AWS region for S3 pre-signed URL generation |
| `S3_MEDIA_BUCKET` | Yes | — | S3 bucket name for avatar storage |
| `PORT` | No | `8080` | HTTP listen port |
| `LOG_LEVEL` | No | `info` | Log level: `debug`, `info`, `warn`, `error` |

---

## Known Issues

- **Avatar confirm race condition:** If the client calls `POST /v1/users/me/avatar/confirm` before the S3 PUT completes, the `avatar_url` is updated to a URL that doesn't yet serve the image. The Lambda resizer handles this eventually, but there's a window of broken avatar URLs. Tracked: GH-412.

- **Credits endpoint not idempotent in edge case:** If `payments-service` retries `POST /internal/users/{id}/credits` with the same `reference_id` within 50ms of the first call, both may succeed (race condition in the idempotency check). In practice this has not caused double-credits in production. Fix planned in next quarter.

- **No pagination on `/v1/users/{id}/connections`:** Returns all connections without a limit. At high connection counts this will cause slow responses. Tracked: GH-438.
