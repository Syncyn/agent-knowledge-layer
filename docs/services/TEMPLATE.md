<!--
title: <Service Name> Service Documentation
status: stub
owner: <team>
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
services: [<service-name>]
-->

# <service-name>

## Service Overview

| Field | Value |
|---|---|
| Language / Runtime | [e.g., Go 1.23 / Python 3.12 / Node.js 20] |
| Repository | `<service-name>/` |
| Primary responsibilities | [What does this service do? 1-3 sentences.] |
| Key internal dependencies | [Shared libraries or internal packages] |
| Key external dependencies | [Databases, caches, external APIs, cloud services] |

## Callers

Who calls this service and what they use:

| Caller | Endpoint / Purpose | Auth |
|---|---|---|
| [service or client name] | [endpoints or purpose] | [auth method] |

## Calls

What this service calls:

| Dependency | Purpose | Auth |
|---|---|---|
| [database / service / API] | [what it's used for] | [how auth works] |

---

## Architecture Notes

<!-- Describe the internal structure of the service. Key patterns, layers, non-obvious design choices.
     Anything a new engineer or agent would need to know before touching the code. -->

TBD

### Layered structure (if applicable)

```
[entry-point]            — [description]
[internal or src]/
  [auth or middleware]/  — [description]
  [config]/              — [description]
  [db or store]/         — [description]
  [model]/               — [description]
  [repository]/
    interfaces.[ext]     — [interface definitions — use these, not concrete types]
  [service]/
    [name]_test.[ext]    — [test approach description]
```

### Test approach

[Describe: unit tests, integration tests, mock approach, test package naming convention.]

---

## Configuration

| Variable | Required | Default | Description |
|---|---|---|---|
| [ENV_VAR_1] | Yes | — | [description] |
| [ENV_VAR_2] | No | [default] | [description] |

---

## Known Issues

<!-- List known bugs, limitations, or tech debt that affects contributors.
     This section is critical for agents — it prevents them from stepping on existing issues. -->

- [Issue 1 — link to ticket if applicable]
- [Issue 2]

## Related Documents

- [api/<service-name>.md](../api/<service-name>.md) — API endpoint reference
- [architecture/overview.md](../architecture/overview.md) — system topology

## Change Log

| Date | Author | Description |
|---|---|---|
| YYYY-MM-DD | | Initial stub |
