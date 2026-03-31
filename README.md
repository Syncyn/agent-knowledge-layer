# Agent-Docs Template

A battle-tested documentation system that makes AI coding agents dramatically more effective on software projects — extracted from a real production codebase.

**What you get:** A structured knowledge hub that your team's human engineers and your AI agents (Claude Code, Cursor, Copilot Workspace, etc.) both read from the same source — so agents arrive at every task already knowing your architecture, past decisions, and current infrastructure state, rather than burning context window inferring them from source code.

---

## Why this exists

Extracted from [Syncyn](https://syncyn.io), a production multi-service platform that uses Claude Code agents extensively for development work. The Syncyn team found that the single highest-leverage investment for agent effectiveness was not better prompts or smarter models — it was **structured, agent-readable documentation**.

Without structured docs, agents:
- Spend 30-50% of their context window on exploratory file reads (`ls`, `find`, grepping for imports)
- Apply architectural patterns from six months ago because CLAUDE.md files have no staleness signals
- Make decisions that conflict with prior architectural choices they have no way of knowing about
- Restart from scratch every session, reconstructing context that previous sessions already established
- Generate infrastructure code for the wrong platform when a migration is underway

With this system, agents:
- Read the INDEX, find the relevant docs in one lookup, and start working
- Know why every major decision was made (ADRs), preventing them from undoing deliberate choices
- Have a live view of the current infrastructure state before touching deployment code
- Build on previous sessions' institutional memory rather than reconstructing it

The pattern was validated across dozens of agent sessions at Syncyn and reduced new-feature implementation time significantly.

---

## Two audiences, one source of truth

Every document in this system is written for two readers simultaneously:

**Human engineers** use these docs to onboard, make architectural decisions, write runbooks, and coordinate across services. The structure makes it easy to find what you need and to understand the reasoning behind past choices.

**AI agents** use these docs as structured context before every task. When an agent reads `docs/INDEX.md` and follows the link to the relevant service doc, design doc, and ADR, it arrives at the coding task with the same context a senior engineer would have. This is the core insight: agents don't need to be smarter, they need to be better informed.

---

## Directory structure

```
agent-knowledge-layer/
├── README.md                         # This file
├── SETUP.md                          # Step-by-step adoption guide (+ setup scripts)
├── CLAUDE.md                         # Drop into your workspace root to instruct agents
├── docs/
│   ├── INDEX.md                      # Single entry point — every doc linked here
│   ├── REPO_NAVIGATION.md            # Complete directory tree for agent orientation
│   ├── REPO_STATE.md                 # Live infrastructure state (check before infra work)
│   ├── architecture/                 # System topology, data flows, cross-cutting concerns
│   ├── design/                       # Feature design docs (pre/during implementation)
│   ├── adr/                          # Architectural Decision Records (immutable)
│   ├── agents/                       # Agent capability definitions and roster
│   ├── implementation-plans/         # Multi-agent task plans with acceptance criteria
│   ├── api/                          # HTTP endpoint references
│   ├── services/                     # Per-service overviews
│   ├── runbooks/                     # Operational procedures
│   └── research/                     # Technology and vendor investigations
├── scripts/
│   ├── setup.sh                      # Automated setup for macOS / Linux
│   ├── setup.ps1                     # Automated setup for Windows (PowerShell)
│   └── README.md                     # Script usage notes
├── mcp-server/
│   ├── README.md                     # How to build a knowledge MCP server for your repo
│   └── example-tools.md              # Tool designs and why each one matters
└── memory/
    ├── README.md                     # Auto-memory system explanation
    └── MEMORY.md                     # Template MEMORY.md for agent memory index
```

### What each part does

**`CLAUDE.md` (workspace root)** — The single most important file. Drop this into your *workspace root* — the directory you invoke your AI agent from. For a single-repo project, that's the repo root. For a multi-repo setup (several service repos side by side), it's the parent directory that contains all of them. Claude Code reads `CLAUDE.md` from wherever it is invoked, so placing it at the workspace root means agents always see it regardless of which individual service repo they're editing. See the template `CLAUDE.md` in this repo — it is extensively commented.

**`docs/INDEX.md`** — The agent's entry point. Before starting any task, an agent should check the index to find relevant docs. Every document in the repo is listed here with a one-line description. This prevents agents from creating duplicate documents and gives them an immediate map of available knowledge.

**`docs/REPO_NAVIGATION.md`** — A complete, written-out directory tree of your project, updated when structure changes. Agents read this instead of running `ls` or `find` — which wastes context tokens and misses important context. For a monorepo with 10+ services, this is critical.

**`docs/REPO_STATE.md`** — A live-updated file tracking current infrastructure state: which services are on which compute platform, what databases they use, what migrations are in progress. Agents check this before writing infrastructure code so they don't generate patterns for a platform you've already migrated away from.

**`docs/architecture/`** — System topology diagrams, data models, and cross-cutting architectural concerns. This is where you document how everything connects, which helps agents make changes that don't break adjacent services.

**`docs/design/`** — Feature design documents written before or during implementation. These give agents the reasoning behind feature choices, so they implement things consistently with stated goals.

**`docs/adr/`** — Architectural Decision Records. Immutable records of significant decisions: what was decided, why, what alternatives were considered, and what the consequences are. This is the most agent-impactful document type — agents that know WHY a decision was made don't accidentally undo it.

**`docs/agents/`** — Agent capability definitions: what each agent type is good at, when to invoke it, what context it needs, and how to reference it in implementation plans. This is the roster your implementation plans draw from. Without it, task assignment in plans is ambiguous and agents assigned to wrong tasks produce poor results.

**`docs/implementation-plans/`** — Structured multi-task plans with step-by-step instructions, assigned agent types, effort estimates, and acceptance criteria. These allow multiple agents to work on different parts of a feature without coordination overhead. Each task's `Assignee` field references an agent defined in `docs/agents/`.

**`docs/api/`** — HTTP endpoint references with request/response schemas. Agents read these to understand the API surface before writing client code or adding new endpoints.

**`docs/services/`** — Per-service overview documents: responsibilities, dependencies, configuration, and known issues. This is the first stop when an agent is assigned to work on a specific service.

**`docs/runbooks/`** — Step-by-step operational procedures for deployments, rollbacks, incident response, and maintenance tasks.

**`docs/research/`** — Technology investigations and vendor evaluations. Documents here inform decisions but are not decisions themselves — those go in ADRs.

**`mcp-server/`** — Guidance on building a local MCP server that exposes your documentation as queryable tools. This is the power-user tier: instead of agents reading files, they call `get_service_context("payments-service")` and get a structured JSON response.

**`memory/`** — The auto-memory system for agents. Claude Code can maintain a `MEMORY.md` index across sessions, with typed memory files (user preferences, feedback, project state, references). This template includes the structure for adopting that system.

---

## Quick start

Adopt this system in an existing project in under an hour:

**1. Copy the docs directory**
```bash
cp -r agent-docs-template/docs your-project/docs
```

**2. Drop in CLAUDE.md at the workspace root**
```bash
cp agent-knowledge-layer/CLAUDE.md ~/workspace/CLAUDE.md   # multi-repo
# or
cp agent-knowledge-layer/CLAUDE.md your-project/CLAUDE.md  # single repo
```
Edit the paths and service names to match your project. The comments in the file explain each section. The key: place it wherever you invoke `claude` (or your agent tool) from — that directory is your workspace root.

**3. Fill in REPO_NAVIGATION.md**
Run `tree` or `ls -R` once, paste the output into `docs/REPO_NAVIGATION.md`, then annotate it. From this point on, agents read this file instead of running tree commands.

**4. Write your first service docs**
For each service or major component in your system, create a file in `docs/services/` using the template. Even a stub with 5-6 fields (language, responsibilities, key dependencies, known issues) is more useful than nothing.

**5. Write your first ADR**
Look at the last significant architectural decision your team made — database choice, framework selection, authentication approach. Write it up as `docs/adr/ADR-0001-*.md`. From now on, major decisions get an ADR before or immediately after the implementation.

**6. Update INDEX.md**
Add entries for every file you just created. This is the step most teams skip and then regret — the index only works if it's complete.

**7. Tell agents to read it** — your `CLAUDE.md` already does this, but verify by starting a new agent session and confirming it reads the docs before diving into code.

---

## MCP server integration

The documentation files work immediately as plain Markdown. Agents can read them with standard file-read tools. But the system reaches its full potential when you add a local MCP server that exposes the docs as queryable tools.

Instead of:
```
[Agent reads 4 files to answer "what does the payments service use for its database?"]
```

An agent calls:
```
get_service_context("payments-service")
→ { language: "Go", db: "PostgreSQL", callers: ["api-gateway"], ... }
```

The `mcp-server/` directory in this template explains how to build this. The implementation follows the same pattern as Syncyn's `syncyn-knowledge-mcp` server: a TypeScript/Node.js MCP server that reads your docs directory and git history to answer structural questions about your codebase.

Core tools to implement (in priority order):
1. `list_services()` — returns all services with one-line descriptions
2. `get_service_context(service)` — returns the service doc + recent git log entries
3. `get_dependency_graph(service?)` — returns inter-service call relationships
4. `get_infra_state()` — returns REPO_STATE.md parsed as structured JSON

---

## How agents use this: before and after

### Without structured docs

An agent assigned to "add rate limiting to the payments API" does this:

1. Runs `ls` to orient — misses half the project structure
2. Reads the main entry point, follows imports for 3-4 file reads to understand routing
3. Reads similar middleware in another service to understand conventions
4. Makes a guess about what database the rate limit state should live in (gets it wrong — there's an existing Redis instance it didn't find)
5. Writes rate limiting using a pattern that was deprecated 6 months ago when the team switched routers
6. You review the PR and explain the conventions. Again.

Total: 6-8 file reads, wrong database choice, wrong framework pattern. PR needs significant rework.

### With structured docs

An agent assigned to "add rate limiting to the payments API" does this:

1. Reads `docs/INDEX.md` — finds `docs/services/payments-service.md` and `docs/architecture/overview.md`
2. Reads the service doc — learns it uses Go + chi router, PostgreSQL for persistence, Redis already configured for session caching
3. Checks `docs/REPO_STATE.md` — confirms it's on ECS, no migration in progress
4. Checks `docs/adr/` — finds ADR-0004 which explains why the team chose chi over gorilla/mux and what middleware conventions to follow
5. Writes rate limiting using chi middleware, backed by the existing Redis instance, following established patterns

Total: 3-4 targeted reads, correct choices, PR lands cleanly.

---

## Document frontmatter

Every document uses a frontmatter comment block at the top. This gives agents and humans immediate orientation without reading the whole document:

```markdown
<!--
title: Payments Service Overview
status: current
owner: platform-team
created: 2024-06-15
last-updated: 2024-11-30
services: [payments-service, api-gateway]
-->
```

**Status vocabulary:**
- `draft` — in progress, not yet reviewed
- `proposed` — written, awaiting review/acceptance
- `current` — accurate and up to date
- `outdated` — known to be stale, do not act on without verifying
- `stub` — placeholder, minimal content

The `last-updated` field means "last verified against reality" — not just "last edited". When an agent updates a doc, it should update this field only if it actually verified the content is still accurate.

---

## Contribution rules for agents

These rules should be in your `CLAUDE.md` and your `docs/CONTRIBUTING.md`:

1. Before creating any new document, check `docs/INDEX.md`. Update an existing doc rather than creating a duplicate.
2. Never create a new top-level directory in `docs/`. Use the established categories.
3. When creating a document, add it to `docs/INDEX.md` in the same commit.
4. Set `status: proposed` on new or significantly revised documents until a human reviews them.
5. Update `last-updated` only when you have verified the content against the current state of the system — not on every edit.
6. ADRs (`docs/adr/`) are immutable. Do not edit the Decision or Context of an accepted ADR. If a decision changes, write a new ADR that supersedes it.
7. When writing implementation plans, assign each step to a specific agent type. Unassigned steps accumulate as technical debt.

---

## Credits

This template is extracted from the documentation system built for [Syncyn](https://syncyn.io), a production multi-service platform (Go microservices + Flutter mobile client) that operates with a multi-agent Claude Code development workflow. The patterns here were developed iteratively based on what actually worked in production agent sessions, not theoretical best practices.

The core insight — that structured, agent-readable documentation is the highest-leverage investment in agent effectiveness, more so than better models or prompts — emerged from direct experience with what causes agents to fail on complex codebases.
