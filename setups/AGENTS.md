# AGENTS.md

## Overview

This project develops Algorand blockchain applications including smart contracts, frontend interfaces and x402 applications. When working here, always leverage the available skills and MCP tools before writing code—they provide canonical syntax, examples, and documentation that prevent errors and save time.

## Creating New Projects

Before initializing any AlgoKit project:

1. **Load the skill**: Use `algorand-project-setup` skill
2. **Run**: `algokit init -n <name> -t typescript --answer preset_name production --defaults`

## Understanding AVM Constraints

Before writing any smart contract, understand what the AVM actually is — a stack machine with two types (`uint64`, `bytes`) and hard resource limits. LLMs default to TEAL/PyTeal and treat contract code like normal TypeScript/Python. The `algorand-core` skill resets this mental model.

1. **Load the core skill**: Use `algorand-core` for AVM mental model, execution model, and resource limits
2. **Then proceed** to the language-specific skill for syntax and patterns

## Writing Smart Contracts

Before writing ANY Algorand contract code:

0. **Understand AVM constraints**: Use `algorand-core` skill for the foundational mental model
1. **Load the skill first**: Use `algorand-typescript` (or `algorand-python` for Python)
2. **Search docs**: Call `kapa_search_algorand_knowledge_sources` for concepts
3. **Get examples**: Use `github_get_file_contents` from:
   - `algorandfoundation/devportal-code-examples`
   - `algorandfoundation/puya-ts` (TypeScript) or `algorandfoundation/puya` (Python)
4. **Write code** following skill guidance
5. **Build/test**: `algokit project run build && algokit project run test`

## Deploying & Calling Contracts

Use the **CLI and generated typed clients** for deployment and interaction.

### Workflow

1. **Load the skill**: Use `algorand-typescript` or `algorand-python` — deployment/interaction references are included
2. **Start localnet**: `algokit localnet start`
3. **Build contracts**: `algokit project run build`
4. **Deploy to localnet**: `algokit project deploy localnet`
   - Handles idempotent deployment (safe to re-run)
   - Note the App ID from the deployment output

### Contract Interaction

After deployment, interact with contracts using the generated typed client:

1. **Write interaction scripts** using the typed client
2. **Use the typed client** generated from the ARC-56 app spec
3. **Run scripts**: `npx tsx scripts/call-contract.ts` (TS) or `python scripts/call_contract.py` (Python)

See the `deploy-interaction.md` reference in your language skill for detailed patterns.

## Building React Frontends

Before building a React frontend that interacts with Algorand contracts:

1. **Load the skill**: Use `algorand-frontend` skill
2. **Prerequisites**: Deployed contract with known App ID, ARC-56 app spec
3. **Generate typed client**: `algokit generate client MyContract.arc56.json --output src/contracts/MyContractClient.ts`
4. **Install deps**: `npm install @algorandfoundation/algokit-utils @txnlab/use-wallet-react algosdk`
5. **Follow the "signer handoff" pattern**:
   - Set up `WalletProvider` with `@txnlab/use-wallet-react`
   - Get `transactionSigner` from `useWallet()` hook
   - Register signer: `algorand.setSigner(activeAddress, transactionSigner)`
   - Create typed client with `defaultSender: activeAddress`

## Available Skills

| Task                         | Skill                      |
| ---------------------------- | -------------------------- |
| AVM mental model, limits     | `algorand-core`            |
| Initialize projects, CLI     | `algorand-project-setup`   |
| TypeScript development       | `algorand-typescript`      |
| Python development           | `algorand-python`          |
| React frontends              | `algorand-frontend`        |
| TypeScript x402 payments     | `algorand-x402-typescript` |
| Python x402 payments         | `algorand-x402-python`     |

Each language skill covers the full lifecycle: syntax, building, testing, deployment, AlgoKit Utils, ARC standards, and troubleshooting.

## MCP Tools

**Important:** These tools are provided by MCP servers. If a tool isn't available when you try to use it, the MCP server may not be configured. Check for a `.mcp.json` (Claude Code) or `opencode.json` (OpenCode) file in the project root. If the config exists but tools still aren't available, restart your coding agent.

**Note:** MCP tool names may have different prefixes depending on your coding agent. For example:
- Claude Code: `mcp__kapa__search_algorand_knowledge_sources`
- Other agents may use: `kapa_search_algorand_knowledge_sources`

The tool functionality is the same regardless of prefix.

### Documentation Search (Kapa)

| Tool                                      | Purpose                       |
| ----------------------------------------- | ----------------------------- |
| `kapa_search_algorand_knowledge_sources` | Search official Algorand docs |

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
| `kapa_search_algorand_knowledge_sources` | Use web search for "site:dev.algorand.co {query}"               |
| `github_get_file_contents`                | Use web search or browse GitHub directly                        |
| `github_search_code`                      | Use web search for "site:github.com algorandfoundation {query}" |

**To fix MCP configuration:**

1. **Check config exists**: Look for `.mcp.json` (Claude Code), `opencode.json` (OpenCode), or `.cursor/mcp.json` (Cursor)
2. **Verify server entries**: Config should include `kapa` and `github` MCP servers
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

## X402 Development

x402 is an HTTP-native payment protocol built on the HTTP 402 "Payment Required" status code. Three components work together: **Client** requests a protected resource, **Server** responds with 402 and structured payment requirements, and **Facilitator** verifies and settles the payment on-chain. The client signs a transaction, retries the request with a `PAYMENT-SIGNATURE` header, and the server forwards it to the facilitator for verification and settlement before granting access.

### Payment Flow

```
Client                  Resource Server           Facilitator           Algorand
  |                          |                        |                    |
  | 1. GET /api/data         |                        |                    |
  |------------------------->|                        |                    |
  | 2. 402 + requirements    |                        |                    |
  |<-------------------------|                        |                    |
  | 3. Build + sign txn      |                        |                    |
  | 4. GET + PAYMENT-SIGNATURE|                      |                    |
  |------------------------->| 5. verify(payload)     |                    |
  |                          |----------------------->| 6. simulate_group  |
  |                          |                        |------------------->|
  |                          |                        |<-------------------|
  |                          |<-----------------------| {isValid: true}    |
  |                          | 7. settle(payload)     |                    |
  |                          |----------------------->| 8. sign + send     |
  |                          |                        |------------------->|
  |                          |                        |<-------------------| txId
  |                          |<-----------------------|                    |
  | 9. 200 + data            |                        |                    |
  |<-------------------------|                        |                    |
```

### Building X402 Applications

1. **Pick language**: TypeScript or Python
2. **Load the skill**: `algorand-x402-typescript` or `algorand-x402-python`
3. **Choose components**: Client, server, facilitator, paywall — or a subset
4. **Follow the skill's SKILL.md** router to find reference files for your component

The skills contain everything needed: CAIP-2 network identifiers, package lists, signer protocols, environment variables, common errors, and complete code examples.

**Public facilitator URL:** `https://facilitator.goplausible.xyz`
