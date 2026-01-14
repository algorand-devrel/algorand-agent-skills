# Ralph Loop for Algorand Agent Skills

A simple bash loop that runs Claude iteratively to enhance Algorand agent skills.

## Vision

Ralph aims to build **comprehensive skill coverage for all Algorand development** (excluding node operations):

| Category | Skills |
|----------|--------|
| **Smart Contracts** | TypeScript (PuyaTs), Python (PuyaPy) syntax, testing, deployment |
| **Client Apps** | AlgoKit Utils for TypeScript and Python |
| **Tooling** | AlgoKit CLI commands and workflows |
| **Debugging** | Common errors and solutions |
| **Standards** | ARC specs for interoperability |
| **Frontend** | React dApp patterns |

See [PLAN.md](./PLAN.md) for detailed architecture and gap analysis.

## Execution Phases

| Phase | Description | Tasks |
|-------|-------------|-------|
| 1 | Rename existing skills | 8 renames to action-oriented names |
| 2 | Add Python patterns | 4 new files in `build-smart-contracts/python/` |
| 3 | Create new skills | `use-algokit-utils`, `troubleshoot-errors` |
| 4 | ARC standards | `implement-arc-standards` |
| 5 | Finalization | Update AGENTS.md, README, consistency review |

## How It Works

1. Claude reads `prompt.md` and works on the next task in `progress.md`
2. When Claude exits, the loop runs it again
3. Claude sees the files it modified and continues from there
4. Repeat until `SKILLS_COMPLETE` or max iterations

The power is in iteration - each run builds on the previous one.

## Files

| File | Purpose |
|------|---------|
| `run.sh` | The bash loop script |
| `prompt.md` | Instructions for Claude each iteration |
| `progress.md` | Task queue and state tracking |
| `PLAN.md` | Strategic overview, architecture, and gap analysis |
| `templates/` | Templates for new skills |

## Running

```bash
cd /home/gabe/Code/@algorand-devrel/algorand-agent-skills

# Default: 20 iterations
./ralph/run.sh

# Custom iteration limit
./ralph/run.sh 10   # max 10 iterations
./ralph/run.sh 50   # max 50 iterations
```

Stop anytime with `Ctrl+C`. Progress is saved in git commits.

## Monitoring

In another terminal:

```bash
# Watch progress
watch -n 5 cat ralph/progress.md

# Watch git commits
watch -n 10 'git log --oneline -5'
```

## Resuming

Just run `./ralph/run.sh` again. Claude reads `progress.md` and continues where it left off.

## Customizing

### Add tasks to queue

Edit `progress.md`, add items under the appropriate PHASE:

```markdown
- [ ] **task-name**: Description
  - Fetch: https://dev.algorand.co/...
  - Create: skills/skill-name/SKILL.md
```

### Change the prompt

Edit `prompt.md` to modify Claude's instructions.

## Cost Estimate

~$1-3 per skill created/modified, depending on complexity. Full run: ~$20-40.

## Best Practices

This workflow follows [Anthropic's Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

- **Action-oriented names**: `build-smart-contracts` not `building-smart-contracts`
- **Progressive disclosure**: SKILL.md < 500 lines, details in sub-files
- **Domain organization**: `typescript/` and `python/` sub-directories
- **Concise content**: Assume Claude is smart
- **CORRECT/INCORRECT examples**: Every rule needs both
