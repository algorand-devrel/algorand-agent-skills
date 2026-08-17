# Hermes Agent Setup

Configure [Hermes Agent](https://hermes-agent.nousresearch.com) (by Nous Research) for AI-assisted Algorand development.

> **Note**: Unlike most tools in this repo, Hermes reads its skills and MCP configuration from the **global** `~/.hermes/` directory rather than per-project config files. Project-level context still comes from `AGENTS.md` in your project root, which Hermes loads automatically.

## Prerequisites

- [AlgoKit](https://github.com/algorandfoundation/algokit-cli) installed
- [Hermes Agent](https://github.com/NousResearch/hermes-agent) installed
- GitHub Personal Access Token (PAT) with expiration date

## Setup Steps

### 1. Clone or Download This Repository

```bash
git clone https://github.com/algorand-devrel/algorand-agent-skills.git
cd algorand-agent-skills
```

### 2. Install the Skills

**Option A (recommended): skills CLI.** The [skills CLI](https://github.com/vercel-labs/skills) supports Hermes Agent (agent name `hermes-agent`) and installs into `~/.hermes/skills/` (respecting `$HERMES_HOME`):

```bash
npx skills add algorand-devrel/algorand-agent-skills/skills -g -a hermes-agent -s '*' -y
```

Skills installed this way are tracked by the CLI — update them later with `npx skills update`, list them with `npx skills ls -g`.

**Option B: manual copy.** Hermes loads skills from `~/.hermes/skills/`:

```bash
cp -r /path/to/algorand-agent-skills/skills/* ~/.hermes/skills/
```

Or keep them in your project and register the directory in `~/.hermes/config.yaml` instead:

```yaml
skills:
  external_dirs:
    - /path/to/your-project/skills
```

With `external_dirs`, skills stay in your repo (committable and shareable), and Hermes indexes them alongside its own. If a skill name exists in both locations, the one in `~/.hermes/skills/` wins.

### 3. Copy AGENTS.md to Your Project

Hermes automatically loads `AGENTS.md` from your project root (and merges `AGENTS.md` files from the git root down to the working directory):

```bash
# From your AlgoKit project directory:
cp /path/to/algorand-agent-skills/setups/AGENTS.md ./
```

If you already have an `AGENTS.md`, merge the content instead.

### 4. Configure MCP Servers

Add the `mcp_servers` section from [`config.yaml`](./config.yaml) to `~/.hermes/config.yaml`:

```yaml
mcp_servers:
  kapa:
    url: "https://algorand-docs.mcp.kapa.ai/"
    auth: oauth
    enabled: true
  github:
    url: "https://api.githubcopilot.com/mcp/"
    headers:
      Authorization: "Bearer ${env:GITHUB_TOKEN}"
    enabled: true
```

- **Kapa** uses OAuth — Hermes opens a browser authorization flow on first connection.
- **GitHub** reads your PAT from the `GITHUB_TOKEN` environment variable via `${env:GITHUB_TOKEN}`. You can also put `GITHUB_TOKEN=github_pat_...` in `~/.hermes/.env`.

If Hermes is already running, reload the servers with:

```
/reload-mcp
```

### 5. Set GitHub Token Environment Variable

```bash
export GITHUB_TOKEN="github_pat_abc123..."
```

To make this permanent, add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.), or add the line to `~/.hermes/.env`.

**PAT Requirements:**
- Must have an expiration date (some MCP clients refuse non-expiring tokens)
- Default permissions work (read access to public repositories)
- Create at: https://github.com/settings/personal-access-tokens

## Files to Copy

| Source | Destination | Required |
|--------|-------------|----------|
| `skills/` | `~/.hermes/skills/` (or register via `skills.external_dirs`) | Yes |
| `setups/AGENTS.md` | `./AGENTS.md` (project root) | Yes (or merge) |
| `setups/hermes/config.yaml` | Merge into `~/.hermes/config.yaml` | Yes |

## Verifying Setup

1. Start Hermes in your project directory:
   ```bash
   hermes chat
   ```

2. List the installed skills:
   ```
   /skills list
   ```
   The `algorand-*` and `algokit-*` skills should appear. Each is also available as a slash command (e.g. `/algorand-typescript`).

3. Test the Kapa MCP:
   ```
   Search for "GlobalState" in Algorand docs
   ```

4. Test the GitHub MCP:
   ```
   Get the contents of algorandfoundation/puya-ts/examples/hello_world_arc4/contract.algo.ts
   ```

5. Test a skill:
   ```
   Create a new smart contract that stores a counter
   ```

## Troubleshooting

### Skills not showing up
- Verify the skills are in `~/.hermes/skills/` (each skill folder must contain a `SKILL.md`)
- If using `external_dirs`, verify the path in `~/.hermes/config.yaml` is absolute and correct
- Restart Hermes after config changes

### MCP tools not available
- Check YAML syntax in `~/.hermes/config.yaml` (`mcp_servers` is a map keyed by server name, not a list)
- Run `/reload-mcp` after editing the config

### GitHub authentication failed
- Verify `GITHUB_TOKEN` is set in your environment or `~/.hermes/.env`
- Verify your PAT has an expiration date and hasn't expired

### Kapa OAuth issues
- Delete the cached token and reconnect to re-trigger the browser authorization flow
- Check your network connection

## Resources

- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs/)
- [Hermes Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- [Hermes MCP Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp)
- [Hermes Context Files (AGENTS.md)](https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
