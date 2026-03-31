<!--
title: users-service API Reference
status: current
owner: platform-team
created: 2024-06-01
last-updated: 2024-11-15
services: [users-service]
-->

# users-service API Reference

<!--
  TEMPLATE NOTE:
  This is an example API reference for the fictional Acme Corp users-service.
  Replace with your actual service's endpoints.
  Keep examples realistic — agents use these to write client code and tests.
-->

## Overview

`users-service` manages user profiles, preferences, and connections. It is accessed through `api-gateway`, which handles JWT verification and forwards `X-User-ID`.

**Base URL:** `https://api.acme.io/v1/users`
**API version:** `v1`
**Internal base URL (service-to-service):** `http://users-service.internal/internal`

## Authentication

All `/v1/` endpoints require the request to pass through `api-gateway`. The gateway verifies the JWT and forwards:

```
X-User-ID: <authenticated-user-id>
```

`users-service` reads `X-User-ID` and does not perform JWT verification (see ADR-0001).

Internal endpoints (`/internal/*`) require:

```
X-Internal-Service-Key: <shared-secret>
```

The `GET /healthz` endpoint requires no authentication.

---

## Endpoints

### `GET /healthz`

Health check. Returns database connectivity status.

**Auth:** None

**Response (200):**
```json
{"status": "healthy", "database": "up"}
```

**Response (503):**
```json
{"status": "unhealthy", "database": "down", "error": "connection refused"}
```

---

### `GET /v1/users/me`

Returns the authenticated user's profile.

**Auth:** `X-User-ID` header (via api-gateway)

**Response (200):**
```json
{
  "id": "user-123",
  "email": "alice@example.com",
  "display_name": "Alice Smith",
  "avatar_url": "https://cdn.acme.io/avatars/user-123.webp",
  "created_at": "2024-06-01T10:00:00Z"
}
```

**Response (404):** User record not found (first-login edge case).

---

### `GET /v1/users/{id}`

Returns a user's public profile. Any authenticated user can view any other user's profile.

**Auth:** `X-User-ID` header (via api-gateway)

**Path parameters:**
- `id` — user ID

**Response (200):**
```json
{
  "id": "user-456",
  "display_name": "Bob Jones",
  "avatar_url": "https://cdn.acme.io/avatars/user-456.webp"
}
```
Note: email is not included in the public profile response.

**Response (404):**
```json
{"error": "user not found"}
```

---

### `PUT /v1/users/me`

Updates the authenticated user's profile.

**Auth:** `X-User-ID` header (via api-gateway)

**Request body:**
```json
{
  "display_name": "Alice Smith Updated",
  "avatar_url": "https://cdn.acme.io/avatars/user-123-new.webp"
}
```
All fields are optional. Omitted fields are not changed.

**Response (200):** Updated profile (same schema as `GET /v1/users/me`)

**Response (400):**
```json
{"error": "display_name must be between 2 and 50 characters"}
```

---

### `POST /v1/users/me/avatar`

Upload a new avatar image. Returns a pre-signed S3 URL for direct browser upload.

**Auth:** `X-User-ID` header (via api-gateway)

**Request body:**
```json
{
  "content_type": "image/jpeg",
  "file_size_bytes": 204800
}
```

**Response (200):**
```json
{
  "upload_url": "https://acme-media.s3.amazonaws.com/avatars/user-123.jpg?X-Amz-...",
  "expires_at": "2024-11-15T12:05:00Z"
}
```

After receiving this response, the client uploads the image directly to S3 using a PUT request to `upload_url`. The avatar is not visible until `POST /v1/users/me/avatar/confirm` is called.

**Response (413):**
```json
{"error": "file_size_bytes exceeds maximum of 5MB"}
```

---

### `POST /v1/users/me/avatar/confirm`

Confirms that the avatar upload to S3 is complete. Updates the user's `avatar_url`.

**Auth:** `X-User-ID` header (via api-gateway)

**Response (200):**
```json
{"avatar_url": "https://cdn.acme.io/avatars/user-123.webp"}
```

---

### `POST /internal/users/{id}/credits`

Internal endpoint. Credits the user's account balance. Called by `payments-service` after a successful purchase.

**Auth:** `X-Internal-Service-Key` header

**Path parameters:**
- `id` — user ID

**Request body:**
```json
{
  "amount": 99.00,
  "currency": "USD",
  "source": "purchase",
  "reference_id": "payment-789"
}
```

**Response (200):**
```json
{"new_balance": 198.00, "currency": "USD"}
```

**Response (401):** Missing or invalid service key.

**Response (404):** User not found.

**Response (409):** `reference_id` already processed (idempotency check).

---

## Error Reference

| Status | Meaning |
|---|---|
| 400 | Bad request — invalid input, see error message |
| 401 | Unauthenticated — missing or invalid X-User-ID / service key |
| 403 | Forbidden — authenticated user cannot perform this action |
| 404 | Resource not found |
| 409 | Conflict — duplicate request or state conflict |
| 413 | Payload too large |
| 429 | Rate limit exceeded |
| 500 | Internal server error |
| 503 | Service unhealthy — database or dependency unavailable |
