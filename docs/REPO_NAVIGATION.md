<!--
title: Repo Navigation Guide
status: current
owner: engineering
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
services: [all]
-->

# Repo Navigation Guide

This document is the canonical reference for the project layout. It is written for AI agents and new developers to orient without running `ls`, `find`, or exploratory glob calls.

**How to maintain:** Run your tree command once, paste the output here, annotate it. Update this file when the directory structure changes — don't let it drift. Agents that read this instead of running tree calls save significant context tokens per session.

---

## Root Layout

```
[YOUR_PROJECT_ROOT]/
├── [service-a]/                 [Language] service — [one-line responsibility]
├── [service-b]/                 [Language] service — [one-line responsibility]
├── [service-c]/                 [Language] service — [one-line responsibility]
├── [shared-library]/            [Language] library (not deployed) — shared utilities
├── [client-app]/                [Framework] client — [web/mobile/desktop]
├── docs/                        Documentation hub
├── [build-config]               [e.g., go.work, package.json workspace, etc.]
└── [other-tooling]/             [description]
```

---

## Service Directory Details

### [service-a] ([Language])

```
[service-a]/
├── [entry-point]                # Application entry point, route registration
├── [handlers or routes]/        # HTTP handler functions
├── [internal or src]/
│   ├── [auth or middleware]/    # Authentication middleware
│   ├── [config]/                # Environment variable loading
│   ├── [db or store]/           # Database connection and queries
│   ├── [model]/                 # Data structures
│   ├── [repository]/            # Data access layer
│   │   └── interfaces.[ext]     # Repository interfaces — always use these in service layer
│   └── [service]/               # Business logic layer
│       └── [name]_test.[ext]    # Service tests (same package as service code)
├── [Dockerfile]
├── [CI workflow]
└── [dependency file]            # e.g., go.mod, package.json, requirements.txt
```

**Key patterns:**
- [Note 1 — e.g., "Test package uses same package name as code under test, not _test suffix"]
- [Note 2 — e.g., "Repository interfaces defined in interfaces.go — always inject these, never concrete types"]
- [Note 3 — e.g., "Authentication: middleware verifies token and injects UID into request context"]
- [Known issues: e.g., "Handler for /search has cyclomatic complexity > 15 — refactor planned"]

---

### [service-b] ([Language])

```
[service-b]/
├── [entry-point]
├── [handlers]/
├── [Dockerfile]
└── [dependency file]
```

**Key patterns:**
- [Note 1]
- [Known issues if any]

---

### [shared-library] ([Language] library)

```
[shared-library]/
├── [middleware]/                # Shared HTTP middleware
├── [clients]/                   # Database/service client constructors
│   └── [init-file].[ext]        # Reads credentials from env vars — never hardcode
└── [dependency file]
```

**Not deployed.** Imported by all services. Local edits are visible to all services immediately via workspace configuration.

---

### [client-app] ([Framework])

```
[client-app]/
├── [src or lib]/
│   ├── [entry-point]            # Application entry point
│   ├── [routes or navigation]/  # Route definitions
│   ├── [config]/                # Environment configuration
│   ├── [screens or pages]/      # Full-page components
│   ├── [services]/              # API client classes
│   │   ├── [service-a-client]   # DI: http client + auth token provider injected via constructor
│   │   └── [service-b-client]
│   ├── [models or types]/       # Data model types
│   └── [components or widgets]/ # Reusable UI components
├── [test or __tests__]/
│   ├── [unit tests]
│   └── [integration or e2e tests]
├── [config files]
└── [dependency file]
```

**Key patterns:**
- [Note 1 — e.g., "String literals: single quotes (enforced by lint)"]
- [Note 2 — e.g., "Services: http client and auth token injected via constructor for testability"]
- [Note 3 — e.g., "Firebase/auth: use lazy initialization pattern, not constructor initialization"]

---

## docs/

```
docs/
├── INDEX.md                     # Master index — every document linked here
├── REPO_NAVIGATION.md           # This file
├── REPO_STATE.md                # Live infrastructure state (check before infra work)
│
├── services/                    # Per-service overview documents
├── api/                         # HTTP endpoint references
├── architecture/                # System-level docs and topology
├── design/                      # Feature design documents
├── adr/                         # Architectural Decision Records (immutable)
├── implementation-plans/        # Multi-task implementation plans
├── research/                    # Technology and vendor investigations
└── runbooks/                    # Operational procedures
```

**Rule:** Always check `INDEX.md` before creating a new document. Update rather than create when a document on the topic exists.

---

## CI/CD

| Service | Workflow path | Notes |
|---|---|---|
| [service-a] | `[path to CI workflow]` | [what the workflow does] |
| [service-b] | `[path to CI workflow]` | [what the workflow does] |
| [client-app] | `[path to CI workflow]` | [what the workflow does] |

[Describe your deployment target — e.g., "All Go services deploy to ECS Fargate via GitHub Actions. Secrets are in AWS Secrets Manager."]

---

## Key Coding Conventions

### [Language 1] services

- [Convention 1 — e.g., "Test package: same package as code under test, not _test suffix"]
- [Convention 2 — e.g., "Mocks: hand-written structs implementing repository interfaces"]
- [Convention 3 — e.g., "Environment variables: never hardcode credentials — use shared config package"]
- [Convention 4 — e.g., "Router: [framework name] for all services"]

### [Language/Framework 2]

- [Convention 1]
- [Convention 2]

### docs/

- Every document has frontmatter: `title`, `status`, `owner`, `created`, `last-updated`, `services`
- `last-updated` = date content was verified against reality, not just any edit
- Status values: `draft`, `proposed`, `current`, `outdated`, `stub`
- Add new document to `INDEX.md` when creating any new file
- Cross-repo links: use service names, not filesystem paths
