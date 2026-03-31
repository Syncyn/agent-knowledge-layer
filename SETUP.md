# Setup Guide — Adopting the Agent-Docs System

This guide walks through adopting this documentation system for an existing project. Budget about an hour for the initial setup; the ongoing cost is keeping docs current when systems change.

> **Prefer automation?** See `scripts/setup.sh` (macOS/Linux) or `scripts/setup.ps1` (Windows) for a script that handles the directory structure and scaffolding steps automatically. Manual steps that require project-specific knowledge (service names, stack details) still need to be filled in — but see the **agent prompts** in each step for how to have an AI agent draft those for you.

---

## Prerequisites

- A software project with at least one service or application component
- Git
- `claude` CLI (or equivalent AI coding agent) — used to invoke agents for the drafting prompts

---

## What is a workspace?

A **workspace** is a directory on your machine that contains one or more code repositories you actively work on together. It is the directory you `cd` into before starting development — the common parent of your repos.

```
~/workspace/               ← your workspace (this is where CLAUDE.md lives)
├── api-service/           ← git repo
├── worker-service/        ← git repo
├── frontend/              ← git repo
└── docs/                  ← git repo (or plain directory)
```

Your workspace is the directory where you run `claude` (or your AI agent CLI) from. Claude Code reads `CLAUDE.md` from that directory automatically, so placing it at the workspace root means agents always see your instructions and project context — regardless of which individual repo they're currently editing.

**For a monorepo** (all code in one repo): your workspace root and your repo root are the same directory. No distinction needed.

**For multiple separate repos**: the workspace root is the directory *above* all of them. This is where `CLAUDE.md` goes — not inside any individual service repo.

> **How to find your workspace root:** Open your terminal and run `pwd` after navigating to where you normally start work. If you always do `cd ~/workspace && claude`, then `~/workspace` is your workspace root.

---

## Step 1: Create the directory structure (2 minutes)

**Automated (recommended):** run the setup script for your platform. See `scripts/README.md` for full usage details and troubleshooting.

```bash
# macOS / Linux / WSL — Option A: run from your workspace root
cd ~/workspace
bash /path/to/agent-knowledge-layer/scripts/setup.sh

# macOS / Linux / WSL — Option B: pass the path explicitly
bash /path/to/agent-knowledge-layer/scripts/setup.sh ~/workspace
```

```powershell
# Windows PowerShell — Option A: run from your workspace root
cd C:\Users\you\workspace
.\path\to\agent-knowledge-layer\scripts\setup.ps1

# Windows PowerShell — Option B: pass the path explicitly
.\path\to\agent-knowledge-layer\scripts\setup.ps1 -WorkspaceRoot "C:\Users\you\workspace"
```

> **Not sure which directory to use?** Run `pwd` (macOS/Linux) or `Get-Location` (PowerShell) after navigating to where you normally start development. That is your workspace root. The script will also detect and warn you if it looks like you may be targeting the wrong directory.

> **Windows execution policy:** If PowerShell blocks the script, run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` first.

**Manual:**

```bash
# At your workspace root (or inside your docs repo if separate)
mkdir -p docs/architecture docs/design docs/adr docs/agents \
         docs/implementation-plans docs/api docs/services \
         docs/runbooks docs/research
```

Copy the template docs into place:

```bash
cp -r agent-knowledge-layer/docs/* your-workspace/docs/
```

---

## Step 2: Drop in CLAUDE.md (2 minutes)

Copy `CLAUDE.md` from this template to your **workspace root**:

```bash
# Multi-repo workspace
cp agent-knowledge-layer/CLAUDE.md ~/workspace/CLAUDE.md

# Single repo
cp agent-knowledge-layer/CLAUDE.md your-project/CLAUDE.md
```

Then fill in the placeholders — or use this agent prompt to have Claude draft it:

> **Agent prompt — draft CLAUDE.md:**
> "I am setting up the agent-knowledge-layer documentation system. Read `CLAUDE.md` at my workspace root (it currently contains placeholder text from the template). Based on the actual contents of this workspace — the services/repos present, the languages and frameworks used, and any conventions you observe in the code — draft a filled-in version of this CLAUDE.md. Replace all `[PLACEHOLDER]` values with real content. For the Service Interaction Map, describe the call relationships between services based on what you can observe. Set `status: proposed` and flag any sections where you couldn't determine the right value — I will review and correct before accepting."

**Validate:** The most critical sections to review manually:
- `Workspace Layout` — list of services must be complete and accurate
- `Service Interaction Map` — call relationships must be correct (agents break contracts when this is wrong)
- `Coding Conventions` — language/framework-specific rules agents must follow

---

## Step 3: Write REPO_NAVIGATION.md (5 minutes)

This file lets agents orient themselves without running `ls`/`find`. Start by generating a tree:

```bash
# macOS / Linux (requires `tree`)
tree -L 3 --gitignore > /tmp/tree.txt

# Windows
tree /F /A > tree.txt
```

Then use this agent prompt to draft the annotated version:

> **Agent prompt — draft REPO_NAVIGATION.md:**
> "Read the raw directory tree I just generated (at `/tmp/tree.txt` or `tree.txt`). Using this as a starting point, write `docs/REPO_NAVIGATION.md` following the template at `docs/REPO_NAVIGATION.md` (current placeholder version). For each service or major directory, add a one-line annotation describing its purpose and language. For each service, add a 'Key patterns' subsection with non-obvious conventions you observe in the code (test package names, mock approach, any singletons or init patterns). Also include the build/test commands for each service. Set `status: proposed` — I will review for accuracy."

---

## Step 4: Write service overview docs (10 minutes total)

For each service, create `docs/services/[service-name].md`.

> **Agent prompt — draft service docs:**
> "For each service in this workspace, create a service overview document in `docs/services/[service-name].md` using the template at `docs/services/TEMPLATE.md`. Read the service's main entry point, router/handler files, and configuration to populate: language/runtime, responsibilities, key internal dependencies, key external dependencies (databases, external APIs), and environment variables. For 'Callers' and 'Called by', use what you can observe from the code and flag any you're uncertain about. Set `status: proposed` on all — I'll verify the caller/callee relationships and any external dependencies before accepting."

**Must validate:** The `Callers` and `Called by` fields. Agents frequently break inter-service contracts because this is wrong.

---

## Step 5: Write your first ADR (10 minutes)

ADRs are the highest-value document type for agents. They explain *why* decisions were made, which prevents agents from undoing deliberate choices.

Look back at the last significant architectural decision your team made:
- Why did you choose this database over alternatives?
- Why is authentication done at this layer vs. another?
- Why does your mobile app read data via the SDK vs. an API?

> **Agent prompt — draft first ADR:**
> "I want to write an ADR for the following decision: [describe the decision in 1-2 sentences]. Read `docs/adr/ADR-0000-template.md` for the format. Draft `docs/adr/ADR-0001-[slug].md` with: the decision we made, the context that drove it (infer from the codebase what problems this solved), the alternatives we likely considered, and the consequences. Set `status: proposed`. I will review and fill in anything you couldn't infer, especially the alternatives and the precise reasoning."

From this point forward: every significant architectural decision gets an ADR. The bar: "if an agent implementing a feature needed to know this, it's an ADR."

---

## Step 6: Define your agent roster (10 minutes)

If you use multiple agent types (e.g., different agents for backend, frontend, database, infrastructure work), define them in `docs/agents/`.

> **Agent prompt — draft agent definitions:**
> "Read all custom agent definition files in `.claude/agents/` (or wherever our agent configurations live). For each one, create a capability definition in `docs/agents/[name].md` following the template at `docs/agents/TEMPLATE.md`. Describe: the agent's domain, the triggers that should lead to assigning it a task, explicit exclusions (what it should NOT be assigned), required context it should read before starting, preferred tools and patterns, and expected outputs. Base this on the agent's system prompt and any examples you find. Set `status: proposed` on each — I'll review and promote to `current`."

If you only use a single general-purpose agent, you can skip this step or write a single entry documenting what that agent is expected to do.

---

## Step 7: Set up REPO_STATE.md (5 minutes)

This file prevents agents from generating code for the wrong platform during migrations or after infrastructure changes.

> **Agent prompt — draft REPO_STATE.md:**
> "Read the current `docs/REPO_STATE.md` template. Based on what you can observe in this workspace — Dockerfiles, CI/CD configs, environment variable names, any infrastructure-as-code files — draft a filled-in REPO_STATE.md describing: what compute platform each service is on, what database each service uses, and any active migrations or infrastructure changes in progress. Flag anything you could not determine with `[UNKNOWN — verify]`. Set `status: proposed`."

Key questions to answer in REPO_STATE.md:
- What compute platform is each service on?
- What database does each service use?
- Are any migrations currently in progress?
- What should agents NOT assume (old patterns that no longer apply)?

---

## Step 8: Populate INDEX.md (5 minutes)

Add an entry to `docs/INDEX.md` for every file you've created. This step is easy to skip and critically important not to — the index only works if it's complete.

> **Agent prompt — update INDEX.md:**
> "Scan all files in `docs/`. For any file that exists but is not yet listed in `docs/INDEX.md`, add an entry in the appropriate section with a one-line description. Follow the existing table format exactly. Do not remove or modify existing entries."

---

## Step 9: Verify agent behavior (5 minutes)

Start a new Claude Code session and give it a task that requires reading your project. Before coding, the agent should:

1. Read `CLAUDE.md` (Claude Code does this automatically for CLAUDE.md at the invocation directory)
2. Check `docs/INDEX.md` to find relevant docs
3. Read the relevant service doc and any linked ADRs

If the agent dives straight into code without reading any docs, add this block to the very top of your `CLAUDE.md` (before any other instructions):

```markdown
## CRITICAL: Before starting any task

1. Check `docs/INDEX.md` to find documentation relevant to this task.
2. Read `docs/REPO_NAVIGATION.md` to understand the workspace layout — do NOT run ls/find.
3. Read `docs/REPO_STATE.md` before writing any infrastructure code.
4. Check `docs/adr/` for ADRs relevant to the component you are changing.
```

---

## Troubleshooting

If anything goes wrong during setup or adoption, the prompts below are designed to be pasted directly into a Claude Code session. They are self-contained — the agent will investigate and fix the issue without you needing to diagnose it first.

---

**The agent isn't reading my docs before starting tasks.**

> "Read `CLAUDE.md` at the workspace root and tell me: (1) does the 'CRITICAL: Before starting any task' block appear near the top of the file? (2) Does it reference `docs/INDEX.md` specifically? (3) Is there anything in the file that contradicts or overrides these instructions? Then look at the last task you were given — did you read any files from `docs/` before starting? If not, explain why and suggest a fix to the CLAUDE.md to make this more reliable."

---

**The setup script failed or produced unexpected results.**

> "The setup script at `scripts/setup.sh` (or `setup.ps1`) did not complete successfully. Here is the error output: [paste error]. Read the script and diagnose what went wrong. Common causes: wrong working directory when the script was run, missing permissions on the target directory, or a path with spaces that wasn't quoted. Suggest a fix and, if the script ran partially, tell me which files were created and which are still missing by comparing the expected structure in `SETUP.md` against what actually exists on disk."

---

**My docs exist but agents are generating outdated or wrong code.**

> "Read `docs/REPO_STATE.md` and `docs/REPO_NAVIGATION.md`. Compare their content against the actual state of the codebase — check Dockerfiles, CI config, and service entry points. For each section in REPO_STATE.md, tell me whether the described state matches reality and flag any discrepancies. Produce a list of specific updates needed to bring these files current. Set the updated sections to `status: outdated` as a marker until I review and confirm."

---

**CLAUDE.md exists but the agent isn't finding it.**

> "Diagnose why Claude Code is not reading CLAUDE.md. Check: (1) Is CLAUDE.md at the directory where `claude` is being invoked from? Run `pwd` in the terminal to confirm. (2) Is there a `.claudeignore` or similar file that might be excluding it? (3) Is there a second CLAUDE.md somewhere that might be taking precedence? Report what you find and the correct fix for my setup (monorepo / multi-repo)."

---

**The INDEX.md is out of date — docs exist that aren't listed.**

> "Scan all `.md` files under `docs/`. For each file not already listed in `docs/INDEX.md`, add an entry in the correct section with a one-line description of the document's content. Do not modify or remove existing entries. After updating, report how many entries were added and which sections they were added to."

---

**An agent wrote something that conflicted with an existing architectural decision.**

> "Read all files in `docs/adr/`. Then read the code change described here: [describe the change or paste the diff]. Identify any ADRs that the change conflicts with or that the agent should have read before making this decision. For each conflict found, explain what the ADR says, what the agent did differently, and whether the ADR should be superseded or the code change should be revised. If this decision should itself become an ADR, draft it."

---

## Optional: MCP server setup

Once the documentation system is working as plain Markdown files, consider adding the knowledge MCP server for faster agent queries. See `mcp-server/README.md` for the full guide.

The MCP server is worth adding when:
- You have 5+ services and agents spend significant time reading docs
- You want agents to have always-current data (git log, live infrastructure state)
- You want structured JSON responses rather than prose docs

---

## Ongoing maintenance

The documentation system's value degrades as docs drift from reality. Key habits:

**When you change a service's architecture:** Update `docs/services/[service].md` and `docs/REPO_NAVIGATION.md`.

**When you complete or start a migration:** Update `docs/REPO_STATE.md`.

**When you make a significant architectural decision:** Write an ADR immediately, while context is fresh.

**When you start a significant feature with multiple agents:** Write an implementation plan in `docs/implementation-plans/` before coding. This is the agents' task specification.

**Quarterly:** Review docs with `status: current` older than 90 days. Set `status: outdated` for any that have drifted.

A useful rule of thumb: if you would explain something to a new engineer joining the team, it belongs in the docs. If an agent keeps making the same mistake, the fix is a doc update (or an ADR), not a better prompt.
