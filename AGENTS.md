# AGENTS.md

This repository contains **Algorand Agent Skills** - a collection of skills and configurations for AI-assisted Algorand development.

## What This Repo Contains

- **`skills/`** - Universal Algorand skills (building contracts, testing, deployment, etc.)
- **`setups/`** - Tool-specific configurations for OpenCode, Claude Code, Cursor, and Copilot
- **`examples/`** - Workflow examples showing skills in action

## For Agents Working on This Repo

When contributing to this repo, follow these guidelines:

### Skill Structure

Each skill lives in `skills/<skill-name>/` with:

- `SKILL.md` - Required: YAML frontmatter + instructions
- `REFERENCE.md` - Optional: Detailed reference documentation
- `EXAMPLES.md` - Optional: Usage examples
- Additional `.md` files for topic-specific details

### SKILL.md Format

```yaml
---
name: skill-name
description: Brief description of when to use this skill
---

# Skill Title

## When to use this skill
[Triggers and use cases]

## Overview / Core Workflow
[Main steps]

## How to proceed
[Detailed instructions]

## Important Rules / Guidelines
[Critical do's and don'ts]

## References / Further Reading
[Links to related skills and docs]
```

### Best Practices

1. **Keep SKILL.md under 500 lines** - Split detailed content into separate files
2. **Include strong triggers** - List phrases that should activate this skill
3. **Provide examples** - Show correct and incorrect patterns
4. **Link related skills** - Help agents discover related capabilities, see [Progressive Disclosure](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)

### Testing Skills

To test a skill:

1. Create a test AlgoKit project
2. Copy `setups/AGENTS.md` and relevant setup files to the project
3. Copy the `skills/` directory
4. Use your AI coding tool to trigger the skill
5. Verify the output follows expected patterns

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed contribution guidelines, including:

- How to add new skills
- PR process and review checklist
- Style guide

## Resources

- [Official Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Platform Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
