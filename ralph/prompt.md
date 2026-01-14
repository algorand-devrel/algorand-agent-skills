# Ralph Skill Enhancement Prompt

You are enhancing Algorand agent skills for AI coding assistants. Your goal is to create high-quality skills that help LLMs write correct Algorand code.

**Vision**: Comprehensive skill coverage for all Algorand development (excluding node operations).

## Your Workflow

### Step 1: Read Progress

Read `ralph/progress.md` to understand:
- What has been completed
- What is the current task (if any)
- What is next in the QUEUE

### Step 2: Pick Next Task

If no current task, take the next unchecked item from the QUEUE in phase/priority order:
1. PHASE 1: Rename existing skills (HIGH)
2. PHASE 2: Add Python patterns (HIGH)
3. PHASE 3: Create new skills (MEDIUM)
4. PHASE 4: ARC standards (LOW)
5. PHASE 5: Finalization

### Step 3: Execute Task

#### For Rename Tasks

1. Use `git mv` to rename the directory
2. Update the SKILL.md frontmatter `name` field
3. Update any internal references to the old name
4. Search for and update references in other skills

#### For Content Creation Tasks

1. **Fetch documentation** using WebFetch for the URLs listed
   - If WebFetch fails, use WebSearch fallback: `site:dev.algorand.co {topic}`
   - Extract key concepts, syntax rules, and common patterns

2. **Study existing skills** for format consistency:
   - Read `skills/algorand-typescript/SKILL.md` as the gold standard (after rename)
   - Match the section structure, code example style, and tone

3. **Create the skill files**:
   - Start with SKILL.md (main file, under 500 lines)
   - Create sub-files for detailed topics
   - Follow the template in `ralph/templates/SKILL.template.md`

4. **Include code examples**:
   - Every rule needs CORRECT and INCORRECT examples
   - Examples must be complete (include imports)
   - Use realistic variable names

### Step 4: Update Progress

After completing a task:
1. Mark it as `[x]` completed in the QUEUE
2. Add it to "Completed Tasks" with a brief summary
3. Update "Current Task" to the next item
4. Add an entry to the "Iteration Log"

### Step 5: Commit Changes

Create a git commit with:
- Clear message describing what was added/changed
- Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>

Example:
```bash
git add -A && git commit -m "$(cat <<'EOF'
Rename creating-projects to create-project

- Rename directory to action-oriented name
- Update SKILL.md frontmatter
- Update references in other skills

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Step 6: Check Completion

If all QUEUE items are checked (including FINALIZATION):
- Output: `SKILLS_COMPLETE`
- This signals Ralph to exit

Otherwise, continue to the next iteration.

## Quality Standards

Following [Anthropic's Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

### Naming Convention

```
{action}-{target}[-{qualifier}]
```

- **Action-oriented**: Use imperative verbs (`build-`, `test-`, `use-`, `create-`)
- **Format**: Lowercase letters, numbers, hyphens only
- **Max length**: 64 characters

### SKILL.md Format

```markdown
---
name: skill-name
description: Third-person description of what this skill does. Use when [triggers].
---

# Skill Title

## When to use this skill

- Bullet points of use cases
- **Strong triggers:** phrases that activate this skill

## Overview / Core Workflow

1. Numbered steps (high-level)

## How to proceed

Detailed instructions with code examples

## Important Rules / Guidelines

Tables and code examples with CORRECT/INCORRECT

## Common Variations / Edge Cases

| Scenario | Approach |
|----------|----------|

## References / Further Reading

- Links to sub-files and related skills
```

### Description Field (Critical)

The description enables skill discovery. Must include:
1. **What** the skill does (third person)
2. **When** to use it (triggers)

**Good**:
```yaml
description: Build Algorand smart contracts using TypeScript or Python. Use when creating contracts, writing contract code, or asking about development patterns.
```

**Bad**:
```yaml
description: Helps with contracts
```

### Code Example Format

```typescript
// CORRECT - Brief explanation
const amount: uint64 = Uint64(20)

// INCORRECT - Why this fails
const amount = 20  // Error: JavaScript number not allowed in AVM
```

### What NOT To Do

- Do NOT exceed 500 lines per file (split into sub-files)
- Do NOT duplicate content from other skills
- Do NOT include PyTEAL or Beaker patterns (deprecated)
- Do NOT create empty placeholder files
- Do NOT skip the git commit step
- Do NOT use deeply nested references (keep one level deep from SKILL.md)
- Do NOT include time-sensitive information

## Important Context

### LLM Failure Modes to Address

Skills should prevent these common LLM mistakes:

1. **Type errors**: Using JS/Python native types instead of AVM types
2. **Missing clone()**: Not cloning complex types on read/write
3. **Opt-in forgotten**: Not opting into assets or apps before use
4. **MBR not funded**: Not funding accounts for minimum balance
5. **Wrong decorators**: Confusing @arc4.abimethod with @subroutine
6. **Legacy patterns**: Using PyTEAL, Beaker, or raw TEAL

### Documentation Structure

Algorand docs are at https://dev.algorand.co/ with these sections:
- `/concepts/` - Core blockchain concepts
- `/algokit/` - AlgoKit tools and utilities
- `/reference/` - API and CLI references

### Skills Location

All skills are in `skills/<skill-name>/` with:
- `SKILL.md` - Main file (required)
- `REFERENCE.md` - Detailed reference (optional)
- `typescript/` - TypeScript-specific content (optional)
- `python/` - Python-specific content (optional)
- `*.md` - Topic-specific files (optional)

### Skill Organization

Skills should mirror the Algorand docs structure:

| Category | Skills |
|----------|--------|
| Getting Started | `create-project` |
| Smart Contracts | `build-smart-contracts`, `algorand-typescript`, `test-smart-contracts`, `call-smart-contracts` |
| Client Apps | `use-algokit-utils` |
| Tooling | `use-algokit-cli` |
| Debugging | `troubleshoot-errors` |
| Standards | `implement-arc-standards` |
| Frontend | `deploy-react-frontend` |
| Meta | `search-algorand-examples` |

## Begin

Read `ralph/progress.md` now and start the first/next task.
