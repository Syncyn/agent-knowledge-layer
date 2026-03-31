# Agent Auto-Memory System

Claude Code agents can maintain persistent memory across sessions using a structured file-based system. This directory contains the template for that system.

## What it is

At the end of a session (or when explicitly asked to remember something), Claude Code can write typed memory files to a persistent directory. These files are read at the start of the next session, giving the agent continuity across conversations without requiring the user to re-establish context.

This is separate from documentation. Documentation describes the system. Memory describes:
- What the user prefers and why
- What feedback the user has given about the agent's approach
- What's currently in progress (project state)
- Where to find things in external systems

## Memory file types

**User memories** (`user_*.md`) — User role, expertise, preferences. Example: "User is a Go expert but new to the Flutter codebase — frame Flutter explanations in terms of backend analogues."

**Feedback memories** (`feedback_*.md`) — How the agent should approach work. Example: "Do not mock the database in integration tests — a production incident was caused by mock/prod divergence." These are the highest-value memories.

**Project memories** (`project_*.md`) — Current state of ongoing work. Example: "Service migration to ECS is in Phase 2; database migration starts next quarter." These decay quickly — check against current project state before acting on them.

**Reference memories** (`reference_*.md`) — Where to find things in external systems. Example: "Deployment issues are tracked in Linear project DEPLOY."

## MEMORY.md index

`MEMORY.md` is an index, not a memory. Each line is a pointer to a memory file:

```markdown
- [feedback_testing.md](feedback_testing.md) — Never mock the database; real DB required for integration tests
- [user_expertise.md](user_expertise.md) — User is a Go expert, new to the Flutter side
- [project_migration.md](project_migration.md) — ECS migration Phase 1 complete; Phase 2 (DB) pending
```

`MEMORY.md` is always loaded in the system prompt. Memory files are read on demand. Keep `MEMORY.md` concise — lines after 200 are truncated.

## Memory file format

```markdown
---
name: [memory name]
description: [one-line description]
type: user | feedback | project | reference
---

[memory content]

For feedback/project types:
**Why:** [reason given — a past incident, strong preference, etc.]
**How to apply:** [when this kicks in]
```

## Setup for your project

1. Copy this `memory/` directory into your agent's persistent memory location. For Claude Code, this is typically `~/.claude/agent-memory/[agent-name]/` or a path configured in `settings.json`.

2. The `MEMORY.md` in this directory is a blank template. Agents will populate it as they work with your team.

3. Configure the memory path in your `CLAUDE.md` or `settings.json` so agents know where to write memories.

## What NOT to save in memory

- Code patterns, architecture, file paths — these should be in documentation, not memory
- Git history or who-changed-what — `git log` is authoritative
- Session-specific context (current task, in-progress work)
- Anything already in `CLAUDE.md`

The memory system is for what's true about the **people and process** working on the project, not what's true about the code.
