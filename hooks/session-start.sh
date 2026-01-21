#!/bin/bash
# Session start hook for mem plugin
# Outputs project memory context if .memory/ exists

# Find mem binary - check plugin's bin dir first, then PATH
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
MEM_BIN="$PLUGIN_DIR/bin/mem"

if [[ ! -x "$MEM_BIN" ]]; then
  MEM_BIN=$(which mem 2>/dev/null || echo "")
fi

if [[ -z "$MEM_BIN" ]]; then
  # mem not found, skip silently
  exit 0
fi

# Check if .memory exists in current project
find_memory_dir() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.memory" ]]; then
      echo "$dir/.memory"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

MEMORY_DIR=$(find_memory_dir 2>/dev/null || echo "")

if [[ -z "$MEMORY_DIR" ]]; then
  # No .memory directory, skip silently
  exit 0
fi

# Output context for Claude
echo "<project-memory>"
"$MEM_BIN" context
echo "</project-memory>"
