# Setup Guide — Adopting the Agent-Docs System

This guide walks through adopting this documentation system for an existing project, step by step. Budget about an hour for the initial setup; the ongoing cost is updating docs when the systems they describe change.

---

## Prerequisites

- A software project with at least one service or application component
- A `CLAUDE.md` (or equivalent instruction file) in your repo root, or willingness to create one
- Git (for commit-hash-based cache invalidation in the MCP server, if you use it)

---

## Step 1: Create the docs directory structure (5 minutes)

Copy the `docs/` directory from this template into your project root:

```bash
cp -r agent-docs-template/docs your-project/docs
```

Or create the structure manually:

```bash
mkdir -p docs/architecture docs/design docs/adr docs/implementation-plans docs/api docs/services docs/runbooks docs/research
```

The `docs/` directory can live at the repo root, or — if you're adding docs to a monorepo that already has a `docs/` folder — as a subdirectory like `docs/agent-knowledge/`. What matters is that the location is consistent and that your `CLAUDE.md` points to the correct path.

---

## Step 2: Set up CLAUDE.md (10 minutes)

Copy `CLAUDE.md` from this template into your repo root:

```bash
cp agent-docs-template/CLAUDE.md your-project/CLAUDE.md
```

Then edit it:
- Replace all `[YOUR_PROJECT_NAME]` placeholders with your project's name
- Replace service names and descriptions in the Service Interaction Map with your actual services
- Update the Monorepo Layout section with your actual directory structure
- Keep all the comments — they explain to future maintainers (human and agent) why each section exists

If you already have a `CLAUDE.md`, merge the relevant sections in. The critical additions are:
- The instruction to check `docs/INDEX.md` before starting any task
- The Service Interaction Map (or a link to it in the docs)
- The per-service coding conventions

---

## Step 3: Write REPO_NAVIGATION.md (10 minutes)

This is the file agents read instead of running `ls` or `find`. It saves them context tokens and lets you annotate the tree with things the filesystem doesn't show.

Start by generating a tree of your project:

```bash
# Unix/Mac
tree -L 3 --gitignore

# Windows
tree /F /A | head -100
```

Paste the output into `docs/REPO_NAVIGATION.md` and annotate it. For each directory and key file, add a comment explaining what it is. See `docs/REPO_NAVIGATION.md` in this template for the format.

Important: include "Key patterns" sections for each service. These are the things you would tell a new engineer in a 5-minute onboarding: test package conventions, mock approach, singleton patterns, anything non-obvious.

---

## Step 4: Write service overview docs (15 minutes)

For each service or major application component, create `docs/services/[service-name].md`. Use the template at `docs/services/README.md` as a starting point.

Minimum viable service doc:

```markdown
<!--
title: [Service Name] Service Documentation
status: current
owner: [team]
created: [today]
last-updated: [today]
services: [[service-name]]
-->

# [service-name]

## Service Overview

| Field | Value |
|---|---|
| Language / Runtime | [e.g., Python 3.12 / FastAPI] |
| Responsibilities | [What does this service do?] |
| Key internal dependencies | [What shared libraries does it use?] |
| Key external dependencies | [Database, cache, external APIs] |
| Callers | [What calls this service?] |
| Calls | [What does this service call?] |

## Configuration

| Variable | Required | Description |
|---|---|---|
| DATABASE_URL | Yes | PostgreSQL connection string |

## Known Issues

- [Anything an agent should know before touching this code]
```

Even a stub like this is dramatically more useful than nothing. The most important fields are **Callers** and **Calls** — agents frequently break inter-service contracts because they don't know what depends on a given endpoint.

---

## Step 5: Write your first ADR (10 minutes)

ADRs are the highest-value document type for agent effectiveness. They explain WHY decisions were made, which is what agents most need to avoid re-making bad choices.

Look back at the last significant architectural decision your team made:
- Why did you choose PostgreSQL over MongoDB?
- Why is authentication done in a gateway vs. in each service?
- Why does the mobile app use direct database reads vs. an API layer?

Write that up as `docs/adr/ADR-0001-[decision-title].md`. Use the template at `docs/adr/ADR-0000-template.md`.

From this point forward: every significant architectural decision gets an ADR. The bar is: "if an agent implementing a feature needed to know this, it's an ADR."

---

## Step 6: Set up REPO_STATE.md (5 minutes)

Copy the template `docs/REPO_STATE.md` and fill in your current infrastructure state. This file exists specifically to prevent agents from generating code for the wrong platform.

Key questions to answer in REPO_STATE.md:
- What compute platform is each service on? (AWS ECS, GCP Cloud Run, Kubernetes, bare VMs, etc.)
- What database does each service use?
- Are any migrations currently in progress?
- What should agents NOT assume (old patterns that no longer apply)?

Update this file whenever a service migrates or a significant infrastructure change is made.

---

## Step 7: Populate INDEX.md (5 minutes)

Add an entry to `docs/INDEX.md` for every file you've created. This step is easy to skip and critically important not to — the index is the agent's entry point and it only works if it's complete.

Format:
```markdown
| [services/my-service.md](./services/my-service.md) | My Service: what it does in one sentence |
```

---

## Step 8: Verify agent behavior (5 minutes)

Start a new Claude Code session and give it a task that requires reading your project. Before it starts coding, it should:

1. Read `CLAUDE.md` (Claude Code does this automatically for CLAUDE.md in the repo root)
2. Check `docs/INDEX.md` to find relevant docs
3. Read at minimum the relevant service doc and any linked ADRs

If the agent dives straight into code without reading any docs, your `CLAUDE.md` instruction isn't strong enough. Add this to the top of your CLAUDE.md (before any other instructions):

```markdown
## CRITICAL: Before starting any task

1. Check docs/INDEX.md to find documentation relevant to this task.
2. Read docs/REPO_NAVIGATION.md if you need to understand the project layout — do NOT run ls/find.
3. Read docs/REPO_STATE.md before writing any infrastructure code.
4. Read docs/adr/ entries relevant to the component you are changing.
```

---

## Optional: MCP server setup

Once the documentation system is working as plain Markdown files, consider adding the knowledge MCP server for faster agent queries. See `mcp-server/README.md` for the full guide.

The MCP server is worth adding when:
- You have 5+ services and agents spend significant time reading docs
- You want agents to have always-current data (git log, live infrastructure state)
- You want structured JSON responses rather than prose docs

---

## Ongoing maintenance

The documentation system's value degrades as docs drift from reality. The key maintenance habits:

**When you change a service's architecture:** Update `docs/services/[service].md` and `docs/REPO_NAVIGATION.md`.

**When you complete or start a migration:** Update `docs/REPO_STATE.md`.

**When you make a significant architectural decision:** Write an ADR immediately, while the context is fresh.

**When you start a significant feature:** Write an implementation plan in `docs/implementation-plans/` before coding. This also serves as the agent's task specification.

**Quarterly:** Review docs with `status: current` older than 90 days. Set `status: outdated` for any that have drifted.

A useful rule of thumb: if you would explain something to a new engineer joining the team, it belongs in the docs. If an agent keeps making the same mistake, the fix is a doc update (or an ADR), not a better prompt.
