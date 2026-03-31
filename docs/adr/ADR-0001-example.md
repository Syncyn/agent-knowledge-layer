<!--
title: Centralize Authentication in api-gateway, Not Per-Service
status: accepted
owner: platform-team
created: 2024-05-20
last-updated: 2024-05-20
services: [api-gateway, users-service, payments-service]
-->

# ADR-0001: Centralize Authentication in api-gateway, Not Per-Service

<!--
  TEMPLATE NOTE:
  This is an example ADR for a fictional "Acme Corp" platform.
  Notice the structure: clear context (the problem), a direct decision statement,
  honest consequences (including negative ones), and rejected alternatives with reasons.
  This format is what makes ADRs useful for agents — they can understand WHY the decision
  was made and won't accidentally undo it.
-->

## Status

`accepted`

## Context

The Acme platform consists of three backend services (`api-gateway`, `users-service`, `payments-service`) that all need to authenticate user requests. We need to decide whether authentication should be:

1. Handled independently in each service (each service verifies JWT tokens)
2. Centralized in `api-gateway` (gateway verifies tokens, downstream services trust a forwarded header)

Each service that independently verifies JWTs must maintain its own copy of the JWT public key and implement the same verification logic. As we add more services, this duplication grows. The verification logic also needs to be updated in every service whenever the signing algorithm or key rotation policy changes.

Additionally, the JWT library used in Go has had security advisories in the past. Centralizing verification means only one service needs to be patched for auth-related security issues.

The tradeoff is that downstream services must trust the `X-User-ID` header forwarded by `api-gateway`. This is safe only if downstream services are not accessible except through `api-gateway` — which is enforced by VPC security group rules.

## Decision

Authentication is centralized in `api-gateway`. Downstream services (`users-service`, `payments-service`) trust the `X-User-ID` header and do not perform JWT verification.

1. `api-gateway` verifies all JWT bearer tokens on every request.
2. After successful verification, `api-gateway` extracts the user ID and forwards it as `X-User-ID`.
3. Downstream services read `X-User-ID` from the request. They do not verify JWTs.
4. Downstream services are only accessible within the VPC — no public route exists to bypass `api-gateway`.
5. Service-to-service internal calls use `X-Internal-Service-Key` (a separate shared secret) rather than user JWTs.

## Consequences

### Positive

- JWT verification logic exists in one place: `api-gateway`. Key rotation and library updates are a single-service change.
- Downstream services are simpler — no auth library dependency, no key management.
- A single security audit of auth logic covers all services.
- Adding a new service does not require adding JWT verification to it.

### Negative

- Downstream services implicitly trust `api-gateway`. If `api-gateway` is compromised, downstream services have no additional auth layer.
- Developers testing `users-service` or `payments-service` locally must simulate the `X-User-ID` header, since there is no JWT verification locally.
- All traffic must go through `api-gateway` — there is no way for a client to call a service directly even if desired.

### Neutral

- VPC security groups must be configured to block direct access to downstream services. This is enforced at the infrastructure level (see Terraform configuration), not in application code.

## Alternatives Considered

### Alternative 1: Per-service JWT verification

Each service independently verifies the JWT bearer token. This is how many microservice architectures work.

**Why not chosen:** Duplication of auth logic across services. Every service needs the JWT library, the public key, and the verification implementation. Security patches to the JWT library must be applied to every service. At Acme's current scale (3 services), the overhead is manageable; as we scale to 10+ services, this becomes a significant maintenance burden. The centralized approach costs us nothing at current scale and scales much better.

### Alternative 2: Shared auth library imported by all services

A shared library handles JWT verification, imported by all services.

**Why not chosen:** This reduces code duplication but not deployment complexity — every service still needs to be rebuilt and redeployed when the auth library is updated. It also means every service still maintains its own copy of the JWT public key in its configuration. The gateway approach is strictly simpler operationally.

## Related Documents

- [architecture/overview.md](../architecture/example-system-topology.md) — system topology showing api-gateway as the entry point
- [services/api-gateway.md](../services/example-service-overview.md) — api-gateway service overview

## Change Log

| Date | Author | Description |
|---|---|---|
| 2024-05-20 | platform-team | Initial ADR; accepted without dissent |
