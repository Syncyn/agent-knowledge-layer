# Setup Scripts

Automated scaffolding for the agent-knowledge-layer documentation system.

| Script | Platform |
|---|---|
| `setup.sh` | macOS, Linux, Windows Subsystem for Linux (WSL) |
| `setup.ps1` | Windows (PowerShell 5.1+ or PowerShell 7+) |

Both scripts are **non-destructive**: they never overwrite files that already exist. Safe to re-run at any time.

---

## What is a workspace?

Your **workspace** is the directory that contains your code repositories — the place you `cd` into before starting development. It is where your AI agent is invoked from.

```
~/workspace/          ← workspace root (run the script from here, or pass this path)
├── api-service/      ← git repo
├── worker-service/   ← git repo
├── frontend/         ← git repo
└── docs/             ← docs repo or directory
```

For a single-repo or monorepo project, your workspace root and your repo root are the same directory.

---

## Usage

### macOS / Linux / WSL

```bash
# Option A: run from your workspace root (recommended)
cd ~/workspace
bash /path/to/agent-knowledge-layer/scripts/setup.sh

# Option B: pass the workspace path explicitly
bash /path/to/agent-knowledge-layer/scripts/setup.sh ~/workspace
```

### Windows (PowerShell)

```powershell
# Option A: run from your workspace root (recommended)
cd C:\Users\you\workspace
.\path\to\agent-knowledge-layer\scripts\setup.ps1

# Option B: pass the workspace path explicitly
.\path\to\agent-knowledge-layer\scripts\setup.ps1 -WorkspaceRoot "C:\Users\you\workspace"
```

> **Execution policy:** If PowerShell blocks the script, run:
> `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
> then retry.

---

## What the scripts do

1. Detect or validate the workspace root (with a confirmation prompt before any changes)
2. Warn if the target looks like a service repo root rather than a workspace root
3. Create the `docs/` subdirectory structure
4. Copy template files into place (skips any that already exist)
5. Print next steps including ready-to-paste agent prompts

The scripts scaffold the structure only. Project-specific content (service names, architecture, stack details) is drafted by agent prompts in `SETUP.md` after running the script.

---

## Troubleshooting

**Script won't run (permission denied on macOS/Linux):**
```bash
chmod +x setup.sh
./setup.sh
```

**Script won't run (PowerShell execution policy):**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**Not sure what path to pass:**
Open your terminal, navigate to where you normally start work, and run `pwd` (macOS/Linux) or `Get-Location` (PowerShell). That is your workspace root.

**Something still went wrong:** Paste this prompt into Claude Code:
> "The setup script at `scripts/setup.sh` (or `setup.ps1`) did not complete as expected. Here is the output: [paste output]. Read the script and diagnose what went wrong. Tell me which files were created and which are still missing by comparing the expected structure in `SETUP.md` against what actually exists at [your workspace path]."
