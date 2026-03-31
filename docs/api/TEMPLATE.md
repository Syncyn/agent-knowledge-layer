<!--
title: <service-name> API Reference
status: stub
owner: <team>
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
services: [<service-name>]
-->

# <service-name> API Reference

## Overview

[Brief description of what this service's API covers.]

**Base URL:** `https://[your-domain]/[base-path]`
**API version:** `v1`
**Internal base URL (service-to-service):** `http://[service-name].internal/internal`

## Authentication

[Describe how to authenticate. Examples:]
- All `/v1/` endpoints require `Authorization: Bearer <jwt>` (verified at api-gateway)
- Internal endpoints require `X-Internal-Service-Key: <shared-secret>`
- `GET /healthz` requires no authentication

---

## Endpoints

### `GET /healthz`

Health check.

**Auth:** None

**Response (200):**
```json
{"status": "healthy"}
```

---

### `[METHOD] /[path]`

[Description of what this endpoint does.]

**Auth:** [What auth is required]

**Path parameters:**
- `[param]` — [description]

**Query parameters:**
- `[param]` — [description, optional/required]

**Request body:**
```json
{
  "[field]": "[type and description]"
}
```

**Response (200):**
```json
{
  "[field]": "[example value]"
}
```

**Response ([error code]):**
```json
{"error": "[description]"}
```

---

## Error Reference

| Status | Meaning |
|---|---|
| 400 | Bad request — invalid input |
| 401 | Unauthenticated — missing or invalid credentials |
| 403 | Forbidden — authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict — state conflict or duplicate |
| 429 | Rate limit exceeded |
| 500 | Internal server error |
| 503 | Service unhealthy |
