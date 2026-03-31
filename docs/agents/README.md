<!--
title: Agent Capability Definitions — Directory Guide
status: current
owner: engineering
created: 2026-03-31
last-updated: 2026-03-31
-->

# docs/agents/

This directory defines the agent types available for your project — their capabilities, when to invoke them, what context they need, and how to reference them in implementation plans.

---

## Why this directory matters

Implementation plans assign tasks to specific agent types (`Assignee: golang-pro`, `Assignee: database-optimizer`). Without a roster here, those assignments are ambiguous — a new contributor (human or agent) reading the plan doesn't know what `golang-pro` means, what it's capable of, or whether a given task is well-matched to it.

This directory solves that. It also helps agents self-identify: when an agent reads the implementation plan and sees it is the `Assignee`, it can look up its own definition here to understand what context, tools, and approach it should bring.

---

## What belongs here

One file per agent type. Each file describes:

- **What this agent does** — its primary domain and capabilities
- **When to use it** — the triggers that should lead someone to assign a task to this agent
- **When NOT to use it** — explicit exclusions to prevent misassignment
- **Required context** — what docs or files this agent should read before starting
- **Preferred tools** — which MCP tools, CLI tools, or patterns this agent relies on
- **Invocation note** — any special instructions for invoking this agent type

---

## What does NOT belong here

- Agent task assignments (those go in `implementation-plans/`)
- Agent configuration files (those go in your `.claude/agents/` directory or equivalent)
- Conversation memory (that lives in the `memory/` system)

---

## File naming

```
docs/agents/[agent-type-name].md
```

Use kebab-case. Match the name used in implementation plan `Assignee:` fields exactly.

---

## Current agent roster

| Agent | Domain | Primary use |
|---|---|---|
| [example-agent.md](./example-agent.md) | [Domain] | [One-line summary] |

Update this table whenever you add or remove an agent definition.

---

## Relationship to implementation plans

Implementation plans reference agents by name in their `Assignee:` field:

```markdown
### Task 1: Add database migration

**Assignee:** database-optimizer
**Effort:** ~3 hours
**Deps:** none
```

When reading a plan, agents and humans can look up `docs/agents/database-optimizer.md` to understand what that agent brings to the task. This prevents misassignment and helps implementation plan authors make good choices.

---

## Prompt to draft agent definitions

If you have existing agent configurations (e.g., custom agents in `.claude/agents/`), you can have an agent draft these definitions for you:

> "Read all agent definition files in `.claude/agents/`. For each one, create a capability definition in `docs/agents/[name].md` following the template at `docs/agents/TEMPLATE.md`. Describe each agent's domain, triggers, exclusions, and required context based on its system prompt. Set status: `proposed` on each — I'll review and promote to `current`."
