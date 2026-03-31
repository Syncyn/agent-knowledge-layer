# Runbooks

This directory contains operational runbooks for the project.

## What belongs here

- Step-by-step procedures for common operational tasks (deployments, rollbacks, secret rotation)
- Incident response playbooks for known failure modes
- Maintenance procedures (database migrations, cache flushes, certificate renewals)
- Any procedure complex enough that you wouldn't want to do it from memory at 2am

## When to create new vs. update existing

Create one runbook per distinct operational procedure. Update the existing runbook if the procedure changes. Retire a runbook by setting its `status` to `retired` when the procedure is no longer applicable — do not delete it. Retired runbooks are historical records.

## Required sections

Every runbook must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Purpose — what this runbook does and when to use it
3. Trigger conditions — exactly when to run this runbook
4. Prerequisites — access, tools, environment needed
5. Step-by-step procedure — numbered, specific, executable
6. Verification — how to confirm the procedure succeeded
7. Rollback — how to undo the procedure if it goes wrong
8. Escalation — who to contact if the runbook fails
9. Related Documents
10. Change Log

## For agents

Agents can use runbooks to perform operational tasks autonomously when they have the required access. The step-by-step format is designed to be agent-executable: each step produces a specific, verifiable outcome. Agents should:

- Verify prerequisites before starting
- Execute steps in order
- Verify each step's output before proceeding to the next
- Run the verification section after completing all steps
- Stop and escalate if any step produces unexpected output

## Testing cadence

Test each runbook at least quarterly, or after any change to the systems it covers. Update `last-updated` after each test run and note the outcome in the Change Log. Runbooks that have not been tested in 6 months should have `status: outdated` set.

## Template

See [TEMPLATE.md](./TEMPLATE.md) to start a new runbook.
