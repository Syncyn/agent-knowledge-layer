<!--
title: WebSocket vs. Server-Sent Events for Real-Time Notifications
status: current
owner: platform-team
created: 2024-09-05
last-updated: 2024-09-05
services: [notifications-service, web-client]
-->

# WebSocket vs. Server-Sent Events for Real-Time Notifications

<!--
  TEMPLATE NOTE:
  This is an example research document for the fictional Acme Corp platform.
  Notice: the Executive Summary states the conclusion FIRST — this is the most important
  convention for research docs. Agents (and engineers) should be able to act on the
  recommendation without reading the full document.
-->

## Executive Summary

For Acme's notification system, **WebSocket is the recommended choice** despite SSE being simpler for the current use case. The deciding factor is forward compatibility: we anticipate wanting bidirectional real-time communication (e.g., collaborative editing, live presence) within 12 months, and upgrading from SSE to WebSocket at that point would require changes to both the server and all clients. WebSocket at parity cost now avoids that migration.

If the project required notifications only and there was no anticipated need for bidirectional communication, SSE would be the correct choice.

---

## Context

We need a real-time delivery mechanism for `notifications-service` to push events to web clients. The two primary candidates are:

- **Server-Sent Events (SSE):** HTTP-based, unidirectional (server → client only), native browser support via `EventSource` API
- **WebSocket:** TCP-based, bidirectional, native browser support, more complex server implementation

---

## Comparison

### Protocol complexity

**SSE:** Built on regular HTTP. Works through proxies and load balancers without special configuration. `EventSource` API is simple: `const es = new EventSource('/events')`.

**WebSocket:** Requires HTTP upgrade handshake. Some load balancers need explicit WebSocket support configuration (AWS ALB supports it by default since 2018). `WebSocket` API is slightly more complex but well-understood.

**Edge cases:**
- SSE connections are dropped by some corporate proxies. This affects a non-trivial portion of enterprise users.
- WebSocket connections are more reliably maintained across diverse network environments.

### Directionality

**SSE:** Server → client only. If a client needs to send data to the server (e.g., acknowledge receipt, send a ping), it must use a separate HTTP request.

**WebSocket:** Bidirectional. Client and server can send messages at any time.

**For our current use case** (delivering notifications to clients), SSE is sufficient. However, for future use cases (collaborative editing, live presence indicators, real-time multiplayer features), WebSocket is required.

### Go server implementation

**SSE:**
```go
// Set headers and write events
w.Header().Set("Content-Type", "text/event-stream")
w.Header().Set("Cache-Control", "no-cache")
fmt.Fprintf(w, "data: %s\n\n", jsonPayload)
w.(http.Flusher).Flush()
```

**WebSocket** (using `gorilla/websocket`):
```go
upgrader := websocket.Upgrader{...}
conn, err := upgrader.Upgrade(w, r, nil)
conn.WriteMessage(websocket.TextMessage, jsonPayload)
```

WebSocket requires a third-party library (`gorilla/websocket` or `nhooyr.io/websocket`); SSE uses only stdlib. Both are well-understood patterns. Implementation complexity is roughly equivalent for our use case.

### Connection management

Both protocols require connection registries on the server:
- SSE: `sync.Map[userID]http.ResponseWriter`
- WebSocket: `sync.Map[userID]*websocket.Conn`

For our connection registry, the patterns are identical. No advantage to either.

### Client-side reconnection

**SSE:** The `EventSource` API reconnects automatically after disconnection. Built-in.

**WebSocket:** Client code must implement its own reconnection logic with backoff.

This is a real advantage for SSE in terms of client complexity.

### Load balancer compatibility

Both work through the AWS ALB used by Acme's ECS services. ALB has native WebSocket support. No additional configuration required for either.

---

## Decision Factors

| Factor | SSE | WebSocket | Winner |
|---|---|---|---|
| Server implementation complexity | Low | Medium | SSE |
| Client implementation complexity | Low (auto-reconnect) | Medium (manual reconnect) | SSE |
| Bidirectionality | No | Yes | WebSocket |
| Proxy/corporate network compatibility | Fair | Good | WebSocket |
| Forward compatibility (future features) | Poor | Good | WebSocket |
| Go stdlib sufficiency | Yes | No (needs library) | SSE |

---

## Recommendations

1. **Use WebSocket** for the notification system, accepting the slightly higher implementation cost in exchange for forward compatibility.

2. **Use `gorilla/websocket`** as the Go library — it is the most widely used, well-maintained, and documented WebSocket library in the Go ecosystem. `nhooyr.io/websocket` is a newer alternative worth evaluating if `gorilla/websocket` shows signs of reduced maintenance.

3. **Implement client-side exponential backoff reconnection** in the web client from day one. Use an initial delay of 1s, doubling up to 30s maximum.

4. **File an ADR** (ADR-0002) to record this decision for future reference.

## Related Documents

- [design/example-feature-design.md](../design/example-feature-design.md) — notification system design (references this research)
- [implementation-plans/example-plan.md](../implementation-plans/example-plan.md) — implementation plan for the notification system

## Change Log

| Date | Author | Description |
|---|---|---|
| 2024-09-05 | platform-team | Initial research |
