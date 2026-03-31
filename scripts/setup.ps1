# =============================================================================
# agent-knowledge-layer setup script — Windows PowerShell
# Compatible with Windows PowerShell 5.1+ and PowerShell 7+
# =============================================================================
#
# USAGE:
#   .\setup.ps1                                       # installs into current directory
#   .\setup.ps1 -WorkspaceRoot "C:\Users\you\workspace"
#
# WHAT IS A WORKSPACE?
#   Your workspace is the directory that contains your code repositories and
#   where you invoke your AI agent from. CLAUDE.md will be placed here so
#   agents read it on every session.
#
#   Single repo:     workspace = repo root (same directory)
#   Multiple repos:  workspace = parent directory containing all repos
#
# WHAT THIS SCRIPT DOES:
#   - Creates the docs/ directory structure
#   - Copies template files into place (non-destructive — never overwrites)
#   - Does NOT fill in project-specific content (service names, stack, etc.)
#     Use the agent prompts in SETUP.md for that after running this script.
#
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$WorkspaceRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Resolve paths ──────────────────────────────────────────────────────────────

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Split-Path -Parent $ScriptDir

if ($WorkspaceRoot -ne "") {
    if (-not (Test-Path $WorkspaceRoot -PathType Container)) {
        Write-Host "ERROR: Path does not exist: $WorkspaceRoot" -ForegroundColor Red
        Write-Host "       Create it first with: New-Item -ItemType Directory -Path '$WorkspaceRoot'"
        exit 1
    }
    $WorkspaceRoot = (Resolve-Path $WorkspaceRoot).Path
} else {
    $WorkspaceRoot = (Get-Location).Path
}

# ── Confirm before proceeding ──────────────────────────────────────────────────

Write-Host ""
Write-Host "agent-knowledge-layer setup" -ForegroundColor Cyan
Write-Host ("─" * 52)
Write-Host "  Template source : $TemplateDir"
Write-Host "  Workspace root  : $WorkspaceRoot"
Write-Host ""
Write-Host "  What is a workspace?"
Write-Host "  The directory you navigate to before running your AI agent."
Write-Host "  CLAUDE.md will be placed here so agents always see it."
Write-Host ""

# Warn if the target directory is a git repo root (may be a service repo,
# not a workspace parent).
if ((Test-Path "$WorkspaceRoot\.git") -and ($WorkspaceRoot -eq (Get-Location).Path)) {
    Write-Host "  NOTE: This directory is a git repository." -ForegroundColor Yellow
    Write-Host "  If you work across multiple repos side by side, consider"
    Write-Host "  running from their parent directory instead:"
    Write-Host "    cd `"$(Split-Path -Parent $WorkspaceRoot)`""
    Write-Host "    .\`"$ScriptDir\setup.ps1`""
    Write-Host "  If this IS your workspace root (monorepo/single-repo), continue."
    Write-Host ""
}

$confirm = Read-Host "Install into $WorkspaceRoot? [y/N]"
if ($confirm -notmatch '^[Yy]([Ee][Ss])?$') {
    Write-Host "Aborted."
    exit 0
}

Write-Host ""

# ── Helper ─────────────────────────────────────────────────────────────────────

function Copy-IfMissing {
    param([string]$Src, [string]$Dest)

    if (-not (Test-Path $Src)) {
        Write-Host "  SKIP (template missing): $Src"
        return
    }

    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }

    if (Test-Path $Dest) {
        Write-Host "  exists  $Dest"
    } else {
        Copy-Item $Src $Dest
        Write-Host "  created $Dest"
    }
}

# ── Create directory structure ─────────────────────────────────────────────────

Write-Host "Creating docs/ structure..."
$dirs = @("architecture","design","adr","agents","implementation-plans","api","services","runbooks","research")
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path "$WorkspaceRoot\docs\$d" | Out-Null
}
New-Item -ItemType Directory -Force -Path "$WorkspaceRoot\memory" | Out-Null
Write-Host ""

# ── Copy template files ────────────────────────────────────────────────────────

Write-Host "Copying template files (existing files are never overwritten)..."

Copy-IfMissing "$TemplateDir\CLAUDE.md"                                    "$WorkspaceRoot\CLAUDE.md"
Copy-IfMissing "$TemplateDir\docs\INDEX.md"                                "$WorkspaceRoot\docs\INDEX.md"
Copy-IfMissing "$TemplateDir\docs\REPO_NAVIGATION.md"                      "$WorkspaceRoot\docs\REPO_NAVIGATION.md"
Copy-IfMissing "$TemplateDir\docs\REPO_STATE.md"                           "$WorkspaceRoot\docs\REPO_STATE.md"
Copy-IfMissing "$TemplateDir\docs\adr\ADR-0000-template.md"                "$WorkspaceRoot\docs\adr\ADR-0000-template.md"
Copy-IfMissing "$TemplateDir\docs\agents\TEMPLATE.md"                      "$WorkspaceRoot\docs\agents\TEMPLATE.md"
Copy-IfMissing "$TemplateDir\docs\implementation-plans\TEMPLATE.md"        "$WorkspaceRoot\docs\implementation-plans\TEMPLATE.md"
Copy-IfMissing "$TemplateDir\memory\MEMORY.md"                             "$WorkspaceRoot\memory\MEMORY.md"
Copy-IfMissing "$TemplateDir\memory\README.md"                             "$WorkspaceRoot\memory\README.md"

foreach ($d in $dirs) {
    Copy-IfMissing "$TemplateDir\docs\$d\README.md" "$WorkspaceRoot\docs\$d\README.md"
}

Write-Host ""

# ── Summary ────────────────────────────────────────────────────────────────────

Write-Host ("─" * 52)
Write-Host "Setup complete." -ForegroundColor Green
Write-Host ""
Write-Host "  Workspace root : $WorkspaceRoot"
Write-Host "  CLAUDE.md      : $WorkspaceRoot\CLAUDE.md"
Write-Host "  Docs hub       : $WorkspaceRoot\docs\"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Open CLAUDE.md and fill in your workspace layout and service names."
Write-Host "     Or paste this prompt into Claude Code to have it drafted for you:"
Write-Host ""
Write-Host "     `"Read CLAUDE.md at the workspace root. Based on the actual contents"
Write-Host "     of this workspace, draft a filled-in version replacing all [PLACEHOLDER]"
Write-Host "     values with real content. Set status: proposed — I will review.`""
Write-Host ""
Write-Host "  2. Then ask Claude to draft the remaining docs:"
Write-Host "     `"Read SETUP.md and follow steps 3 through 8 to draft the remaining"
Write-Host "     documentation files. Use the agent prompts in each step. Set"
Write-Host "     status: proposed on all new docs.`""
Write-Host ""
Write-Host "  3. Review all proposed docs and set status: proposed -> current."
Write-Host ""
Write-Host "  If anything goes wrong, see the Troubleshooting section in SETUP.md"
Write-Host "  for AI prompts that diagnose and fix common issues."
Write-Host ""
