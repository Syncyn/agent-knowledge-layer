# [YOUR_PROJECT_NAME] — CLAUDE.md

<!--
  WHAT THIS FILE IS:
  This file is read automatically by Claude Code at the start of every session.
  It is the single most important file in this documentation system.
  Instructions here directly change how agents behave — what they check before coding,
  what conventions they follow, and what they must not do.

  WHERE THIS FILE LIVES — WORKSPACE ROOT CONVENTION:
  This file belongs at the *workspace root* — the directory you invoke your AI agent from.

  For a single-repo project:   workspace root = repo root (standard)
  For a multi-repo workspace:  workspace root = the parent directory that contains all
                                your service repos side by side, e.g.:
                                  ~/workspace/
                                  ├── CLAUDE.md          ← this file lives here
                                  ├── api-service/
                                  ├── worker-service/
                                  ├── frontend/
                                  └── docs/              ← or docs live as a sibling repo

  Claude Code reads CLAUDE.md from wherever it is invoked. Placing it at the workspace
  root means agents always see it regardless of which individual repo they happen to be
  editing. This is the correct mental model: agents work across your entire workspace,
  not inside individual service repos.

  HOW TO USE THIS TEMPLATE:
  Replace all [PLACEHOLDERS] with your project's specifics.
  Keep the comments — they help future maintainers understand why each section exists.
  Add project-specific conventions to the relevant sections.
  The more specific and accurate this file is, the more effective your agents will be.
-->

---

## CRITICAL: Before starting any task

<!--
  This section must come first. Its purpose is to redirect agents to the knowledge hub
  before they start reading source files. Without this, agents spend 30-50% of their
  context window on exploratory reads that could be avoided.
-->

1. Check `docs/INDEX.md` to find documentation relevant to this task. If a document on the topic exists, read it before doing anything else.
2. Use `docs/REPO_NAVIGATION.md` to understand the project layout. Do NOT run `ls`, `find`, or `Glob` to explore the directory structure — the navigation file covers it.
3. Read `docs/REPO_STATE.md` before writing any infrastructure-touching code (deployments, database access patterns, cloud platform assumptions).
4. Check `docs/adr/` for ADRs relevant to the component you are modifying. ADRs explain WHY decisions were made — do not undo them without reading the context first.

---

## Workspace Layout

<!--
  List every repo / top-level directory in your workspace here.
  This supplements REPO_NAVIGATION.md — that file has the full annotated tree,
  this section gives agents a 10-second orientation.

  For a monorepo, these are subdirectories of the repo root.
  For a multi-repo workspace, these are the repos checked out side by side under
  a common parent directory (which is where this CLAUDE.md lives).
  Either way, agents use this section instead of running ls/find at the workspace root.

  Update this when the top-level structure changes significantly.
-->

```
[workspace-root]/
├── CLAUDE.md            ← this file — read by agents on every session start
├── [service-a]/         [Language] — [one-line responsibility]
├── [service-b]/         [Language] — [one-line responsibility]
├── [service-c]/         [Language] — [one-line responsibility]
├── [shared-library]/    [Language] library (not deployed) — [shared utilities]
├── [client-app]/        [Framework] client — [web/mobile/desktop]
├── docs/                Documentation hub — architecture, design, ADRs, runbooks
│                        (can also be a sibling git repo, e.g. "your-project-docs/")
└── [other-tooling]/     [description]
```

---

## Service Interaction Map

<!--
  This section is critical for agents working on inter-service features.
  Agents frequently break service contracts because they don't know what calls what.
  Keep this updated when service dependencies change.

  _last-updated: [YYYY-MM-DD]_

  For the full infrastructure state (compute platform, DB, migration phase)
  see docs/REPO_STATE.md. The map below describes logical call relationships.
-->

_last-updated: [YYYY-MM-DD]_

For the current infrastructure state see `docs/REPO_STATE.md`. The map below describes logical call relationships.

### [service-a] ([Language])
- **Role:** [What is this service responsible for?]
- **Calls:** [service-b] (REST, [auth method]), [database] (direct)
- **Called by:** [client-app] (REST, [auth method]), [service-c] (internal key)

### [service-b] ([Language])
- **Role:** [What is this service responsible for?]
- **Calls:** [external-api], [database]
- **Called by:** [service-a] (REST), [client-app] (REST)

### [service-c] ([Language])
- **Role:** [What is this service responsible for?]
- **Calls:** [service-a] `POST /internal/[endpoint]` (with `X-Internal-Service-Key` header)
- **Called by:** [client-app] (REST, [auth method])

### [client-app] ([Framework])
- **Role:** [Cross-platform client / web frontend / etc.]
- **Calls:** [service-a], [service-b], [service-c] (REST, [auth method])
- **Called by:** Nobody — it is the client.

### [shared-library] ([Language] library — not deployed)
- **Role:** Shared utilities — [list what's shared: auth middleware, DB clients, etc.]
- **Called by:** [service-a], [service-b], [service-c] (all import it)

---

## Coding Conventions

<!--
  This section prevents the most common agent mistakes.
  Every item here should be something an agent has gotten wrong at least once,
  or something non-obvious enough that a new engineer would need to be told.
  Organize by language/framework so agents can quickly find relevant conventions.
-->

### [Language/Framework 1] (e.g., Go services)

- **Test package:** `package [name]` (same package as the code under test, not `_test` suffix)
- **Mocks:** [your mock approach — hand-written, mockery, testify/mock, etc.]
- **Dependencies:** Use `[your shared library]` for [shared init/config] — never hardcode credentials or service URLs
- **Environment variables:** `[ENV_VAR_1]`, `[ENV_VAR_2]` — read by `[your config package]`
- **[Any other non-obvious conventions]**

### [Language/Framework 2] (e.g., Flutter / React / Python)

- **[Convention 1]:** [description]
- **[Convention 2]:** [description]
- **[Dependency injection pattern]:** [describe it — this is high value for agents]
- **[Test mocking approach]:** [describe it]

### docs/

<!--
  These rules govern how agents interact with the documentation itself.
  Critical: the "check INDEX before creating" rule prevents duplicate docs,
  which is the most common documentation mistake agents make.
-->

- Every document has a frontmatter comment block: `title`, `status`, `owner`, `created`, `last-updated`, `services`
- `last-updated` means "last verified against reality", not "last edited"
- Status values: `draft`, `proposed`, `current`, `outdated`, `stub`
- **Always check `docs/INDEX.md` before creating a new document.** Update an existing doc rather than creating a duplicate.
- **Never create a new top-level directory in `docs/`.** Use the established categories.
- Add new docs to `docs/INDEX.md` in the same commit that creates them.
- ADRs in `docs/adr/` are immutable. Do not edit the Decision or Context of an accepted ADR. Supersede with a new ADR instead.

---

## docs/ Directory Map

<!--
  This table is the quick reference for which directory to use for each document type.
  Keep it in sync with the actual directory structure.
-->

| Directory | Document type |
|---|---|
| `docs/architecture/` | System/feature architecture, topology, data flows |
| `docs/design/` | Feature design docs (written before or during implementation) |
| `docs/api/` | HTTP endpoint references |
| `docs/services/` | Per-service overview docs |
| `docs/adr/` | Architectural Decision Records (immutable) |
| `docs/agents/` | Agent capability definitions — what each agent type does, when to use it, how to invoke it in implementation plans |
| `docs/implementation-plans/` | Multi-task plans with assigned agents |
| `docs/research/` | Technology/API/legal investigations |
| `docs/runbooks/` | Operational procedures |

---

## Test Accounts / Credentials

<!--
  List any test accounts or non-secret credentials agents need for automated testing.
  Do NOT put real secrets here — use environment variables or a secrets manager.
  This section is for things like "the test user account in staging" that agents
  need to know about to run integration tests or automated UI flows.
-->

- [Describe test account or staging credentials if applicable]
- [e.g., Test user: test@example.com / TestPassword123 (staging only)]

---

## Implementation Status

<!--
  A quick-reference table of what's done and what's pending.
  Agents use this to avoid re-implementing completed work and to understand
  what planned work they might be asked to do next.
  Update this table as work completes or priorities change.
-->

| Area | Status |
|---|---|
| [Feature or refactor 1] | Complete |
| [Feature or refactor 2] | In progress |
| [Feature or refactor 3] | Pending |
| [Feature or refactor 4] | Pending |

---

## Tracking work

Work items, bugs, progress and priority live in GitHub, not in syncyn-docs (`syncyn-docs/adr/0011-workflow-tracking-in-github-projects.md`). Each unit of work is an issue in the repo that does the work, on the org project [Syncyn Roadmap](https://github.com/orgs/Syncyn/projects/1), with Stage (Planned, Design, In progress, Merged, On staging, In production, Verified) and Priority (P0 to P3). Reference the issue in the PR (`Closes Syncyn/<repo>#N`), and move its Stage when the work merges, deploys or is verified live. Don't record progress in syncyn-docs plans or designs. Cloud agent sessions can't edit board fields, so use the matching issue labels instead; they sync with the board every hour (`stage:*`, `priority:P0` to `priority:P3`, `blocked:kev`, `blocked:vlad`, `blocked:kev+vlad`, `blocked:external`; see syncyn-docs `CONTRIBUTING.md`). If you can't continue without Kev or Vlad (a decision, access, credentials or review), add the matching `blocked:*` label (or set the board's **Blocked on** field), leave one issue comment saying exactly what's needed, and stop. When the label is removed, the issue can be picked up again.
