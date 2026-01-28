# Contributing

## Adding a Skill

```bash
# 1. Initialize
./scripts/init_skill.py my-skill --path skills/

# 2. Edit skills/my-skill/SKILL.md

# 3. Validate
./scripts/quick_validate.py skills/my-skill

# 4. Package (optional)
./scripts/package_skill.py skills/my-skill
```

## Skill Structure

```
skills/my-skill/
├── SKILL.md              # Required: frontmatter + instructions
└── references/           # Optional: detailed docs loaded on-demand
```

Keep SKILL.md under 500 lines. Split detailed content into `references/` files.

## Claude Code Users

This repo includes a skill-creator skill in `.claude/skills/`. When working in Claude Code, ask it to help you create or improve skills.

## Resources

- [Anthropic Skills Repo](https://github.com/anthropics/skills)
- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
