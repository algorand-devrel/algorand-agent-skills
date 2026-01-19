# Ralph: Iterative Claude Loop Pattern

Ralph is a workflow pattern for running Claude iteratively on long-running tasks. It enables autonomous, multi-session work by having Claude read its progress from a file, work on the next task, update the progress file, and repeat.

## How It Works

```
┌──────────────────────────────────────────────────────────────┐
│  run.sh starts loop (bash wrapper)                           │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│  Claude reads prompt.md (instructions + tools + workflow)    │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│  Claude reads progress.md (current state + task queue)       │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│  Claude works on next task, updates files                    │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│  Claude updates progress.md, commits changes                 │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│  Claude exits → run.sh restarts it with fresh context        │
└──────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│  Repeat until WORKFLOW_COMPLETE or max iterations            │
└──────────────────────────────────────────────────────────────┘
```

The key insight: Claude's context window resets each iteration, but **state persists through files**. By reading `progress.md` each time, Claude picks up exactly where it left off.

## When to Use Ralph

Ralph is ideal for:

- **Long-running tasks** that exceed Claude's context window
- **Multi-phase projects** with distinct stages
- **Batch processing** many similar items (files, records, skills)
- **Research tasks** requiring iterative exploration
- **Maintenance runs** (audits, updates, migrations)

## Files

| File          | Purpose                                             |
| ------------- | --------------------------------------------------- |
| `run.sh`      | Bash loop that runs Claude repeatedly               |
| `prompt.md`   | Instructions Claude receives each iteration         |
| `progress.md` | State tracking - task queue, completed items, notes |
| `plan.md`     | High-level plan and architecture (optional)         |
| `templates/`  | Templates for files Claude creates (optional)       |

## Customizing for Your Workflow

### 1. Edit `prompt.md`

This is the main customization point. Replace the `[CUSTOMIZE]` sections:

- **Workflow description**: What Claude is doing
- **Available tools**: MCP tools, web tools, file tools
- **Phases/tasks**: Your specific workflow phases
- **Quality standards**: Rules and guidelines
- **Completion criteria**: When to output `WORKFLOW_COMPLETE`

### 2. Edit `progress.md`

Set up your initial state:

- Define the task QUEUE with all items to process
- Clear out the completed items section
- Set up your phase structure

### 3. Edit `plan.md` (optional)

Document your workflow's:

- Vision and scope
- Architecture decisions
- Success criteria

### 4. Add templates (optional)

Put any templates in `templates/` for Claude to use when creating new files.

## Running

```bash
# Navigate to project root
cd /path/to/your/project

# Run with default 50 iterations
./ralph/run.sh

# Run with custom iteration limit
./ralph/run.sh 100  # max 100 iterations
./ralph/run.sh 10   # max 10 iterations
```

Stop anytime with `Ctrl+C`. Progress is saved in git commits.

## Monitoring

In another terminal:

```bash
# Watch progress updates
watch -n 5 cat ralph/progress.md

# Watch git commits
watch -n 10 'git log --oneline -5'

# Follow iteration output
# (run.sh prints Claude's output to terminal)
```

## Resuming

Just run `./ralph/run.sh` again. Claude reads `progress.md` and continues from where it left off.

## Completion Signal

When all tasks are done, Claude outputs `WORKFLOW_COMPLETE`. The run.sh script detects this and exits cleanly.

To customize the completion signal, edit both:

1. `prompt.md` - Tell Claude what to output
2. `run.sh` - Change the string it looks for

## Tips

### Keep progress.md structured

Use consistent formatting so Claude can parse it reliably:

- `[ ]` for pending tasks
- `[x]` for completed tasks
- Clear section headers
- Iteration log for debugging

### Commit frequently

Have Claude commit after each significant change. This creates a trail and allows rollback.

### Use phases

Break large workflows into phases (A, B, C, etc.). This helps Claude understand the overall structure and progress.

### Monitor cost

Each iteration costs tokens. For expensive runs, start with a low iteration limit and monitor before scaling up.

### Tune iteration count

- **Small task queues**: 10-20 iterations
- **Medium projects**: 30-50 iterations
- **Large batch jobs**: 50-100 iterations

## Example Workflows

### Documentation Review

- Phase A: Audit existing docs for gaps
- Phase B: Update outdated sections
- Phase C: Add missing topics
- Phase D: Final consistency check

### Code Migration

- Phase A: Analyze codebase, identify patterns
- Phase B: Transform files (one per iteration)
- Phase C: Update imports and references
- Phase D: Run tests, fix issues

### Data Processing

- Queue: List of files/records to process
- Each iteration: Process next item, update progress
- Completion: All items processed

## Troubleshooting

### Claude doesn't continue from last position

- Check that `progress.md` is being read (add explicit instruction in prompt.md)
- Ensure task markers (`[ ]` / `[x]`) are consistent

### Loop runs but nothing changes

- Claude may be stuck - check output for errors
- Add more explicit next-step instructions in prompt.md

### Max iterations reached before completion

- Increase the limit: `./ralph/run.sh 100`
- Or break the workflow into smaller chunks
