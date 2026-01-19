# GitHub Copilot Setup

Configure [GitHub Copilot](https://github.com/features/copilot) for AI-assisted Algorand development.

> **Note**: These instructions are for **per-project setup**. For organization-wide configuration, refer to the [GitHub Copilot documentation](https://docs.github.com/en/copilot).

## Prerequisites

- [AlgoKit](https://github.com/algorandfoundation/algokit-cli) installed
- GitHub Copilot subscription
- VS Code with GitHub Copilot extension

## Setup Steps

### 1. Clone or Download This Repository

```bash
git clone https://github.com/algorand-devrel/algorand-agent-skills.git
cd algorand-agent-skills
```

### 2. Copy Files to Your Project

```bash
# From your AlgoKit project directory:

# Copy skills
cp -r /path/to/algorand-agent-skills/skills ./

# Copy AGENTS.md (or merge with existing)
cp /path/to/algorand-agent-skills/setups/AGENTS.md ./

# Copy Copilot instructions
mkdir -p .github
cp /path/to/algorand-agent-skills/setups/copilot/copilot-instructions.md ./.github/copilot-instructions.md
```

## Files to Copy

| Source | Destination | Required |
|--------|-------------|----------|
| `skills/` | `./skills/` | Yes |
| `setups/AGENTS.md` | `./AGENTS.md` | Yes (or merge) |
| `setups/copilot/copilot-instructions.md` | `./.github/copilot-instructions.md` | Yes |

## AGENTS.md Note

**If you already have an AGENTS.md**: Merge the content from `setups/AGENTS.md` into your existing file.

**If you don't have one**: Copy `setups/AGENTS.md` to your project root as `AGENTS.md`.

## What copilot-instructions.md Does

The `.github/copilot-instructions.md` file provides custom instructions for GitHub Copilot in your repository. It tells Copilot to read `AGENTS.md` for project-specific guidance about Algorand development.

## MCP Note

Unlike OpenCode, Claude Code, and Cursor, GitHub Copilot does not currently support MCP servers directly. The skills and AGENTS.md provide guidance, but you won't have access to:
- Kappa MCP (Algorand documentation search)
- GitHub MCP (code example retrieval)

For full MCP support, consider using OpenCode (recommended) or Claude Code.

## Verifying Setup

1. Open your project in VS Code with Copilot enabled

2. Open Copilot Chat and test:
   ```
   Create a new Algorand smart contract that stores a counter
   ```

3. Copilot should reference the skills and AGENTS.md for guidance

## Troubleshooting

### Copilot not using instructions
- Ensure `.github/copilot-instructions.md` exists
- The file must be in the `.github` directory
- Restart VS Code after adding the file

### Skills not being referenced
- Ensure `skills/` directory is in your project root
- Ensure `AGENTS.md` is in your project root
- Try explicitly mentioning "use the build-smart-contracts skill"

## Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Custom Instructions for Copilot](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
