#!/usr/bin/env bash
# =============================================================================
# agent-knowledge-layer setup script — macOS / Linux / WSL
# =============================================================================
#
# USAGE:
#   bash setup.sh                        # installs into current directory
#   bash setup.sh /path/to/workspace     # installs into specified path
#
# WHAT IS A WORKSPACE?
#   Your workspace is the directory that contains your code repositories and
#   where you invoke your AI agent from (e.g., `cd ~/workspace && claude`).
#   CLAUDE.md will be placed here so agents read it on every session.
#
#   Single repo:         workspace = repo root (same directory)
#   Multiple repos:      workspace = parent directory containing all repos
#
# WHAT THIS SCRIPT DOES:
#   - Creates the docs/ directory structure
#   - Copies template files into place (non-destructive — never overwrites)
#   - Does NOT fill in your project-specific content (service names, stack, etc.)
#     Use the agent prompts in SETUP.md for that after running this script.
#
# =============================================================================

set -euo pipefail

# ── Resolve paths ──────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ $# -ge 1 ]; then
  WORKSPACE_ROOT="$(cd "$1" 2>/dev/null && pwd)" || {
    echo "ERROR: Path does not exist: $1"
    echo "       Create it first with: mkdir -p $1"
    exit 1
  }
else
  WORKSPACE_ROOT="$(pwd)"
fi

# ── Confirm before proceeding ──────────────────────────────────────────────────

echo ""
echo "agent-knowledge-layer setup"
echo "────────────────────────────────────────────────────"
echo "  Template source : $TEMPLATE_DIR"
echo "  Workspace root  : $WORKSPACE_ROOT"
echo ""
echo "  What is a workspace?"
echo "  The directory you cd into before running your AI agent."
echo "  CLAUDE.md will be placed here so agents always see it."
echo ""

# Warn if workspace root looks like it IS a git repo (likely a service repo,
# not a workspace parent). Suggest the parent directory instead.
if [ -d "$WORKSPACE_ROOT/.git" ] && [ $# -eq 0 ]; then
  echo "  ⚠  NOTE: This directory is a git repository."
  echo "     If you work in multiple separate repos side by side, consider"
  echo "     running this script from the parent directory instead:"
  echo "       cd \"$(dirname "$WORKSPACE_ROOT")\" && bash \"$SCRIPT_DIR/setup.sh\""
  echo "     If this IS your workspace root (monorepo or single-repo project),"
  echo "     you can safely continue."
  echo ""
fi

read -r -p "Install into $WORKSPACE_ROOT? [y/N] " confirm
case "$confirm" in
  [yY][eE][sS]|[yY]) ;;
  *)
    echo "Aborted."
    exit 0
    ;;
esac

echo ""

# ── Helper ─────────────────────────────────────────────────────────────────────

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ ! -f "$src" ]; then
    echo "  SKIP (template missing): $src"
    return
  fi
  if [ -f "$dest" ]; then
    echo "  exists  $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  created $dest"
  fi
}

# ── Create directory structure ─────────────────────────────────────────────────

echo "Creating docs/ structure..."
for dir in architecture design adr agents implementation-plans api services runbooks research; do
  mkdir -p "$WORKSPACE_ROOT/docs/$dir"
done
mkdir -p "$WORKSPACE_ROOT/memory"
echo ""

# ── Copy template files ────────────────────────────────────────────────────────

echo "Copying template files (existing files are never overwritten)..."

copy_if_missing "$TEMPLATE_DIR/CLAUDE.md"                          "$WORKSPACE_ROOT/CLAUDE.md"
copy_if_missing "$TEMPLATE_DIR/docs/INDEX.md"                      "$WORKSPACE_ROOT/docs/INDEX.md"
copy_if_missing "$TEMPLATE_DIR/docs/REPO_NAVIGATION.md"            "$WORKSPACE_ROOT/docs/REPO_NAVIGATION.md"
copy_if_missing "$TEMPLATE_DIR/docs/REPO_STATE.md"                 "$WORKSPACE_ROOT/docs/REPO_STATE.md"
copy_if_missing "$TEMPLATE_DIR/docs/adr/ADR-0000-template.md"      "$WORKSPACE_ROOT/docs/adr/ADR-0000-template.md"
copy_if_missing "$TEMPLATE_DIR/docs/agents/TEMPLATE.md"            "$WORKSPACE_ROOT/docs/agents/TEMPLATE.md"
copy_if_missing "$TEMPLATE_DIR/docs/implementation-plans/TEMPLATE.md" \
                                                                    "$WORKSPACE_ROOT/docs/implementation-plans/TEMPLATE.md"
copy_if_missing "$TEMPLATE_DIR/memory/MEMORY.md"                   "$WORKSPACE_ROOT/memory/MEMORY.md"
copy_if_missing "$TEMPLATE_DIR/memory/README.md"                   "$WORKSPACE_ROOT/memory/README.md"

for dir in architecture design adr agents implementation-plans api services runbooks research; do
  copy_if_missing "$TEMPLATE_DIR/docs/$dir/README.md" "$WORKSPACE_ROOT/docs/$dir/README.md"
done

echo ""

# ── Summary ────────────────────────────────────────────────────────────────────

echo "────────────────────────────────────────────────────"
echo "Setup complete."
echo ""
echo "Workspace root : $WORKSPACE_ROOT"
echo "CLAUDE.md      : $WORKSPACE_ROOT/CLAUDE.md"
echo "Docs hub       : $WORKSPACE_ROOT/docs/"
echo ""
echo "Next steps:"
echo ""
echo "  1. Open CLAUDE.md and fill in your workspace layout and service names."
echo "     Or paste this prompt into Claude Code to have it drafted for you:"
echo ""
echo "     \"Read CLAUDE.md at the workspace root. Based on the actual contents"
echo "     of this workspace, draft a filled-in version replacing all [PLACEHOLDER]"
echo "     values with real content. Set status: proposed — I will review.\""
echo ""
echo "  2. Then ask Claude to draft the remaining docs:"
echo "     \"Read SETUP.md and follow steps 3 through 8 to draft the remaining"
echo "     documentation files. Use the agent prompts in each step. Set"
echo "     status: proposed on all new docs.\""
echo ""
echo "  3. Review all proposed docs and set status: proposed → current."
echo ""
echo "  If anything goes wrong, see the Troubleshooting section in SETUP.md"
echo "  for AI prompts that diagnose and fix common issues."
echo ""
