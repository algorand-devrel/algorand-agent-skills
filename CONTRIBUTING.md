# Contributing to Algorand Agent Skills

Thank you for contributing to Algorand Agent Skills! This guide explains how to add new skills, improve existing ones, and follow best practices.

## Official Skill Documentation

Before contributing, familiarize yourself with the Agent Skills specification:

- [Anthropic Skills Repository](https://github.com/anthropics/skills) - Official skills collection and format
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) - Skills in Claude Code
- [Agent Skills Platform Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) - Platform documentation

## Skill Structure

Each skill lives in `skills/<skill-name>/` with these files:

```
skills/
└── my-new-skill/
    ├── SKILL.md          # Required: Main skill file with frontmatter
    ├── REFERENCE.md      # Optional: Detailed reference documentation
    ├── EXAMPLES.md       # Optional: Usage examples
    └── *.md              # Optional: Additional topic-specific files
```

### SKILL.md Format

Every skill requires a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description of when to use this skill. This appears in skill listings.
---

# Skill Title

## When to use this skill

Use this skill when the user wants to:
- [Specific use case 1]
- [Specific use case 2]

**Strong triggers:**
- "phrase that should activate this skill"
- "another trigger phrase"

## Overview / Core Workflow

[Brief overview of the main workflow - numbered steps]

## How to proceed

[Detailed step-by-step instructions]

## Important Rules / Guidelines

[Critical do's and don'ts - what must be followed]

## Common Variations / Edge Cases

[Table or list of variations and how to handle them]

## References / Further Reading

[Links to related skills, docs, and resources]
```

### Best Practices

1. **Keep SKILL.md under 500 lines**
   - Split detailed content into separate files (REFERENCE.md, EXAMPLES.md)
   - Link to supporting files from SKILL.md

2. **Include strong triggers**
   - List phrases that should activate this skill
   - Be specific ("create a voting contract" not just "create")

3. **Show correct and incorrect patterns**
   - Use code blocks with `// CORRECT` and `// INCORRECT` comments
   - Explain why incorrect patterns fail

4. **Link related skills**
   - Help agents discover related capabilities
   - Use relative paths: `../other-skill/SKILL.md`

5. **Provide actionable steps**
   - Each "How to proceed" step should be concrete
   - Include actual commands, not just descriptions

## Adding a New Skill

1. **Create the skill directory:**
   ```bash
   mkdir -p skills/my-new-skill
   ```

2. **Create SKILL.md** with required frontmatter and sections

3. **Test the skill** (see Testing section below)

4. **Update setups/AGENTS.md** to include the new skill in the skills table

5. **Submit a PR** with a clear description of what the skill does

## Improving Existing Skills

1. **Read the existing skill** thoroughly
2. **Understand the intent** - don't change the purpose
3. **Make targeted changes** - fix what's broken, don't rewrite
4. **Test your changes** - verify the skill still works
5. **Document why** - explain your changes in the PR

## Testing Skills

To test a skill before submitting:

1. **Create a test project:**
   ```bash
   algokit init -n test-project -t typescript --defaults
   cd test-project
   ```

2. **Copy the skill files:**
   ```bash
   cp -r /path/to/algorand-agent-skills/skills ./
   cp /path/to/algorand-agent-skills/setups/AGENTS.md ./
   ```

3. **Copy your tool's config** (OpenCode, Claude Code, etc.)

4. **Test the trigger phrases:**
   - Start your AI coding tool
   - Use the trigger phrases from the skill
   - Verify the skill activates and provides correct guidance

5. **Test edge cases:**
   - Try variations mentioned in the skill
   - Verify error handling guidance works

## Pull Request Checklist

Before submitting a PR:

- [ ] SKILL.md has valid YAML frontmatter (`name` and `description`)
- [ ] SKILL.md includes all required sections
- [ ] SKILL.md is under 500 lines (split into supporting files if needed)
- [ ] Code examples are correct and tested
- [ ] Links to related skills use relative paths
- [ ] setups/AGENTS.md is updated (for new skills)
- [ ] You've tested the skill with at least one AI coding tool

## Style Guide

### Naming

- Skill directories: `kebab-case` (e.g., `building-smart-contracts`)
- Skill names in frontmatter: match directory name
- File names: `UPPERCASE.md` for main files, `lowercase.md` for topic files

### Content

- Use present tense ("Use this skill when..." not "This skill is used when...")
- Be direct and concise
- Use tables for comparisons and variations
- Use code blocks for all code, commands, and file contents

### Code Examples

```typescript
// CORRECT - Shows proper pattern
const amount: uint64 = Uint64(20)

// INCORRECT - Explains why this fails
const amount = 20  // Error: JavaScript number not allowed
```

## Questions?

- Open an issue for questions about contributing
- Check existing skills for examples of good patterns
- Reference the official documentation linked above
