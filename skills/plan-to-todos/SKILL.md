---
name: plan-to-todos
description: Use after write-plans to generate todos from a plan file - creates structured tracking in .memory/
---

# Plan to Todos

## Overview

Converts a plan document (created by `superpowers:writing-plans`) into structured todos in `.memory/`. This creates the execution tracking layer that persists across sessions.

**Announce at start:** "I'm using plan-to-todos to generate memory todos from this plan."

## When to Use

- After `write-plans` saves a plan to `docs/plans/YYYY-MM-DD-feature.md`
- When you have an existing plan file you want to track
- User says "create todos from this plan"

## Prerequisites

1. `.memory/` must be initialized (`mem init`)
2. Plan file must exist with `### Task N:` structure

## The Process

### Step 1: Identify the Plan

If not specified, find the most recent plan:
```bash
ls -t docs/plans/*.md | head -1
```

### Step 2: Extract Epic Name

From filename `docs/plans/2025-01-20-user-auth.md`:
- Epic name: `2025-01-20-user-auth`

### Step 3: Parse Tasks

Find all lines matching `### Task N: [Description]` in the plan.

Example plan structure:
```markdown
### Task 1: Create user model
### Task 2: Implement registration endpoint
### Task 3: Add authentication middleware
```

### Step 4: Generate Todos

For each task found:
```bash
mem add -t "Task 1: Create user model" -e 2025-01-20-user-auth
mem add -t "Task 2: Implement registration endpoint" -e 2025-01-20-user-auth
mem add -t "Task 3: Add authentication middleware" -e 2025-01-20-user-auth
```

### Step 5: Confirm

Output summary:
```
Created 3 todos in epic: 2025-01-20-user-auth

Run `mem ready` to see actionable items.
Run `mem list todos` to see all todos.
```

## Example Session

```
User: I just finished writing the plan, create todos from it

Claude: I'm using plan-to-todos to generate memory todos from this plan.

Found plan: docs/plans/2025-01-20-user-auth.md
Epic: 2025-01-20-user-auth

Extracting tasks...
- Task 1: Create user model
- Task 2: Implement registration endpoint
- Task 3: Add authentication middleware

Creating todos...
[runs mem add commands]

Created 3 todos in epic: 2025-01-20-user-auth
Run `mem ready` to see actionable items.
```

## Integration with write-plans

After `superpowers:writing-plans` completes:

1. Plan is saved to `docs/plans/`
2. Offer: "Want me to create todos from this plan for cross-session tracking?"
3. If yes, invoke this skill

## If .memory/ Doesn't Exist

Prompt user:
```
This project doesn't have .memory/ initialized.
Run `mem init` to enable persistent todo tracking, or skip this step.
```

## Updating Existing Todos

If todos for this epic already exist:
```
Epic 2025-01-20-user-auth already has 3 todos.
Options:
1. Skip (keep existing)
2. Replace (delete old, create new)
3. Append (add new tasks only)
```

## Remember

- One todo per `### Task N:` line
- Epic name comes from plan filename
- Don't create duplicate todos
- Always confirm count after creation