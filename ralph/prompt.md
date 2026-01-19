# Ralph Workflow Prompt

<!-- ============================================================
     [CUSTOMIZE] This entire file is a template. Replace all
     [CUSTOMIZE] sections with your workflow-specific content.
     ============================================================ -->

## Workflow Overview

<!-- [CUSTOMIZE] Describe what Claude is doing in this workflow -->

You are performing an iterative task using the Ralph workflow pattern. Your goal is to:

1. Read `ralph/progress.md` to understand current state
2. Execute the next pending task
3. Update `ralph/progress.md` with your progress
4. Commit changes to git
5. Exit (the loop will restart you with fresh context)

**Vision**: [CUSTOMIZE: One-sentence description of the workflow's goal]

## Available Tools

<!-- [CUSTOMIZE] Document the tools Claude has access to -->

### Standard Tools

- **Read/Write/Edit**: File operations
- **Bash**: Run shell commands
- **Glob/Grep**: Search files and content

### MCP Tools (if configured)

<!-- [CUSTOMIZE] List your MCP server tools here, for example:

### MyServer (Description)

```
mcp__myserver__search(query: "...")
mcp__myserver__get_item(id: "...")
```

**When to use**: Describe use cases
-->

### Web Tools

- **WebFetch**: Fetch content from a URL
- **WebSearch**: Search the web

## Your Workflow

### Step 1: Read Progress

Read `ralph/progress.md` to understand:
- What has been completed
- What is the current task (if any)
- What is next in the QUEUE

### Step 2: Pick Next Task

Take the next unchecked item `[ ]` from the QUEUE.

<!-- [CUSTOMIZE] Define your phases. Example structure:

**Phase order:**
1. **PHASE A**: [Description] - What to do in this phase
2. **PHASE B**: [Description] - What to do in this phase
3. **PHASE C**: [Description] - What to do in this phase
-->

### Step 3: Execute Task

<!-- [CUSTOMIZE] Describe how to execute tasks for each phase. Example:

#### For PHASE A Tasks

1. Research the topic using [tool]
2. Compare against existing [resources]
3. Create/update [artifacts]
4. Verify quality

#### For PHASE B Tasks

1. Read the existing [artifact]
2. Validate against [source of truth]
3. Make corrections as needed
4. Document changes
-->

Work on the task thoroughly before moving on.

### Step 4: Update Progress

After completing a task:
1. Mark it as `[x]` completed in the QUEUE
2. Add it to "Completed Tasks" with a brief summary
3. Update "Current Task" to show what's next
4. Add an entry to the "Iteration Log"

### Step 5: Commit Changes

Create a git commit with a clear message:

```bash
git add -A && git commit -m "$(cat <<'EOF'
Brief description of what was done

- Detail 1
- Detail 2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Step 6: Check Completion

If all QUEUE items are checked `[x]`:
- Output: `WORKFLOW_COMPLETE`
- This signals the loop to exit

Otherwise, exit normally and the loop will restart you.

## Quality Standards

<!-- [CUSTOMIZE] Define your quality requirements. Examples:

### File Format Requirements

- Maximum file length: 500 lines
- Required sections: [list sections]
- Naming convention: [describe pattern]

### Content Guidelines

- Be concise - only add information that isn't already known
- Use consistent terminology throughout
- Include both CORRECT and INCORRECT examples for rules

### Anti-Patterns to Avoid

- [Anti-pattern 1]
- [Anti-pattern 2]
- [Anti-pattern 3]
-->

### General Best Practices

1. **Complete one task fully** before moving to the next
2. **Commit after each task** to create a recovery point
3. **Update progress.md** every iteration
4. **Be explicit** about what was done and what's next

## Resources

<!-- [CUSTOMIZE] List relevant resources

### Documentation
- [Link to docs]

### Templates
- `templates/example.template.md` - Template for creating new files

### Related Files
- `path/to/related/files`
-->

## Begin

Read `ralph/progress.md` now and start the next task.
