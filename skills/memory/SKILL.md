---
name: memory
description: Use to maintain context across sessions - auto-detects decisions, blockers, patterns worth remembering
---

# Memory Skill

## Overview

Persistent memory system for maintaining context across Claude sessions. Stores decisions, patterns, blockers, and todos in `.memory/` directory, git-tracked with the project.

**Announce at start:** "I'm using the memory skill to [load context / save this decision / etc.]"

## When This Skill Activates

### Session Start (Automatic via Hook)

Context is loaded automatically. You'll see a `<project-memory>` block with:
- Active blockers
- Ready todos
- Summary of available context

**Don't reload** - it's already there. Just reference it.

### During Conversation (Manual Triggers)

Offer to save memories when you detect:

| Trigger | Detection Signal | Action |
|---------|------------------|--------|
| **Decision made** | "Let's go with X", choosing between options, "I recommend" | Ask: "Should I save this decision to memory?" |
| **Blocker hit** | "This won't work because", test failures, "blocked by" | Ask: "Should I log this blocker?" |
| **Pattern discovered** | "I notice this codebase uses", "the pattern here is" | Ask: "Should I save this pattern?" |
| **Task identified** | Clear next action emerges from discussion | Ask: "Should I add this as a todo?" |

**Always ask before saving** - never auto-store without confirmation.

## Commands

### Saving Memories

After user confirms, use Bash to run:

```bash
# Decisions
mem add -d "Use JWT for API authentication"

# Patterns
mem add -p "Error handling uses Result type throughout"

# Blockers
mem add -b "CI flaky test blocking deploys"

# Todos
mem add -t "Write failing test for registration"
mem add -t "Implement handler" -e auth-feature  # With epic grouping
```

### Querying Memories

When user asks about past context:

```bash
# "What did we decide about auth?"
mem search "auth" --type decision

# "Show me that decision"
mem show d-001

# "What's blocking us?"
mem list blockers

# "What should I work on?"
mem ready
```

### Managing Todos

```bash
# Mark complete
mem done t-001

# Mark blocked
mem block t-002 "waiting on API access"

# List all todos
mem list todos
```

## Integration with Other Skills

### With write-plans

After `write-plans` creates `docs/plans/YYYY-MM-DD-feature.md`:

1. Parse the tasks from the plan
2. Create an epic: `mem add -t "Feature epic" -e YYYY-MM-DD-feature`
3. Add each task: `mem add -t "Task description" -e YYYY-MM-DD-feature`

This creates the execution tracking layer.

### With executing-plans

When working through a plan:
1. Check `mem ready` for next actionable item
2. Mark `mem done <id>` as you complete tasks
3. Mark `mem block <id> "reason"` if stuck

### With brainstorming

After a brainstorming session produces a decision:
- Offer to save key decisions to memory
- These persist even if the design doc is later modified

## Security Rules

**Never store:**
- API keys or tokens
- Private keys
- Passwords
- Email addresses or PII
- Verbatim code blocks (use file:line references instead)

The `mem` CLI will reject content matching sensitive patterns, but double-check before suggesting saves.

**Good:** "Use JWT with RS256 signing - see auth.ts:45-80"
**Bad:** "Use this API key: sk-abc123..."

## Initializing Memory

If `.memory/` doesn't exist and user wants to use it:

```bash
mem init
```

Then add `.memory/` to git:

```bash
git add .memory
git commit -m "Initialize project memory"
```

## Token Efficiency

Context loading is **lean by design**:
- Session start only shows blockers + ready todos + counts
- Full details fetched on-demand via `mem show` or `mem search`
- Don't dump entire memory contents unless specifically asked

When user asks "what do we have in memory?", summarize counts first, offer to show details.
