# Cursor Setup

Configure [Cursor](https://cursor.sh) for AI-assisted Algorand development.

> **Note**: These instructions cover **per-project setup**. For global configuration (`~/.cursor/`), refer to the [Cursor documentation](https://cursor.com/docs).

## Prerequisites

- [AlgoKit](https://github.com/algorandfoundation/algokit-cli) installed
- [Cursor](https://cursor.sh) installed
- GitHub Personal Access Token (PAT) with expiration date

## Setup Steps

### 1. Clone or Download This Repository

```bash
git clone https://github.com/algorand-devrel/algorand-agent-skills.git
```

### 2. Copy Files to Your Project

```bash
# From your AlgoKit project directory:

# Copy AGENTS.md (Cursor reads this directly from project root)
cp /path/to/algorand-agent-skills/setups/AGENTS.md ./

# Copy skills to Cursor's skill directory
mkdir -p .cursor/skills
cp -r /path/to/algorand-agent-skills/skills/* .cursor/skills/
```

### 3. Configure MCP Servers

MCP config can be project-level or global:

**Option A: Project-level (recommended)**
```bash
cp /path/to/algorand-agent-skills/setups/cursor/mcp.json .cursor/mcp.json
```

**Option B: Global**
```bash
mkdir -p ~/.cursor
cp /path/to/algorand-agent-skills/setups/cursor/mcp.json ~/.cursor/mcp.json
```

Edit the config and replace `YOUR_GITHUB_PAT` with your actual token:

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

### 4. Restart Cursor

Restart Cursor to load the new configuration.

## Files to Copy

| Source | Destination | Required |
|--------|-------------|----------|
| `setups/AGENTS.md` | `./AGENTS.md` | Yes |
| `skills/*` | `.cursor/skills/` | Yes |
| `setups/cursor/mcp.json` | `.cursor/mcp.json` or `~/.cursor/mcp.json` | Yes |

## How It Works

- **AGENTS.md**: Cursor reads this directly from your project root for agent instructions
- **Skills**: Place in `.cursor/skills/` directory. Cursor also discovers skills from `.claude/skills/` and `.codex/skills/`
- **MCP**: Configure in `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (global)

## AGENTS.md Note

**If you already have an AGENTS.md**: Merge the content from `setups/AGENTS.md` into your existing file.

**If you don't have one**: Copy `setups/AGENTS.md` to your project root as `AGENTS.md`.

## Note on Skills

Skills in `.cursor/skills/` are automatically discovered by Cursor. Cursor also checks `.claude/skills/` and `.codex/skills/` directories.

## PAT Requirements

- Must have an expiration date (some MCP clients refuse non-expiring tokens)
- Default permissions work (read access to public repositories)
- Create at: https://github.com/settings/personal-access-tokens

## Verifying Setup

1. Open your project in Cursor

2. Test MCP tools in Agent chat:
   ```
   Search for "GlobalState" in Algorand docs
   ```

3. Test GitHub MCP:
   ```
   Get the contents of algorandfoundation/puya-ts/examples/hello_world_arc4/contract.algo.ts
   ```

4. Test a skill:
   ```
   Create a new smart contract that stores a counter
   ```

## Troubleshooting

### MCP tools not available
- Verify `.cursor/mcp.json` or `~/.cursor/mcp.json` exists
- Check JSON syntax is valid
- Restart Cursor after config changes
- Check Cursor's MCP panel (Settings → Tools & Integrations → MCP Tools) for green status

### GitHub authentication failed
- Verify your PAT has an expiration date
- Check the PAT hasn't expired
- Ensure the `Bearer` prefix is included in the Authorization header

### Skills not loading
- Check skills are in `.cursor/skills/` directory
- Each skill folder must contain a `SKILL.md` file
- Restart Cursor after adding skills

### Kapa OAuth issues
- Cursor will prompt for re-authentication when needed
- Check your network connection

## Resources

- [Cursor Skills Documentation](https://cursor.com/docs/context/skills)
- [Cursor MCP Documentation](https://cursor.com/docs/context/mcp)
- [Cursor Rules Documentation](https://cursor.com/docs/context/rules)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
