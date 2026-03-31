# Design

This directory contains feature and system design documents — written before or during implementation to record the reasoning behind significant features.

## What belongs here

- Feature designs that span multiple components or services
- System designs that require architectural thought (e.g., a new caching layer, a data pipeline)
- UI/UX designs that have meaningful backend implications
- Design documents that were written to align a team before implementation started

## What does NOT belong here

- Post-hoc documentation of how something works → `architecture/` or `services/`
- Architectural decisions with rationale → `adr/` (after the decision is made)
- Step-by-step implementation plans with task assignments → `implementation-plans/`

## Relationship to ADRs and implementation plans

A design document describes **what** and **why** at a feature level. When a design involves a significant decision that will affect future work, extract that decision into an ADR. When a design is approved and ready to implement, create an implementation plan that breaks it into assignable tasks.

Typical lifecycle: design doc (proposal) → review → ADR (if decision is significant) → implementation plan → work complete → design doc status set to `current`

## Required sections

Every design document must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Problem Statement
3. Goals
4. Non-Goals
5. Design Overview
6. Detailed Design (data model, API changes, flow diagram, error handling)
7. Alternatives Considered
8. Open Questions
9. Related Documents
10. Change Log

## Template

See [TEMPLATE.md](./TEMPLATE.md) to start a new design document.
