<!--
title: backend-engineer — Capability Definition
status: current
owner: engineering
created: 2026-03-31
last-updated: 2026-03-31
-->

# backend-engineer

> **One-line summary:** Implements server-side features, API endpoints, database layers, and service integrations for the Acme Corp backend services.

---

## Domain

The `backend-engineer` agent handles backend application code: REST API handlers, database repositories, business logic services, middleware, background jobs, and inter-service integrations. It is language-agnostic but should be given a language/framework context in its task (e.g., "this is a Go service using pgx" or "this is a Python service using FastAPI").

It is not responsible for infrastructure provisioning, database schema design, or cloud platform configuration — those belong to `database-optimizer` and `cloud-architect` respectively.

---

## When to use

Assign a task to this agent when:

- A new REST endpoint needs to be added to an existing service
- A new database repository or data-access layer needs to be written
- Business logic needs to be added, refactored, or tested
- A background job or scheduled task needs implementation
- An inter-service integration (HTTP call, message queue consumer) needs to be added
- Existing code needs refactoring to follow updated conventions
- A dual-write pattern needs to be implemented (writing to two stores simultaneously)

---

## When NOT to use

Do not assign to this agent when:

- The task requires creating or modifying database schemas — use `database-optimizer`
- The task requires cloud infrastructure changes (ECS, RDS, IAM) — use `cloud-architect`
- The task requires frontend or mobile client code — use `frontend-engineer` or `mobile-engineer`
- The task is a broad architectural design with multiple services — use `cloud-architect` to design first, then break into backend-engineer tasks
- The primary deliverable is documentation — use `documentation-engineer`

---

## Required context before starting

This agent should read the following before beginning any assigned task:

- `docs/REPO_NAVIGATION.md` — workspace layout and per-service build commands
- `docs/services/[target-service].md` — responsibilities, dependencies, and known issues for the service being modified
- `docs/adr/` — any ADRs relevant to the component being modified
- `docs/REPO_STATE.md` — confirms current infrastructure state (database type, platform) before writing DB or cloud code
- Any linked design doc in the task's `Context:` field

---

## Preferred tools and patterns

- Reads service docs and ADRs before reading source code — avoids redundant exploration
- Uses the project's established test patterns (see service doc and `docs/architecture/` for conventions)
- Writes dual-write errors as non-fatal log lines (`warn: ...`) that do not propagate to HTTP responses
- Verifies builds and tests pass per-service using the commands in `docs/REPO_NAVIGATION.md`
- Does not create new abstractions for one-time operations; does not add error handling for scenarios that cannot happen

---

## Output expectations

When assigned a task in an implementation plan, this agent typically produces:

- Modified source files for the target service
- New or updated unit/integration tests for the changed code
- Passing build and test run (`go test ./...`, `pytest`, etc.) confirmed in the task response
- Updated acceptance criteria status in the implementation plan task

---

## Invocation notes

Provide the full task block from the implementation plan — including `Context`, `Steps`, and `Acceptance criteria`. This agent performs best when the task scope is narrow (one service, one feature). Avoid combining multiple services into a single task assignment; split them instead.

---

## Example task assignment

```markdown
### P2-T3: Add message persistence to conversations service

**Assignee:** backend-engineer
**Effort:** ~3 hours
**Deps:** P2-T1 (conversations table created), P2-T2 (dual-write pool initialized)

**Context:** The conversations service currently writes messages to Firestore only.
Add a dual-write so new messages are also written to the `messages` PostgreSQL table.
The PostgreSQL write must be non-fatal — Firestore remains the source of truth.

**Steps:**
1. In `conversations-service/handlers/message.go`, after the Firestore write,
   add an INSERT into `messages` using the pool from P2-T2.
2. Wrap the INSERT in `ON CONFLICT (id) DO NOTHING` for idempotency.
3. Log failures as `warn: pg dual-write failed for message_id=%s` — do not return 5xx.

**Acceptance criteria:**
- New messages appear in `messages` table after sending via API
- Firestore write still succeeds if PostgreSQL INSERT fails (verified by breaking DB URL in test)
- `go test ./...` passes in `conversations-service`
```
