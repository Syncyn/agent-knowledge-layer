<!--
title: [Agent Name] — Capability Definition
status: proposed
owner: engineering
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
-->

# [agent-name]

> **One-line summary:** [What this agent does in one sentence.]

---

## Domain

[2-3 sentences on the agent's primary area of expertise. What kind of work does it produce? What domain knowledge does it bring?]

---

## When to use

Assign a task to this agent when:

- [Trigger 1 — be specific. E.g., "A Go service needs a new database repository layer"]
- [Trigger 2]
- [Trigger 3]
- [Trigger 4 — include the keyword signals that should make someone think of this agent]

---

## When NOT to use

Do not assign to this agent when:

- [Exclusion 1 — e.g., "The task involves Flutter/Dart code — use flutter-expert instead"]
- [Exclusion 2 — a common misassignment]
- [Exclusion 3]

---

## Required context before starting

This agent should read the following before beginning any assigned task:

- `docs/REPO_NAVIGATION.md` — workspace layout
- `docs/REPO_STATE.md` — current infrastructure state
- [Any domain-specific docs this agent always needs, e.g., `docs/architecture/data-model.md`]
- [Service-specific docs if this agent typically works on a particular service]

---

## Preferred tools and patterns

- [Tool or pattern 1 — e.g., "Uses `GOWORK=off go test ./...` for per-service Go tests"]
- [Tool or pattern 2 — e.g., "Uses `syncyn-knowledge-mcp` `get_service_context` before reading source"]
- [Tool or pattern 3]

---

## Output expectations

When assigned a task in an implementation plan, this agent typically produces:

- [Output type 1 — e.g., "Modified Go source files with passing unit tests"]
- [Output type 2 — e.g., "Updated schema.sql with migration SQL"]
- [Output type 3 — e.g., "Updated acceptance criteria status in the implementation plan"]

---

## Invocation notes

[Any special instructions for invoking this agent type. E.g., "Provide the full task context including Deps and Acceptance criteria, not just the Steps." or "This agent works best when given a specific service to focus on — avoid open-ended tasks."]

---

## Example task assignment

```markdown
### P1-T3: Add PostgreSQL repository for user profiles

**Assignee:** [agent-name]
**Effort:** ~3 hours
**Deps:** P1-T1 (schema migration deployed), P1-T2 (interface defined)

**Context:** [Brief task context]

**Steps:**
1. [Step]
2. [Step]

**Acceptance criteria:**
- [Binary criterion]
- [Binary criterion]
```
