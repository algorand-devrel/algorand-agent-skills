# Ralph Loop for Algorand Agent Skills

A simple bash loop that runs Claude iteratively to review, enhance, and maintain Algorand agent skills.

## Current Run: Review & Enhancement

This run focuses on three objectives:

| Phase | Objective | Tasks |
|-------|-----------|-------|
| **A** | Coverage Audit | Review Algorand docs via Kappa MCP, identify gaps, create missing skills |
| **B** | Accuracy Review | Verify each skill against current documentation |
| **C** | Best Practices | Audit all skills against Anthropic guidelines |
| **D** | Finalization | Update docs, final consistency check |

## How It Works

1. Claude reads `prompt.md` and works on the next task in `progress.md`
2. Claude uses **MCP tools** (Kappa, GitHub) to research Algorand documentation
3. When Claude exits, the loop runs it again
4. Claude sees the files it modified and continues from there
5. Repeat until `SKILLS_COMPLETE` or max iterations (50)

The power is in iteration - each run builds on the previous one.

## MCP Tools Available

### Kappa (Algorand Knowledge) - PRIMARY
```
mcp__kappa__search_algorand_knowledge_sources(query: "...")
```
Semantic search over Algorand documentation. Use for all Algorand-specific research.

### GitHub
```
mcp__github__get_file_contents(owner, repo, path)
mcp__github__search_code(query)
```
Access code examples from official Algorand repositories.

### Web Tools
```
WebFetch(url, prompt)
WebSearch(query)
```
For Anthropic best practices and non-Algorand content.

## Files

| File | Purpose |
|------|---------|
| `run.sh` | The bash loop script (default: 50 iterations) |
| `prompt.md` | Instructions for Claude each iteration |
| `progress.md` | Task queue and state tracking |
| `PLAN.md` | Strategic overview and architecture |
| `templates/` | Templates for new skills |

## Running

```bash
cd /home/gabe/Code/@algorand-devrel/algorand-agent-skills

# Default: 50 iterations
./ralph/run.sh

# Custom iteration limit
./ralph/run.sh 10   # max 10 iterations
./ralph/run.sh 100  # max 100 iterations
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

## Quality Standards

This workflow follows [Anthropic's Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

- **Action-oriented names**: `build-smart-contracts` not `building-smart-contracts`
- **Progressive disclosure**: SKILL.md < 500 lines, details in sub-files
- **Domain organization**: `typescript/` and `python/` sub-directories
- **Concise content**: Assume Claude is smart
- **CORRECT/INCORRECT examples**: Every rule needs both
- **Third-person descriptions**: For skill discovery
- **One-level-deep references**: No nested file references

## Cost Estimate

~$1-3 per skill reviewed/modified. Full review run: ~$30-50.
