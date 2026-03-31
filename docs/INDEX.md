<!--
title: [YOUR_PROJECT_NAME] Docs — Master Index
status: current
owner: engineering
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
services: [all]
-->

# [YOUR_PROJECT_NAME] Docs — Master Index

This file is the single entry point for all documentation. Every document is listed here with a one-line description and a relative link.

For onboarding guidance and contribution rules, see [README.md in the docs root or your project root]. For a complete directory tree, see [REPO_NAVIGATION.md](./REPO_NAVIGATION.md). For live infrastructure state, see [REPO_STATE.md](./REPO_STATE.md).

**Rule for agents:** Before creating any new document, check this index. If a document on your topic exists, update it rather than creating a duplicate.

---

## Navigation and Meta-Docs

| Document | Description |
|---|---|
| [REPO_NAVIGATION.md](./REPO_NAVIGATION.md) | Canonical project directory tree — every service, key file, build commands, CI/CD map, and coding conventions — read this instead of running ls/find |
| [REPO_STATE.md](./REPO_STATE.md) | Live infrastructure state — compute platforms, databases, active migrations, patterns that no longer apply — check before writing infrastructure code |

---

## Services

Per-service overview documents covering responsibilities, dependencies, configuration, and known issues.

| Document | Description |
|---|---|
| [services/service-a.md](./services/service-a.md) | [Service A]: [one-line description of responsibilities] |
| [services/service-b.md](./services/service-b.md) | [Service B]: [one-line description of responsibilities] |
| [services/service-c.md](./services/service-c.md) | [Service C]: [one-line description of responsibilities] |
| [services/README.md](./services/README.md) | Directory guide: what belongs here and how to add a new service doc |

---

## Architecture

System-level architecture overviews, service topology, data flow, and cross-cutting concerns.

| Document | Description |
|---|---|
| [architecture/overview.md](./architecture/overview.md) | Top-level system overview: all services, roles, communication patterns, authentication model, infrastructure |
| [architecture/data-model.md](./architecture/data-model.md) | Data model: databases, tables/collections, schemas, cross-service data ownership |
| [architecture/README.md](./architecture/README.md) | Directory guide: what belongs here and when to create vs. update |

---

## API

HTTP endpoint references, request/response schemas, and inter-service contracts.

| Document | Description |
|---|---|
| [api/service-a.md](./api/service-a.md) | [Service A] endpoints: [summary of key endpoints] |
| [api/service-b.md](./api/service-b.md) | [Service B] endpoints: [summary of key endpoints] |
| [api/README.md](./api/README.md) | Directory guide: what belongs here and update cadence |

---

## Design

Feature and system design documents written before or during implementation.

| Document | Description |
|---|---|
| [design/example-feature.md](./design/example-feature.md) | [Feature name]: [one-line description of what design covers] |
| [design/README.md](./design/README.md) | Directory guide: what belongs here and document lifecycle |

---

## Architectural Decision Records

| Document | Description |
|---|---|
| [adr/ADR-0001-example.md](./adr/ADR-0001-example.md) | [Decision title]: [accepted/proposed/deprecated] — [one-line description] |
| [adr/README.md](./adr/README.md) | Directory guide: ADR format, immutability rules, status vocabulary |

---

## Agent Definitions

Capability definitions for each agent type used in implementation plans — domain, triggers, required context, and invocation notes.

| Document | Description |
|---|---|
| [agents/example-backend-engineer.md](./agents/example-backend-engineer.md) | backend-engineer: server-side features, API endpoints, database layers, service integrations |
| [agents/README.md](./agents/README.md) | Directory guide: what belongs here, relationship to implementation plans |

---

## Implementation Plans

Multi-agent task plans with acceptance criteria. Each task's `Assignee:` field references an agent defined in `docs/agents/`.

| Document | Description |
|---|---|
| [implementation-plans/example-plan.md](./implementation-plans/example-plan.md) | [Plan title]: [what it achieves, N steps, current phase] |
| [implementation-plans/README.md](./implementation-plans/README.md) | Directory guide: plan format and agent assignment conventions |

---

## Research

Technology investigations and vendor evaluations.

| Document | Description |
|---|---|
| [research/example-research.md](./research/example-research.md) | [Research title]: [one-line summary of findings] |
| [research/README.md](./research/README.md) | Directory guide: research vs. ADR distinction, required sections |

---

## Runbooks

Operational procedures for deployments, incidents, and maintenance.

| Document | Description |
|---|---|
| [runbooks/example-runbook.md](./runbooks/example-runbook.md) | [Runbook title]: [trigger condition and procedure summary] |
| [runbooks/README.md](./runbooks/README.md) | Directory guide: runbook format, testing cadence |
