# Algorand Agent Skills

Agent skills and configurations for AI-assisted Algorand development. Give your AI coding assistant the knowledge to build smart contracts, deploy applications, and follow Algorand best practices.

## Quick Start

Choose your AI coding tool and follow the setup guide.

> **Note**: These instructions are for **per-project setup**. For global/user-level configuration, refer to each tool's official documentation.

### OpenCode (Recommended)

[OpenCode](https://opencode.ai) is an open-source AI coding agent with full MCP support.

```bash
# 1. Clone this repo
git clone https://github.com/algorand-devrel/algorand-agent-skills.git

# 2. In your AlgoKit project, copy the files:
cp -r algorand-agent-skills/skills ./
cp algorand-agent-skills/setups/AGENTS.md ./
cp algorand-agent-skills/setups/opencode/opencode.json ./

# 3. Set GITHUB_TOKEN env var (see GitHub PAT Setup below)
# 4. Run: opencode
```

[Full OpenCode setup guide](./setups/opencode/README.md)

### Claude Code

```bash
cp -r algorand-agent-skills/skills ./
cp algorand-agent-skills/setups/AGENTS.md ./
cp algorand-agent-skills/setups/claude-code/.mcp.json ./
cp algorand-agent-skills/setups/claude-code/CLAUDE.md ./
```

[Full Claude Code setup guide](./setups/claude-code/README.md)

### Cursor

```bash
cp algorand-agent-skills/setups/AGENTS.md ./
mkdir -p .cursor/skills
cp -r algorand-agent-skills/skills/* .cursor/skills/
cp algorand-agent-skills/setups/cursor/mcp.json .cursor/mcp.json
```

[Full Cursor setup guide](./setups/cursor/README.md)

### GitHub Copilot

```bash
cp -r algorand-agent-skills/skills ./
cp algorand-agent-skills/setups/AGENTS.md ./
mkdir -p .github
cp algorand-agent-skills/setups/copilot/copilot-instructions.md ./.github/
```

[Full Copilot setup guide](./setups/copilot/README.md)

## What's Included

### Skills

Skills teach AI assistants how to complete Algorand-specific tasks:

| Skill                      | Description                                       |
| -------------------------- | ------------------------------------------------- |
| `create-project`           | Initialize AlgoKit projects with best practices   |
| `build-smart-contracts`    | Build contracts in Algorand TypeScript or Python  |
| `algorand-typescript`      | Syntax rules for Algorand TypeScript (PuyaTs)     |
| `algorand-ts-migration`    | Migrate from TEALScript or beta Algorand TS       |
| `test-smart-contracts`     | Write and run contract tests                      |
| `call-smart-contracts`     | Deploy and interact with contracts                |
| `deploy-react-frontend`    | Build React frontends for dApps                   |
| `use-algokit-cli`          | AlgoKit CLI command reference                     |
| `search-algorand-examples` | Find canonical code examples                      |
| `use-algokit-utils`        | AlgoKit Utils library for SDK interactions        |
| `troubleshoot-errors`      | Diagnose and fix common Algorand errors           |
| `implement-arc-standards`  | Implement ARC-4, ARC-32, and ARC-56 standards     |

Skills for x402 HTTP-native payment protocol with Algorand integration ([Contributed by GoPlausible](https://goplausible.com)):

| Skill                                    | Description                                               |
| ---------------------------------------- | --------------------------------------------------------- |
| `teach-algorand-x402`                   | Teach x402 protocol, payment flow, and component architecture |
| `explain-algorand-x402-typescript`      | Explain x402-avm TypeScript packages and patterns         |
| `explain-algorand-x402-python`          | Explain x402-avm Python package and patterns              |
| `create-typescript-x402-client`         | Build x402 clients with fetch and axios (`@x402-avm/fetch`, `@x402-avm/axios`) |
| `create-typescript-x402-server`         | Build payment-protected servers with Express and Hono     |
| `create-typescript-x402-facilitator`    | Build facilitator services with optional Bazaar extension |
| `create-typescript-x402-paywall`        | Build browser paywall UI for manual payments              |
| `create-typescript-x402-nextjs`         | Build fullstack Next.js apps with payment middleware      |
| `use-typescript-x402-core-avm`          | Use `@x402-avm/core` and `@x402-avm/avm` directly for custom integrations |
| `create-python-x402-client`             | Build x402 clients with httpx (async) and requests (sync) |
| `create-python-x402-server`             | Build payment-protected servers with FastAPI and Flask    |
| `create-python-x402-facilitator`        | Build facilitator services implementing `FacilitatorAvmSigner` |
| `create-python-x402-facilitator-bazaar` | Build facilitator with Bazaar discovery extension         |
| `use-python-x402-core-avm`              | Use `x402-avm[avm]` core and AVM mechanism directly      |

### MCP Servers

MCP (Model Context Protocol) servers give AI assistants access to external tools:

**Kapa MCP** - Algorand Documentation

- Semantic search over official Algorand docs
- URL: `https://algorand-docs.mcp.kapa.ai/`
- Auth: OAuth (prompted on first use)

**GitHub MCP** - Code Examples

- Access canonical examples from Algorand repositories
- URL: `https://api.githubcopilot.com/mcp/`
- Auth: GitHub PAT (requires expiration date)

### Configuration Files

| Tool        | Files                                 |
| ----------- | ------------------------------------- |
| OpenCode    | `opencode.json`                       |
| Claude Code | `.mcp.json`, `CLAUDE.md`              |
| Cursor      | `.cursor/mcp.json`, `.cursor/skills/` |
| Copilot     | `.github/copilot-instructions.md`     |

## AGENTS.md

The `setups/AGENTS.md` file is the canonical instruction set for AI assistants working on Algorand projects. Copy it to your project root (or merge with your existing AGENTS.md).

It includes:

- When and how to use each skill
- MCP tool reference
- Development workflows
- Troubleshooting guidance

## GitHub PAT Setup

All MCP configurations require a GitHub Personal Access Token:

1. Go to https://github.com/settings/personal-access-tokens
2. Create a new token with an **expiration date** (required)
3. Default permissions are sufficient (public repo read access)
4. Set the `GITHUB_TOKEN` environment variable:
   ```bash
   export GITHUB_TOKEN="github_pat_..."
   ```
   Add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) to persist it.

## Packaged Skills (Releases)

Pre-packaged `.zip` files are available from [GitHub Releases](https://github.com/algorand-devrel/algorand-agent-skills/releases). These are single-file bundles that can be extracted directly into your project's skills directory.

To package skills locally:

```bash
./scripts/package-all-skills.sh
```

Packaged skills will be output to the `dist/` directory.

## Resources

- [AlgoKit CLI](https://github.com/algorandfoundation/algokit-cli)
- [Algorand Developer Portal](https://dev.algorand.co/)
- [Puya TypeScript (PuyaTs)](https://github.com/algorandfoundation/puya-ts)
- [Puya Python (PuyaPy)](https://github.com/algorandfoundation/puya)
- [x402 Protocol on Algorand](https://x402.goplausible.xyz)
- [OpenCode](https://opencode.ai)
- [Claude Code](https://claude.ai/code)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on:

- Adding new skills
- Improving existing skills
- Skill format and best practices

## License

MIT License - see [LICENSE](./LICENSE)
