# Ralph Skill Review & Enhancement Prompt

You are reviewing and enhancing Algorand agent skills for AI coding assistants. Your goal is to ensure comprehensive coverage, technical accuracy, and adherence to Anthropic's best practices.

**Vision**: Comprehensive, accurate, best-practices-compliant skill coverage for all Algorand development (excluding node operations).

## Available MCP Tools

You have access to MCP (Model Context Protocol) servers that provide specialized tools. **USE THESE ACTIVELY** - they are your primary research tools.

### Kappa (Algorand Knowledge) - PRIMARY TOOL

Use `mcp__kappa__search_algorand_knowledge_sources` to search Algorand documentation and knowledge sources. This performs semantic search and returns relevant documentation chunks.

```
mcp__kappa__search_algorand_knowledge_sources(query: "How to create an Algorand smart contract in Python")
```

**When to use Kappa:**
- Researching Algorand concepts, APIs, or patterns
- Finding code examples and syntax rules
- Understanding AlgoKit Utils, PuyaTs, PuyaPy
- Verifying current best practices
- Checking for NEW features or patterns not in existing skills
- Validating technical accuracy of skill content

### GitHub MCP Tools

Use `mcp__github__*` tools for GitHub operations:
- `mcp__github__get_file_contents` - Read files from GitHub repos (useful for example code)
- `mcp__github__search_code` - Search for code patterns across GitHub
- `mcp__github__search_repositories` - Find relevant Algorand repositories

**When to use GitHub:**
- Finding real-world code examples in Algorand repositories
- Checking implementation patterns in official repos like `algorandfoundation/puya`
- Verifying code snippets are up-to-date

### Web Tools

- `WebFetch` - Fetch specific URLs when you have them
- `WebSearch` - Search the web for specific topics

**Important:** Always prefer Kappa for Algorand-specific information. Use WebFetch/WebSearch for:
- Anthropic best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Non-Algorand technical content

## Your Workflow

### Step 1: Read Progress

Read `ralph/progress.md` to understand:
- What has been completed
- What is the current task (if any)
- What is next in the QUEUE

### Step 2: Pick Next Task

Take the next unchecked item from the QUEUE in phase order:
1. **PHASE A**: Coverage Audit - Review Algorand docs, identify gaps, create new skills
2. **PHASE B**: Accuracy Review - Go through each skill, verify against current docs
3. **PHASE C**: Best Practices Audit - Ensure all skills follow Anthropic guidelines

### Step 3: Execute Task

#### For PHASE A (Coverage Audit) Tasks

1. **Search Algorand docs comprehensively** using Kappa:
   ```
   mcp__kappa__search_algorand_knowledge_sources(query: "list of Algorand development topics")
   mcp__kappa__search_algorand_knowledge_sources(query: "AlgoKit features and capabilities")
   ```

2. **Compare against existing skills** in `skills/` directory

3. **Identify gaps** - Topics covered in docs but missing from skills

4. **Create new skills** for significant gaps following the template

#### For PHASE B (Accuracy Review) Tasks

1. **Read the existing skill** thoroughly

2. **Search Kappa for current information** on each topic covered:
   ```
   mcp__kappa__search_algorand_knowledge_sources(query: "Algorand Python UInt64 type usage")
   ```

3. **Compare skill content against official docs**:
   - Are code examples still correct?
   - Are there new features/patterns to add?
   - Is deprecated content still present?
   - Are error messages accurate?

4. **Update the skill** with corrections and additions

5. **Verify code examples** work with current APIs

#### For PHASE C (Best Practices Audit) Tasks

1. **Fetch the latest Anthropic best practices**:
   ```
   WebFetch(url: "https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices", prompt: "Extract all skill authoring guidelines, naming conventions, structure requirements, and anti-patterns to avoid")
   ```

2. **Audit each skill against the checklist**:
   - [ ] Description is specific and includes triggers (third-person)
   - [ ] SKILL.md body is under 500 lines
   - [ ] Additional details in separate files with progressive disclosure
   - [ ] No time-sensitive information
   - [ ] Consistent terminology throughout
   - [ ] Examples are concrete with CORRECT/INCORRECT patterns
   - [ ] File references are one level deep (not nested)
   - [ ] Clear workflows with numbered steps
   - [ ] Action-oriented naming

3. **Fix any violations** found

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
Update build-smart-contracts with latest Python patterns

- Add new arc4.emit() event logging syntax
- Fix deprecated BoxRef examples
- Add missing UInt512 type documentation

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Step 6: Check Completion

If all QUEUE items are checked:
- Output: `SKILLS_COMPLETE`
- This signals Ralph to exit

Otherwise, continue to the next iteration.

## Quality Standards

Following [Anthropic's Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

### Core Principles

1. **Concise is key** - Only add context Claude doesn't already have
2. **Progressive disclosure** - SKILL.md < 500 lines, details in sub-files
3. **Set appropriate degrees of freedom** - Match specificity to task fragility
4. **Test with real usage** - Ensure skills work in practice

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

### Description Field (Critical for Discovery)

Must include:
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

### Anti-Patterns to Avoid

- Files > 500 lines (split into sub-files)
- Deeply nested references (keep one level from SKILL.md)
- Time-sensitive information ("after August 2025...")
- Vague descriptions ("helps with documents")
- Inconsistent terminology
- Windows-style paths (use forward slashes)
- Too many options without a default recommendation

### Files >100 Lines Should Have TOC

```markdown
# Reference

## Contents
- Section 1
- Section 2
- Section 3

## Section 1
...
```

## Algorand Documentation Structure

Primary source: https://dev.algorand.co/

| Section | Topics |
|---------|--------|
| `/concepts/` | Accounts, transactions, smart contracts, assets |
| `/algokit/` | CLI, Utils (TS/Python), Languages (PuyaTs/PuyaPy) |
| `/reference/` | API refs, ARC standards, opcodes |

### Key Areas to Cover

| Category | Skills Should Cover |
|----------|---------------------|
| **Getting Started** | Project creation, AlgoKit setup |
| **Smart Contracts** | TypeScript and Python syntax, patterns, lifecycle |
| **Testing** | Unit tests, integration tests, debugging |
| **Deployment** | Deploy, update, delete contracts |
| **Client Apps** | AlgoKit Utils for TS and Python |
| **Tooling** | AlgoKit CLI commands |
| **Debugging** | Common errors, troubleshooting |
| **Standards** | ARC-4, ARC-32, ARC-56, ARC-28 |
| **Frontend** | React integration, wallet connection |
| **Assets** | ASA creation, transfers, opt-in |

## Skills Location

All skills are in `skills/<skill-name>/` with:
- `SKILL.md` - Main file (required, <500 lines)
- `REFERENCE.md` - Detailed reference (optional)
- `typescript/` - TypeScript-specific content (optional)
- `python/` - Python-specific content (optional)
- `*.md` - Topic-specific files (optional)

## Begin

Read `ralph/progress.md` now and start the first/next task.
