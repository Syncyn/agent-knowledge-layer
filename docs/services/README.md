# Services

This directory contains per-service overview documents. Each deployed service (and major application component) has one document here.

## What belongs here

- Service responsibilities and scope
- Caller and dependency maps (what calls this service, what it calls)
- Key architecture notes (patterns, layers, non-obvious design choices)
- Configuration reference (environment variables)
- Known issues that affect contributors and agents

## What does NOT belong here

- HTTP endpoint details → `api/`
- Feature designs → `design/`
- Architectural decisions → `adr/`
- System topology → `architecture/`

## One file per service

Create one file per service: `[service-name].md`. If a service has multiple significant components (e.g., a background worker plus a REST API), document them in the same file under separate sections.

## The Callers and Calls sections are critical

The most common agent mistake when working on a service is breaking an inter-service contract. Agents break contracts because they don't know who depends on an endpoint. The **Callers** and **Calls** sections exist specifically to prevent this.

Always fill these in:

```markdown
## Callers

Who calls this service and what endpoints they use:

| Caller | Endpoint | Auth |
|---|---|---|
| api-gateway | all `/v1/*` routes | `X-User-ID` forwarded after JWT verification |
| payments-service | `POST /internal/credits` | `X-Internal-Service-Key` |
```

```markdown
## Calls

What this service calls:

| Dependency | Purpose | Auth |
|---|---|---|
| PostgreSQL (users-db) | primary data store | connection string |
| S3 (acme-media bucket) | avatar storage | IAM role |
| notifications-service | `POST /internal/notify` | `X-Internal-Service-Key` |
```

## Required sections

Every service document must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Service Overview table (language, responsibilities, key dependencies)
3. Callers (who calls this service)
4. Calls (what this service calls)
5. Architecture Notes (key patterns, non-obvious design, test approach)
6. Configuration (environment variables)
7. Known Issues

## Template

See [TEMPLATE.md](./TEMPLATE.md) to start a new service document.
