#!/bin/bash
# Pre-commit hook to scan .memory/ for sensitive content
# Install: cp this to .git/hooks/pre-commit (or add to existing hook)

set -e

# Only run if .memory exists and has staged changes
if ! git diff --cached --name-only | grep -q "^\.memory/"; then
  exit 0
fi

echo "Scanning .memory/ for sensitive content..."

# Patterns to detect
PATTERNS=(
  'sk-[A-Za-z0-9]{20,}'
  'ghp_[A-Za-z0-9]{36}'
  'gho_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{22,}'
  'AKIA[0-9A-Z]{16}'
  '-----BEGIN .* PRIVATE KEY-----'
  'AIza[0-9A-Za-z_-]{35}'
  'xox[baprs]-[0-9A-Za-z-]+'
)

FOUND=0

for pattern in "${PATTERNS[@]}"; do
  if git diff --cached -- .memory/ | grep -qE "$pattern"; then
    echo "ERROR: Sensitive pattern detected in .memory/"
    echo "Pattern: $pattern"
    FOUND=1
  fi
done

# Also check for common password patterns
if git diff --cached -- .memory/ | grep -qiE 'password\s*[:=]\s*[^*\s]'; then
  echo "ERROR: Possible password found in .memory/"
  FOUND=1
fi

# Check for email addresses (basic pattern)
if git diff --cached -- .memory/ | grep -qE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'; then
  echo "WARNING: Email address found in .memory/ - review before committing"
  # Warning only, not blocking
fi

if [[ $FOUND -eq 1 ]]; then
  echo ""
  echo "Remove sensitive content before committing."
  echo "Use 'git reset HEAD .memory/' to unstage, then edit files."
  exit 1
fi

echo "Memory scan passed."
exit 0
