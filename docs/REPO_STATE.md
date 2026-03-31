<!--
title: REPO_STATE — Live Infrastructure State
status: current
owner: [platform-team or devops]
created: YYYY-MM-DD
last-updated: YYYY-MM-DD
-->

# REPO_STATE — Live Infrastructure State

**Purpose:** Tracks the current infrastructure state of every service so agents do not apply outdated patterns to services that have already migrated. Check this file before generating infrastructure-touching code for any service.

**Update this file** whenever a service migrates, a phase completes, or a significant infrastructure change is made. The `last-updated` date in the frontmatter should reflect when this was last verified against reality.

---

## Infrastructure Platform by Service

<!--
  List every service and its current compute, database, and migration status.
  This table is the primary reference for agents deciding which patterns to use.
  A service that has migrated from platform A to platform B must be clearly marked.
-->

| Service | Compute | Primary DB | Secondary Store | Status |
|---|---|---|---|---|
| [service-a] | [e.g., AWS ECS Fargate / GCP Cloud Run / K8s] | [e.g., PostgreSQL / MongoDB / Firestore] | [e.g., Redis / S3] | [e.g., Active / Migrating / Deprecated] |
| [service-b] | [compute] | [database] | [store] | [status] |
| [service-c] | [compute] | [database] | [store] | [status] |
| [client-app] | [e.g., iOS/Android/web] | — | — | No migration needed |

---

## Migration Phase Summary

<!--
  If your project is mid-migration (cloud platform, database, auth provider),
  document each phase clearly. Agents must know which services have completed
  each phase vs. which are still on the old pattern.

  The most common agent mistake this file prevents: generating code for platform A
  on a service that has already migrated to platform B.
-->

### Phase [N] — [Phase Name] — [STATUS: COMPLETE / IN PROGRESS / PENDING]

[Describe what changed. Which services were affected. What the new pattern is.]

**New pattern after this phase:**
```
[Example: env var CREDENTIALS_JSON is injected at runtime from AWS Secrets Manager]
[Example: services now behind ALB at api-[service].yourdomain.com]
```

### Phase [N+1] — [Next Phase Name] — PENDING

[Describe what will change. Which services are affected. Target timeline if known.]

---

## Key Infrastructure Facts for Agents

<!--
  This section is specifically for preventing common agent mistakes.
  List patterns that USED to apply but no longer do, and patterns that are NEW.
  Format: "Do NOT assume X" followed by "The current pattern is Y".
-->

### Do NOT assume these old patterns still apply:

- [Example: `option.WithCredentialsFile("sa.json")` — services now use `CREDENTIALS_JSON` env var]
- [Example: Cloud Run service URLs (`*.run.app`) — services are on ECS behind ALB]
- [Example: `cloudbuild.yaml` — replaced by GitHub Actions workflows]
- [Example: GCS for media — [service-name] media now goes to S3]

### Current patterns (all active services):

```
[ENV_VAR_1]  → [where it comes from, e.g., injected from AWS Secrets Manager]
[ENV_VAR_2]  → [e.g., written at startup by shared init package]
[ENV_VAR_3]  → [e.g., [service-a] only — database connection string]
```

### [Service-specific notes]

- [service-a]: [Any service-specific infrastructure notes agents should know]
- [service-b]: [Any service-specific notes]

---

## Infrastructure as Code

<!--
  Tell agents where to find IaC if they need to understand or modify it.
  Also tell them what NOT to do — e.g., if Terraform has ignore_changes on
  task_definition, agents need to know that deploying is done via CI, not terraform apply.
-->

- **IaC tool:** [Terraform / Pulumi / CDK / none]
- **IaC location:** [path or separate repo]
- **Deployment method:** [GitHub Actions / manual / etc.]
- **Important:** [Any IaC gotchas — e.g., "lifecycle ignore_changes on task_definition means CI deploys, not terraform apply"]

---

## DNS / Routing Status

[Describe current DNS setup. Are all services accessible? Any pending DNS cutover?]

---

## Active Risks / Known Issues

| Risk | Severity | Notes |
|---|---|---|
| [Risk 1] | High / Medium / Low | [What it is and how to avoid triggering it] |
| [Risk 2] | Medium | [Description] |
