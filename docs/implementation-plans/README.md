# Implementation Plans

This directory contains structured multi-task implementation plans for significant features, refactors, and migrations.

## What belongs here

- Plans for features that require more than a few hours of work
- Refactors that touch multiple services or require coordinated steps
- Migrations (database, platform, auth provider) with defined phases
- Any work that benefits from task assignment, sequencing, and acceptance criteria

## Why implementation plans matter for agents

When an agent is given a large task with no structure, it must decompose it itself. This leads to:
- Different agents making different decomposition decisions (coordination overhead)
- Steps executed in the wrong order because dependencies weren't documented
- No clear definition of "done" for each step
- Work that gets abandoned mid-task because the scope was unclear

A well-written implementation plan solves all of these. Agents can pick up a step, execute it exactly, verify the acceptance criteria, and stop — without needing to reconstruct the full context.

## The agent assignment pattern

Every step in an implementation plan has an **Assignee** field that names the agent type suited for that step. This is the key innovation over a plain task list:

```markdown
### Step 3: Add rate limiting middleware

**Assignee:** backend-developer

**Description:** Implement per-user rate limiting in api-gateway using Redis.
Rate limit: 100 requests per minute per user ID.

**Acceptance criteria:**
- Requests over the limit receive 429 Too Many Requests
- Rate limit state persists across gateway restarts (Redis-backed)
- Unit test covers limit enforcement and reset
- No changes to downstream services required
```

The Assignee field tells the orchestrating agent which sub-agent to spawn, and tells the sub-agent what kind of expertise the task requires.

## Effort and dependency notation

Use these fields to allow parallel execution where possible:

```markdown
**Effort:** Small (< 2 hours) | Medium (half day) | Large (1+ days)
**Depends on:** Step 1, Step 2
```

Steps with no dependencies can run in parallel. Steps with dependencies must run in sequence. Document this explicitly.

## Acceptance criteria format

Acceptance criteria should be:
- Specific and verifiable (not "the feature works")
- Testable by the agent without human review where possible
- Binary — either done or not done, no partial credit

Bad: "The notifications system is working."
Good:
- `POST /internal/notify` returns 200 when called with a valid service key and user ID
- Notification appears in `GET /v1/notifications` response within 1 second
- WebSocket client receives notification within 500ms of `POST /internal/notify` call

## Required sections

Every implementation plan must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Goal
3. Background and Motivation
4. Scope (In Scope / Out of Scope)
5. Implementation Steps (each with Assignee, Description, Acceptance Criteria)
6. Risks and Mitigations
7. Related Documents
8. Change Log

## Templates

- [TEMPLATE.md](./TEMPLATE.md) — blank plan template
- [example-plan.md](./example-plan.md) — filled example
