# Architecture

This directory contains system-level architecture documentation: service topology, data models, cross-cutting concerns, and infrastructure overviews.

## What belongs here

- System topology documents (how all services connect, what calls what)
- Data model documentation (database schemas, collection structures, data ownership)
- Cross-cutting architectural concerns (authentication model, shared infrastructure, caching strategy)
- Feature-level architecture when the feature spans multiple services
- Infrastructure diagrams and data flow documentation

## What does NOT belong here

- Feature design documents (pre-implementation planning) → `design/`
- Per-service detailed documentation → `services/`
- Architectural decisions and their rationale → `adr/`
- API endpoint references → `api/`

## When to create vs. update existing

Prefer updating existing documents when a change affects an existing architectural concern. Create a new document when:
- Introducing a new cross-service pattern (e.g., a new authentication mechanism, a new data pipeline)
- Documenting a significant new subsystem
- The existing document would become unwieldy if extended

One document per major architectural topic. Do not create separate documents for minor variations.

## Required sections

Every architecture document must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Overview — a 2-4 sentence description of what this document covers
3. Diagram — Mermaid or ASCII diagram of the relevant topology or data flow
4. Detailed description — prose explanation of the diagram
5. Key decisions — links to relevant ADRs
6. Related Documents
7. Change Log

## Template

See [TEMPLATE.md](./TEMPLATE.md) to start a new architecture document.
