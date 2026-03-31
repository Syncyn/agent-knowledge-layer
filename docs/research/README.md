# Research

This directory contains technology investigations, vendor evaluations, and feasibility studies.

## What belongs here

- Technology investigations (evaluating libraries, frameworks, protocols, tools)
- API feasibility research (third-party API capabilities, pricing, integration complexity)
- Legal and compliance research (licensing, data protection, platform policies)
- Vendor evaluations (comparing services or providers before a decision is made)
- "Should we use X?" documents

## What does NOT belong here

- Decisions — once a conclusion is acted on, file an ADR in `adr/`
- Feature designs — `design/`
- Post-hoc documentation — `services/` or `architecture/`

## Research vs. ADR distinction

Research documents inform decisions but are not decisions themselves. The lifecycle is:

1. Write a research document here: "Should we use X?"
2. Reach a conclusion
3. Write an ADR in `adr/`: "We decided to use X because..."
4. Reference the research document from the ADR's Context section

Research documents may be outdated without being wrong — technology changes. Set `status: outdated` when you know the findings need refreshing, and link to the ADR that acted on them.

## Required sections

Every research document must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Executive Summary — state the conclusion first (2-4 sentences)
3. Research body (format varies by topic)
4. Recommendations — actionable next steps
5. Related Documents
6. Change Log

## Status vocabulary for research documents

| Status | Meaning |
|---|---|
| `draft` | In progress; findings incomplete |
| `current` | Complete and reflects current understanding |
| `outdated` | Findings are stale; refresh before acting on them |

## Update cadence

Research documents should be reviewed before acting on their recommendations. If more than 90 days have passed or the underlying technology has changed significantly, set `status: outdated` and refresh the document or write a new one.

## Template

See [TEMPLATE.md](./TEMPLATE.md) to start a new research document.
