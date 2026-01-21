# mem

Persistent memory system for Claude Code sessions. Maintains context across conversations - decisions, patterns, blockers, and todos - stored in `.memory/` and git-tracked with your project.

Inspired by [Beads](https://github.com/steveyegge/beads), designed to complement [superpowers](https://github.com/obra/superpowers).

## Repository

https://github.com/cristianj26/mem

## Why

Claude loses context between sessions. You end up re-explaining:
- "We decided to use JWT because..."
- "The auth system works by..."
- "We're blocked on CI flaky tests..."
- "Next step was to implement X..."

`mem` solves this by storing structured memories that load automatically at session start.

## Install

### As Claude Code Plugin

```bash
# Clone to your plugins directory
git clone https://github.com/based/mem ~/.claude/plugins/mem

# Or if using plugin marketplace (coming soon)
claude plugin install mem
```

### CLI Only

```bash
# Add to PATH
cp bin/mem ~/.local/bin/
# or
ln -s $(pwd)/bin/mem ~/.local/bin/mem
```

## Quick Start

```bash
# Initialize in your project
cd your-project
mem init

# Add to git
git add .memory
git commit -m "Initialize project memory"
```

## Usage

### From Terminal

```bash
# Add memories
mem add -d "Use JWT for auth"              # Decision
mem add -p "Errors use Result type"        # Pattern
mem add -b "CI flaky test"                 # Blocker
mem add -t "Write failing test"            # Todo
mem add -t "Implement handler" -e feature  # Todo in epic

# Query
mem list                    # List all
mem list todos              # List by type
mem ready                   # Show actionable todos
mem show d-001              # Show details
mem search "auth"           # Search

# Manage todos
mem done t-001              # Mark complete
mem block t-002 "reason"    # Mark blocked

# For Claude sessions
mem context                 # Output lean summary
```

### From Claude

The `memory` skill handles Claude-side interaction:

- **Auto-loads** context at session start via hook
- **Detects** when to offer saving (decisions, blockers, patterns)
- **Queries** on demand ("what did we decide about X?")
- **Manages** todos during plan execution

## Structure

```
.memory/
├── index.json              # Fast lookup index
├── decisions/              # "Why did we do X?"
│   └── d-001-use-jwt.md
├── patterns/               # "How does this work?"
│   └── p-001-error-handling.md
├── blockers/               # "What's stopping us?"
│   └── b-001-flaky-ci.md
└── todos/                  # "What's next?"
    └── 2025-01-20-feature/
        ├── 001-write-test.md
        └── 002-implement.md
```

## Token Efficiency

Session start loads **minimal context**:

```
## Active Blockers
- [b-001] CI flaky test

## Ready Todos
- [t-003] Write failing test

## Available Context
- 5 decisions (query: "what did we decide about X?")
- 3 patterns (query: "how does X work?")
```

Full details fetched on-demand, not upfront.

## Security

The CLI **rejects** content matching:
- API keys (OpenAI, GitHub, AWS, Google, Slack)
- Private keys
- Passwords
- Email addresses
- SSN patterns

Pre-commit hook available for additional safety:

```bash
cp hooks/pre-commit-memory.sh .git/hooks/pre-commit
```

**Best practice:** Store file references (`auth.ts:45-60`), not code blocks.

## Integration with superpowers

Works alongside superpowers skills:

| Skill | Integration |
|-------|-------------|
| `write-plans` | Plans generate todos in `.memory/` |
| `executing-plans` | Uses `mem ready` / `mem done` for progress |
| `brainstorming` | Decisions saved to memory after sessions |

## License

MIT
