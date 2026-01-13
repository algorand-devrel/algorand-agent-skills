# Claude Code Setup

Configure [Claude Code](https://claude.ai/code) for AI-assisted Algorand development.

> **Note**: These instructions are for **per-project setup**. For global configuration (`~/.claude.json`), refer to the [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code).

## Prerequisites

- [AlgoKit](https://github.com/algorandfoundation/algokit-cli) installed
- [Claude Code](https://claude.ai/code) installed
- GitHub Personal Access Token (PAT) with expiration date

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

# Copy Claude Code config files
cp /path/to/algorand-agent-skills/setups/claude-code/.mcp.json ./
cp /path/to/algorand-agent-skills/setups/claude-code/CLAUDE.md ./
```

### 3. Configure GitHub PAT

Edit `.mcp.json` and replace `YOUR_GITHUB_PAT` with your GitHub PAT (include the `Bearer` prefix):

```json
{
  "mcpServers": {
    "github": {
      "headers": {
        "Authorization": "Bearer ghp_abc123..."
      }
    }
  }
}
```

**PAT Requirements:**
- Must have an expiration date (some MCP clients refuse non-expiring tokens)
- Default permissions work (read access to public repositories)
- Create at: https://github.com/settings/personal-access-tokens

### 4. Authenticate Kappa MCP

The Kappa MCP uses OAuth authentication. On first use, Claude Code will prompt you to authorize access to Algorand documentation.

## Files to Copy

| Source | Destination | Required |
|--------|-------------|----------|
| `skills/` | `./skills/` | Yes |
| `setups/AGENTS.md` | `./AGENTS.md` | Yes (or merge) |
| `setups/claude-code/.mcp.json` | `./.mcp.json` | Yes |
| `setups/claude-code/CLAUDE.md` | `./CLAUDE.md` | Yes |

## AGENTS.md Note

**If you already have an AGENTS.md**: Merge the content from `setups/AGENTS.md` into your existing file.

**If you don't have one**: Copy `setups/AGENTS.md` to your project root as `AGENTS.md`.

## What CLAUDE.md Does

The `CLAUDE.md` file tells Claude Code to read `AGENTS.md` for project-specific guidance. It contains:

```markdown
All agents should read `AGENTS.md` as the canonical source for project guidance.
```

## Verifying Setup

1. Open Claude Code in your project directory:
   ```bash
   claude
   ```

2. Test the Kappa MCP:
   ```
   Search for "GlobalState" in Algorand docs
   ```

3. Test the GitHub MCP:
   ```
   Get the contents of algorandfoundation/puya-ts/examples/hello_world_arc4/contract.algo.ts
   ```

4. Test a skill:
   ```
   Create a new smart contract that stores a counter
   ```

## Troubleshooting

### MCP tools not available
- Verify `.mcp.json` is in your project root
- Check JSON syntax is valid
- Restart Claude Code after config changes

### GitHub authentication failed
- Verify your PAT has an expiration date
- Check the PAT hasn't expired
- Ensure the `Bearer` prefix is included in the Authorization header

### Kappa OAuth issues
- Claude Code will prompt for re-authentication automatically
- Check your network connection

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code MCP Configuration](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
