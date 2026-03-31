<!--
title: <Runbook Title>
status: draft
owner: <team>
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
services: [service1, service2]
-->

# <Runbook Title>

## Purpose

[What does this runbook do? One sentence.]

## Trigger conditions

Run this runbook when:

- [Condition 1 — e.g., a specific alert fires]
- [Condition 2 — e.g., quarterly rotation schedule]
- [Condition 3 — e.g., after a team member departs]

## Prerequisites

- [Access requirement 1 — e.g., AWS IAM permission: secretsmanager:UpdateSecret]
- [Tool requirement — e.g., AWS CLI configured with production profile]
- [Environment requirement — e.g., services must be healthy before starting]

---

## Procedure

### Step 1: [Action]

[Description of what this step does and why.]

```bash
[Command to run]
```

**Expected output:** [What success looks like]

---

### Step 2: [Action]

[Description.]

```bash
[Command]
```

**Expected output:** [What success looks like]

---

## Verification

After completing all steps, verify success:

1. [Verification step 1]
   ```bash
   [Command]
   ```
   Expected: [what you should see]

2. [Verification step 2]

---

## Rollback

If the procedure fails or causes unintended effects:

1. [Rollback step 1]
2. [Rollback step 2]

---

## Escalation

- If [condition]: [who to contact / what to do]
- If the rollback also fails: [escalation path]

## Related Documents

- <!-- Link to architecture docs, ADRs, or other runbooks -->

## Change Log

| Date | Author | Description |
|---|---|---|
| YYYY-MM-DD | | Initial draft |
