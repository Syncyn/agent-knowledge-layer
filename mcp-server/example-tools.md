# Knowledge MCP Server — Tool Designs

Detailed designs for each MCP tool: what it does, why it exists, the implementation approach, and the response shape.

---

## Tool 1: `list_services`

### Why it exists

The first thing an agent needs when picking up a task is orientation: what services exist, what they do, which one is relevant to this task. Without this tool, agents either read the whole `docs/INDEX.md` (wastes tokens on irrelevant entries) or guess from the directory structure (misses context).

### Inputs

None.

### Implementation

Read all files in `docs/services/` that match `*.md` (excluding `README.md`, `TEMPLATE.md`). Parse frontmatter for `title`, `status`, `services`. Extract the first paragraph of prose after the service overview table.

### Response shape

```json
{
  "services": [
    {
      "name": "users-service",
      "language": "Go",
      "one_line": "User profile CRUD, avatar upload, account credits, connections",
      "status": "current",
      "doc_path": "docs/services/users-service.md"
    },
    {
      "name": "payments-service",
      "language": "Go",
      "one_line": "Payment processing, subscription management, billing",
      "status": "current",
      "doc_path": "docs/services/payments-service.md"
    }
  ],
  "total": 3,
  "last_updated": "2024-11-15"
}
```

---

## Tool 2: `get_service_context`

### Why it exists

This is the highest-value tool. When an agent is assigned to work on a specific service, it needs:
- What the service does
- What calls it (so it doesn't break those callers)
- What it calls (so it knows its dependencies)
- Recent changes (so it doesn't re-implement something just merged)
- Known issues (so it doesn't step on existing bugs)

Without this tool, gathering this context requires reading `docs/services/[service].md`, `docs/api/[service].md`, and running `git log --oneline -10` — three operations and significant parsing work.

### Inputs

```typescript
{
  service: string  // Service name, fuzzy-matched
}
```

### Implementation

1. Find the service doc in `docs/services/[service].md` (fuzzy match on filename)
2. Parse the full Markdown, extracting sections by header
3. Run `git log --oneline -10 -- [service-directory]/` for recent commits
4. Extract Callers and Calls tables from the service doc

### Response shape

```json
{
  "service": "users-service",
  "language": "Go",
  "responsibilities": "User profile CRUD, avatar upload to S3, account credits, connection management",
  "callers": [
    {"service": "api-gateway", "endpoints": "all /v1/* routes", "auth": "X-User-ID header"},
    {"service": "payments-service", "endpoints": "POST /internal/users/{id}/credits", "auth": "X-Internal-Service-Key"}
  ],
  "calls": [
    {"dependency": "PostgreSQL (users-db)", "purpose": "primary data store"},
    {"dependency": "S3 (acme-media)", "purpose": "avatar storage"},
    {"dependency": "notifications-service", "purpose": "POST /internal/notify"}
  ],
  "known_issues": [
    "Avatar confirm race condition (GH-412)",
    "No pagination on /v1/users/{id}/connections (GH-438)"
  ],
  "recent_changes": [
    {"hash": "a3f8b2c", "message": "Add idempotency check to credits endpoint", "date": "2024-11-10"},
    {"hash": "9c2d4e1", "message": "Fix avatar URL not updating after confirm", "date": "2024-11-08"}
  ],
  "doc_status": "current",
  "last_updated": "2024-11-15",
  "source_path": "docs/services/users-service.md"
}
```

### Error handling

```json
{
  "error": "service 'users-svc' not found",
  "suggestions": ["users-service", "users-worker"],
  "available_services": ["api-gateway", "users-service", "payments-service"]
}
```

---

## Tool 3: `get_infra_state`

### Why it exists

Agents writing infrastructure code need to know the current platform for each service. Without this, agents generate code for the wrong platform (e.g., Cloud Run patterns for a service that has migrated to ECS). `docs/REPO_STATE.md` contains this information, but parsing it manually is tedious.

### Inputs

```typescript
{
  service?: string  // Optional — if provided, returns state for one service only
}
```

### Implementation

Parse `docs/REPO_STATE.md`. Extract the infrastructure table rows. If `service` is provided, filter to that service.

### Response shape

```json
{
  "services": {
    "users-service": {
      "compute": "AWS ECS Fargate (us-east-1)",
      "primary_db": "PostgreSQL",
      "secondary_store": "S3 (acme-media)",
      "migration_status": "Active — no migration in progress"
    },
    "payments-service": {
      "compute": "AWS ECS Fargate (us-east-1)",
      "primary_db": "PostgreSQL",
      "secondary_store": null,
      "migration_status": "Active — no migration in progress"
    }
  },
  "active_migrations": [],
  "patterns_no_longer_valid": [
    "Cloud Run service URLs (*.run.app) — services are on ECS behind ALB",
    "cloudbuild.yaml — replaced by GitHub Actions"
  ],
  "last_updated": "2024-11-15",
  "source_path": "docs/REPO_STATE.md"
}
```

---

## Tool 4: `search_docs`

### Why it exists

Sometimes an agent needs to find documentation about a specific topic (e.g., "how does avatar upload work?" or "what does the X-Internal-Service-Key header do?") without knowing which file contains the answer. Full-text search across the docs directory handles this.

### Inputs

```typescript
{
  query: string,          // Search query
  service?: string,       // Optional — limit search to docs tagged with this service
  doc_type?: string       // Optional — limit to a directory: 'services', 'adr', 'api', etc.
}
```

### Implementation

Run `ripgrep` (or equivalent) across the `docs/` directory. Return file path, line number, and surrounding context. Filter by frontmatter `services` field if `service` is provided.

### Response shape

```json
{
  "query": "X-Internal-Service-Key",
  "matches": [
    {
      "file": "docs/architecture/example-system-topology.md",
      "line": 42,
      "context": "Service-to-service calls use an internal X-Internal-Service-Key header rather than user JWTs.",
      "section": "Communication Patterns"
    },
    {
      "file": "docs/adr/ADR-0001-example.md",
      "line": 67,
      "context": "Service-to-service internal calls use X-Internal-Service-Key (a separate shared secret)",
      "section": "Decision"
    },
    {
      "file": "docs/runbooks/example-runbook.md",
      "line": 15,
      "context": "X-Internal-Service-Key: <shared-secret>",
      "section": "Prerequisites"
    }
  ],
  "total_matches": 3
}
```

---

## Implementation notes

### MCP server skeleton (TypeScript)

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import * as fs from "fs";
import * as path from "path";
import matter from "gray-matter";

const DOCS_PATH = process.env.DOCS_PATH || "./docs";
const REPO_PATH = process.env.REPO_PATH || ".";

const server = new Server(
  { name: "knowledge-mcp", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "list_services",
      description: "Returns all services with one-line descriptions and status",
      inputSchema: { type: "object", properties: {} }
    },
    {
      name: "get_service_context",
      description: "Returns full context for a service: responsibilities, callers, calls, known issues, recent git changes",
      inputSchema: {
        type: "object",
        properties: {
          service: { type: "string", description: "Service name (fuzzy matched)" }
        },
        required: ["service"]
      }
    },
    {
      name: "get_infra_state",
      description: "Returns current infrastructure state from REPO_STATE.md",
      inputSchema: {
        type: "object",
        properties: {
          service: { type: "string", description: "Optional — filter to one service" }
        }
      }
    },
    {
      name: "search_docs",
      description: "Full-text search across docs/ directory",
      inputSchema: {
        type: "object",
        properties: {
          query: { type: "string" },
          doc_type: { type: "string", description: "Optional: services, adr, api, architecture, etc." }
        },
        required: ["query"]
      }
    }
  ]
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case "list_services":
      return { content: [{ type: "text", text: JSON.stringify(listServices(), null, 2) }] };
    // ... implement other tools
    default:
      throw new Error(`Unknown tool: ${request.params.name}`);
  }
});

function listServices() {
  const servicesDir = path.join(DOCS_PATH, "services");
  const files = fs.readdirSync(servicesDir)
    .filter(f => f.endsWith(".md") && f !== "README.md" && f !== "TEMPLATE.md");

  return {
    services: files.map(f => {
      const content = fs.readFileSync(path.join(servicesDir, f), "utf-8");
      const { data } = matter(content);
      return {
        name: f.replace(".md", ""),
        language: extractLanguage(content),
        one_line: extractFirstParagraph(content),
        status: data.status,
        doc_path: `docs/services/${f}`
      };
    }),
    total: files.length,
    last_updated: new Date().toISOString().split("T")[0]
  };
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}
main().catch(console.error);
```

### Caching strategy

Cache expensive operations (git log, file parsing) on git HEAD hash:

```typescript
import { execSync } from "child_process";

let cache: Map<string, { hash: string; data: unknown }> = new Map();

function getGitHead(): string {
  try {
    return execSync("git rev-parse HEAD", { cwd: REPO_PATH }).toString().trim();
  } catch {
    return "unknown";
  }
}

function cachedOp<T>(key: string, compute: () => T): T {
  const hash = getGitHead();
  const cached = cache.get(key);
  if (cached && cached.hash === hash) return cached.data as T;
  const data = compute();
  cache.set(key, { hash, data });
  return data;
}
```

This makes repeated tool calls within the same session essentially free.
