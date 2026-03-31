# Architectural Decision Records (ADRs)

This directory contains immutable records of significant architectural decisions made for this project.

## Why ADRs matter for AI agents

ADRs are the highest-value document type for agent effectiveness. Agents frequently undo deliberate architectural decisions because they don't know a decision was made, let alone why. An ADR tells an agent:

- What was decided
- What alternatives were considered and why they were rejected
- What consequences to expect from the decision
- What context existed at the time

This prevents agents from "helpfully" refactoring away a deliberate choice, or from asking the same architectural question that was already answered six months ago.

**When assigning a task to an agent, tell it to read the relevant ADRs first.** This is the single most impactful instruction you can add to a task description.

## What belongs here

- Decisions about technology choices (language, framework, database, cloud platform)
- Decisions about architectural patterns (monolith vs. microservices, sync vs. async, etc.)
- Decisions about security and authentication models
- Decisions that have significant long-term consequences or are difficult to reverse
- Decisions where multiple reasonable options existed and the rationale for the choice matters

## What does NOT belong here

- Implementation details that might change (configuration values, specific library versions)
- Feature designs → `design/`
- Operational procedures → `runbooks/`

## Immutability rule

ADRs are immutable once accepted. **Do not edit the Status, Context, or Decision sections of an accepted ADR.** If a decision changes, write a new ADR that supersedes the old one:

```markdown
## Status
`superseded by ADR-0007`
```

The old ADR remains in the directory — it explains why the OLD decision was made, which is still valuable historical context.

## Status vocabulary

| Status | Meaning |
|---|---|
| `proposed` | Written, circulating for review |
| `accepted` | Approved and in effect |
| `deprecated` | Was accepted but the decision is no longer in force |
| `superseded by ADR-NNNN` | Replaced by a newer ADR |

## Numbering

ADRs are numbered sequentially. When creating a new ADR:
1. Find the highest existing number
2. Use the next integer: `ADR-NNNN-short-decision-title.md`
3. Add it to `docs/INDEX.md`

## Templates

- [ADR-0000-template.md](./ADR-0000-template.md) — blank template
- [ADR-0001-example.md](./ADR-0001-example.md) — filled example
