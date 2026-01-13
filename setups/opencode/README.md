# OpenCode Setup

Configure [OpenCode](https://opencode.ai) for AI-assisted Algorand development.

> **Note**: These instructions are for **per-project setup**. For global configuration (`~/.config/opencode/opencode.json`), refer to the [OpenCode documentation](https://opencode.ai/docs/config/).

## Prerequisites

- [AlgoKit](https://github.com/algorandfoundation/algokit-cli) installed
- [OpenCode](https://github.com/opencode-ai/opencode) installed
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

# Copy OpenCode config
cp /path/to/algorand-agent-skills/setups/opencode/opencode.json ./
```

### 3. Configure GitHub PAT

Edit `opencode.json` and replace `YOUR_GITHUB_PAT` with your GitHub PAT (no `Bearer` prefix needed):

```json
{
  "mcp": {
    "github": {
      "headers": {
        "Authorization": "github_pat_abc123..."
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

The Kappa MCP uses OAuth authentication. On first use, OpenCode will prompt you to authorize access to Algorand documentation.

## Files to Copy

| Source | Destination | Required |
|--------|-------------|----------|
| `skills/` | `./skills/` | Yes |
| `setups/AGENTS.md` | `./AGENTS.md` | Yes (or merge) |
| `setups/opencode/opencode.json` | `./opencode.json` | Yes |

## AGENTS.md Note

**If you already have an AGENTS.md**: Merge the content from `setups/AGENTS.md` into your existing file.

**If you don't have one**: Copy `setups/AGENTS.md` to your project root as `AGENTS.md`.

## Verifying Setup

1. Start OpenCode in your project directory:
   ```bash
   opencode
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
- Verify `opencode.json` is in your project root
- Check JSON syntax is valid
- Restart OpenCode after config changes

### GitHub authentication failed
- Verify your PAT has an expiration date
- Check the PAT hasn't expired
- Ensure the PAT is entered directly (no `Bearer` prefix needed for OpenCode)

### Kappa OAuth issues
- Run `opencode mcp auth` to re-authenticate
- Check your network connection

## Resources

- [OpenCode Documentation](https://opencode.ai/docs/)
- [OpenCode MCP Configuration](https://opencode.ai/docs/mcp-servers/)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
