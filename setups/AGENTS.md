# AGENTS.md

## Overview

This project develops Algorand blockchain applications including smart contracts and frontend interfaces. When working here, always leverage the available skills and MCP tools before writing code—they provide canonical syntax, examples, and documentation that prevent errors and save time.

## Creating New Projects

Before initializing any AlgoKit project:

1. **Load the skill**: Use `create-project` skill for project setup guidance
2. **Run**: `algokit init -n <name> -t typescript --answer preset "Production" --defaults`

## Writing Smart Contracts

Before writing ANY Algorand contract code:

1. **Load the skill first**: Use `build-smart-contracts` skill
2. **Search docs**: Call `kappa_search_algorand_knowledge_sources` for concepts
3. **Get examples**: Use `github_get_file_contents` from:
   - `algorandfoundation/devportal-code-examples`
   - `algorandfoundation/puya-ts` (examples/)
4. **Write code** following skill guidance
5. **Build/test**: `algokit project run build && algokit project run test`

## Deploying & Calling Contracts

Use the **CLI and generated TypeScript clients** for deployment and interaction.

### Workflow

1. **Load the skill**: Use `call-smart-contracts` skill
2. **Start localnet**: `algokit localnet start`
3. **Build contracts**: `algokit project run build`
4. **Deploy to localnet**: `algokit project deploy localnet`
   - This runs `deploy-config.ts` which uses the generated client
   - Handles idempotent deployment (safe to re-run)
   - Note the App ID from the deployment output

### Contract Interaction

After deployment, interact with contracts using the generated TypeScript client:

1. **Write interaction scripts** in `deploy-config.ts` or separate scripts
2. **Use the typed client** generated from the ARC-56 app spec
3. **Run scripts**: `npx tsx scripts/call-contract.ts`

See the `call-smart-contracts` skill for detailed patterns and examples.

## Building React Frontends

Before building a React frontend that interacts with Algorand contracts:

1. **Load the skill**: Use `deploy-react-frontend` skill
2. **Prerequisites**: Deployed contract with known App ID, ARC-56 app spec
3. **Generate typed client**: `algokit generate client MyContract.arc56.json --output src/contracts/MyContractClient.ts`
4. **Install deps**: `npm install @algorandfoundation/algokit-utils @txnlab/use-wallet-react algosdk`
5. **Follow the "signer handoff" pattern**:
   - Set up `WalletProvider` with `@txnlab/use-wallet-react`
   - Get `transactionSigner` from `useWallet()` hook
   - Register signer: `algorand.setSigner(activeAddress, transactionSigner)`
   - Create typed client with `defaultSender: activeAddress`

## Available Skills

| Task                | Skill                      |
| ------------------- | -------------------------- |
| Initialize projects | `create-project`           |
| Create contracts    | `build-smart-contracts`    |
| Syntax questions    | `algorand-typescript`      |
| Build/deploy cmds   | `use-algokit-cli`          |
| Write tests         | `test-smart-contracts`     |
| Find examples       | `search-algorand-examples` |
| Deploy & call       | `call-smart-contracts`     |
| React frontends     | `deploy-react-frontend`    |
| SDK interactions    | `use-algokit-utils`        |
| Debug errors        | `troubleshoot-errors`      |
| ARC standards       | `implement-arc-standards`  |

## MCP Tools

**Important:** These tools are provided by MCP servers. If a tool isn't available when you try to use it, the MCP server may not be configured. Check for a `.mcp.json` (Claude Code) or `opencode.json` (OpenCode) file in the project root. If the config exists but tools still aren't available, restart your coding agent.

### Documentation Search (Kappa)

| Tool                                      | Purpose                       |
| ----------------------------------------- | ----------------------------- |
| `kappa_search_algorand_knowledge_sources` | Search official Algorand docs |

### GitHub (Code Examples)

| Tool                         | Purpose                          |
| ---------------------------- | -------------------------------- |
| `github_get_file_contents`   | Retrieve example code from repos |
| `github_search_code`         | Find code patterns across repos  |
| `github_search_repositories` | Discover repos by topic/name     |

## Troubleshooting

### MCP Tools Not Available

If MCP tools aren't available, use these fallbacks:

| Missing Tool                              | Fallback                                                        |
| ----------------------------------------- | --------------------------------------------------------------- |
| `kappa_search_algorand_knowledge_sources` | Use web search for "site:dev.algorand.co {query}"               |
| `github_get_file_contents`                | Use web search or browse GitHub directly                        |
| `github_search_code`                      | Use web search for "site:github.com algorandfoundation {query}" |

**To fix MCP configuration:**

1. **Check config exists**: Look for `.mcp.json` (Claude Code), `opencode.json` (OpenCode), or `.cursor/mcp.json` (Cursor)
2. **Verify server entries**: Config should include `kappa` and `github` MCP servers
3. **Restart the agent**: MCP tools load at startup; restart after config changes

**Note:** You can always proceed without MCPs by:

- Using web search for documentation (dev.algorand.co)
- Browsing GitHub repos directly (algorandfoundation/puya-ts, algorandfoundation/devportal-code-examples)
- Using CLI commands for all deployment and testing

### Localnet Connection Errors

If localnet commands fail with "network unreachable" or connection errors:

1. **Start localnet**: `algokit localnet start`
2. **Verify it's running**: `algokit localnet status`
3. **Reset if needed**: `algokit localnet reset`

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
