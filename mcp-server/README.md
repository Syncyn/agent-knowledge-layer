# Knowledge MCP Server

A local MCP (Model Context Protocol) server that exposes your documentation hub as queryable tools for AI agents. This is the power-user tier of the agent-docs system.

## What it does

Without the MCP server, agents read your docs the same way they read any file: with file-read tool calls. This works and is a major improvement over having no docs. But agents still spend tokens on:
- Deciding which file to read
- Parsing prose documentation into structured facts
- Reading potentially outdated cached content

The knowledge MCP server wraps your docs directory and git history into structured JSON tools. Agents call `get_service_context("payments-service")` and get a structured response immediately, without reading any files themselves.

Example interaction:

```
Agent: [calls get_service_context("payments-service")]
MCP:   {
         "service": "payments-service",
         "language": "Go",
         "responsibilities": "...",
         "callers": [{"service": "api-gateway", "auth": "X-User-ID"}],
         "calls": [{"dep": "users-service", "endpoint": "/internal/credits"}],
         "known_issues": [...],
         "recent_changes": [
           {"hash": "a3f8b2", "message": "Add idempotency check to credits endpoint", "date": "2024-11-10"}
         ],
         "last_updated": "2024-11-15",
         "source_path": "docs/services/payments-service.md"
       }
```

## When to add the MCP server

The plain Markdown docs work immediately and are worth adopting regardless of whether you add the MCP server. Add the MCP server when:

- You have 5+ services and agents spend significant time on doc reads
- You want agents to automatically have recent git context alongside the docs
- You want to add live infrastructure queries (ECS health, database state)
- You are running agents in an automated pipeline where latency matters

## Architecture

The MCP server is a small TypeScript/Node.js application that:

1. Reads your `docs/` directory
2. Parses frontmatter and Markdown structure
3. Exposes the parsed content as MCP tools
4. Optionally queries git log for recent changes
5. Optionally queries cloud infrastructure for live state

It runs locally (no cloud deployment needed) and is invoked by Claude Code as a subprocess via stdio transport.

## Setup

### 1. Scaffold the server

```bash
mkdir knowledge-mcp && cd knowledge-mcp
npm init -y
npm install @modelcontextprotocol/sdk gray-matter marked
npm install -D typescript @types/node
```

Create `src/index.ts` following the MCP SDK server pattern. See `example-tools.md` for the full tool designs.

### 2. Configure Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "knowledge-mcp": {
      "command": "node",
      "args": ["/absolute/path/to/knowledge-mcp/dist/index.js"],
      "env": {
        "DOCS_PATH": "/absolute/path/to/your/project/docs",
        "REPO_PATH": "/absolute/path/to/your/project"
      }
    }
  }
}
```

### 3. Build and verify

```bash
npm run build
# Reload MCP servers in Claude Code
# Test: ask Claude "call list_services and tell me what you get"
```

## Design principles

These come from building `syncyn-knowledge-mcp` and learning what works:

**Return structured JSON, not prose.** Agents reason more reliably over structured data. A response with `{"callers": [{"service": "api-gateway"}]}` is easier to act on than "api-gateway calls this service."

**Include `last_updated` and `source_path` in every response.** Agents should know how fresh the data is and where to go if they need more detail.

**Fail informatively.** `"service 'payments-svc' not found — did you mean 'payments-service'?"` is dramatically better than a generic error. Name matching should be fuzzy.

**Cache on git commit hash.** Most structural questions can be answered from last-commit data. Check git HEAD, return cached response if the hash hasn't changed. This makes repeated tool calls essentially free.

**Don't over-build Phase 1.** Four tools (`list_services`, `get_service_context`, `get_dependency_graph`, `search_docs`) cover 80% of agent needs. Add live infrastructure tools in Phase 2 once the basics are working.

## Phase 1 tools (start here)

These four tools have the highest return on investment and are straightforward to implement.

See `example-tools.md` for detailed designs and example response shapes.

| Tool | Description |
|---|---|
| `list_services` | All services with one-line descriptions and technology tags |
| `get_service_context` | Service doc content + recent git log + dependency summary |
| `get_infra_state` | REPO_STATE.md parsed as structured JSON |
| `search_docs` | Ripgrep-based full-text search across docs/, returns file + line + context |

## Phase 2 tools (add when needed)

| Tool | Description |
|---|---|
| `get_api_endpoints` | Parse router files → structured endpoint list (method, path, auth) |
| `get_recent_changes` | Structured git log for a service over N days |
| `get_dependency_graph` | Inter-service call relationships from dependency-graph.json |
| `check_adr` | Look up ADRs relevant to a topic or service |

## Phase 3 tools (live infrastructure)

These require cloud CLI access. Only add when agents are doing infrastructure work regularly.

| Tool | Description |
|---|---|
| `get_ecs_health` | ECS service status, running task count, recent deployment events |
| `get_database_state` | Database connectivity, table sizes, migration status |
| `list_secrets` | AWS/GCP secrets (names only, not values) available to each service |

## Keeping it working

The MCP server reads your docs files at query time — it doesn't maintain a separate index that can drift. The only thing that can make it stale is if the docs themselves are stale. This is by design: the maintenance surface is just keeping docs accurate, not maintaining a separate tool.

Run `npm run build` after any changes to the MCP server code. Restart Claude Code to reload the server.
