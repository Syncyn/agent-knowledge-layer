# API

This directory contains HTTP endpoint references for all services in the project.

## What belongs here

- Complete endpoint documentation for each deployed service
- Request and response schemas with examples
- Authentication requirements per endpoint
- Inter-service contract documentation (internal endpoints)
- Error code references

## What does NOT belong here

- API design rationale → `design/` or `adr/`
- Service architecture and dependencies → `services/`

## One file per service

Create one API reference file per service: `[service-name].md`. Do not split a service's API across multiple files. If a service has many endpoints, use clear section headers within the single file.

## Required sections

Every API reference must include (see TEMPLATE.md):

1. Frontmatter comment block
2. Overview (base URL, API version, auth model)
3. Authentication section (how to authenticate, what errors to expect)
4. Endpoint documentation for each endpoint:
   - HTTP method and path
   - Description
   - Authentication requirement
   - Request parameters/body (with types)
   - Response examples (success and error cases)
5. Error code reference

## Update cadence

API docs must be updated whenever an endpoint is added, changed, or removed. An agent that adds a new endpoint to a service should update the corresponding API doc in the same PR.

Stale API docs are worse than no docs — they send agents and engineers to implement against the wrong contract. Set `status: outdated` if you know the docs don't match the current API.

## Template

See [TEMPLATE.md](./TEMPLATE.md) to start a new API reference.
