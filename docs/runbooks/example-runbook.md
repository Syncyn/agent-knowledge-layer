<!--
title: Rotate Internal Service Key
status: current
owner: platform-team
created: 2024-07-01
last-updated: 2024-10-15
services: [api-gateway, users-service, payments-service, notifications-service]
-->

# Rotate Internal Service Key

<!--
  TEMPLATE NOTE:
  This is an example runbook for the fictional Acme Corp platform.
  Notice the structure: clear trigger condition, prerequisites with access requirements,
  numbered steps with exact commands, and a verification section.
  This format is designed to be executable by a human or an agent at 2am.
-->

## Purpose

Rotate the `INTERNAL_SERVICE_KEY` shared secret used for service-to-service authentication. This key must be rotated after any suspected compromise, whenever a team member with access to it departs, or as part of quarterly key rotation policy.

## Trigger conditions

Run this runbook when:
- A security incident suggests the key may be compromised
- A team member with access to the AWS Secrets Manager secret leaves the team
- Quarterly rotation schedule (due every 90 days — check the Change Log below for last rotation date)

## Prerequisites

- AWS CLI configured with access to the `production` profile
- AWS IAM permission: `secretsmanager:UpdateSecret` on `acme/internal-service-key`
- AWS IAM permission: `ecs:UpdateService`, `ecs:DescribeServices` on the ECS cluster
- All production services running and healthy (check `GET /healthz` for each before starting)
- 15 minutes of low-traffic window (key rotation causes ~30 second service disruption per service during restart)

---

## Procedure

### Step 1: Generate a new key

Generate a cryptographically secure 32-byte key:

```bash
openssl rand -hex 32
```

Save the output — you'll need it in Step 2. Do not store it in a file; keep it in your clipboard or terminal session.

**Expected output:** A 64-character hex string, e.g., `a3f8b2c1...`

---

### Step 2: Update the secret in AWS Secrets Manager

```bash
aws secretsmanager update-secret \
  --secret-id acme/internal-service-key \
  --secret-string '{"key":"<NEW_KEY_HERE>"}' \
  --profile production
```

Replace `<NEW_KEY_HERE>` with the key generated in Step 1.

**Expected output:**
```json
{
  "ARN": "arn:aws:secretsmanager:us-east-1:...",
  "Name": "acme/internal-service-key",
  "VersionId": "..."
}
```

---

### Step 3: Force ECS task restart for each service

Each service must restart to pick up the new secret. Restart them in this order to minimize disruption: `notifications-service` first (least traffic), then `payments-service`, then `users-service`, then `api-gateway` last.

```bash
# Repeat for each service: notifications-service, payments-service, users-service, api-gateway
aws ecs update-service \
  --cluster acme-production \
  --service acme-production-[SERVICE_NAME] \
  --force-new-deployment \
  --profile production
```

Wait for each service to stabilize before restarting the next. Check status:

```bash
aws ecs describe-services \
  --cluster acme-production \
  --services acme-production-[SERVICE_NAME] \
  --profile production \
  --query 'services[0].deployments'
```

A service is stable when `deployments` shows one entry with `status: PRIMARY` and `runningCount` equal to `desiredCount`.

---

### Step 4: Verify inter-service calls are working

Test a flow that exercises service-to-service auth. The `payments-service` → `users-service` credits call is a reliable test:

```bash
# Trigger a test payment that will call credits (use staging environment or
# a test user account that won't affect real balances)
curl -X POST https://api.acme.io/v1/payments/test-purchase \
  -H "Authorization: Bearer <test-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"product_id": "test-product-1"}'
```

**Expected:** 200 response and the test user's credit balance increases.

---

## Verification

After completing all steps:

1. Check health of all services:
   ```bash
   for svc in api-gateway users-service payments-service notifications-service; do
     echo -n "$svc: "
     curl -s https://api.acme.io/healthz | jq '.status'
   done
   ```
   All should return `"healthy"`.

2. Check ECS service events for errors (last 5 minutes):
   ```bash
   aws ecs describe-services \
     --cluster acme-production \
     --services acme-production-users-service \
     --profile production \
     --query 'services[0].events[:5]'
   ```
   No events should mention "unable to pull secrets" or "task stopped".

3. Run the test payment from Step 4 if not already done.

---

## Rollback

If any service fails to start after the new key is deployed:

1. Update the secret back to the previous key value:
   ```bash
   aws secretsmanager update-secret \
     --secret-id acme/internal-service-key \
     --secret-string '{"key":"<PREVIOUS_KEY>"}' \
     --profile production
   ```
   Note: you need the previous key value for this. Before rotating, consider retrieving and storing the current key securely as a temporary backup.

2. Force restart any services that are failing.

3. Investigate why the new key was not accepted (check CloudWatch logs for the failing service).

---

## Escalation

- If AWS Secrets Manager update fails: contact AWS support or check IAM permissions
- If a service fails to restart after 3 attempts: page the on-call engineer (PagerDuty: Acme Platform)
- If the rollback also fails: engage the full team; do not attempt further changes until the team is assembled

## Related Documents

- [architecture/example-system-topology.md](../architecture/example-system-topology.md) — how internal service auth works
- [adr/ADR-0001-example.md](../adr/ADR-0001-example.md) — why inter-service auth uses a shared key

## Change Log

| Date | Author | Description |
|---|---|---|
| 2024-07-01 | platform-team | Initial runbook |
| 2024-10-15 | platform-team | Tested — successful rotation. Added Step 4 test procedure. |
