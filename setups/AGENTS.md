# AGENTS.md

## Overview

This project develops Algorand blockchain applications including smart contracts, frontend interfaces and x402 applications. When working here, always leverage the available skills and MCP tools before writing code—they provide canonical syntax, examples, and documentation that prevent errors and save time.

## Creating New Projects

Before initializing any AlgoKit project:

1. **Load the skill**: Use `create-project` skill for project setup guidance
2. **Run**: `algokit init -n <name> -t typescript --answer preset "Production" --defaults`

## Writing Smart Contracts

Before writing ANY Algorand contract code:

1. **Load the skill first**: Use `build-smart-contracts` skill
2. **Search docs**: Call `kapa_search_algorand_knowledge_sources` for concepts
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

x402 is an HTTP-native payment protocol built on the HTTP 402 "Payment Required" status code. Three components work together: **Client** requests a protected resource, **Server** responds with 402 and structured payment requirements, and **Facilitator** verifies and settles the payment on-chain. The client signs a transaction, retries the request with an `X-PAYMENT` header, and the server forwards it to the facilitator for verification and settlement before granting access.

Algorand (AVM) is a **first-class citizen** alongside EVM (Ethereum) and SVM (Solana) — never conditional, always registered unconditionally. It uses CAIP-2 network identifiers and supports fee abstraction (facilitator pays transaction fees), ASA payments (USDC, ALGO), atomic transaction groups, and 3.3-second finality.

### Payment Flow

```
Client                  Resource Server           Facilitator           Algorand
  |                          |                        |                    |
  | 1. GET /api/data         |                        |                    |
  |------------------------->|                        |                    |
  | 2. 402 + requirements    |                        |                    |
  |<-------------------------|                        |                    |
  | 3. Build + sign txn      |                        |                    |
  | 4. GET + X-PAYMENT header|                        |                    |
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

### CAIP-2 Network Identifiers

| Network            | Identifier                                               |
| ------------------ | -------------------------------------------------------- |
| Algorand Testnet   | `algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=` |
| Algorand Mainnet   | `algorand:wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=`  |

### X402 Components

**Client** — Wraps HTTP clients (fetch/axios/httpx/requests) to automatically handle 402 responses. Builds Algorand transaction groups using `ClientAvmSigner`, signs them, encodes as `X-PAYMENT` header, and retries the request.

**Resource Server** — Middleware for Express/Hono/Next.js/FastAPI/Flask that intercepts requests to protected routes. Returns 402 with `PaymentRequirements` (scheme, network, payTo, price, asset) when no payment header is present. Forwards valid payments to facilitator for verification and settlement.

**Facilitator** — On-chain payment processor implementing `FacilitatorAvmSigner` protocol: `simulate_group()` to verify transaction structure, `sign_group()` for fee abstraction (signs fee payer transactions), `send_group()` to submit atomic groups, and `confirm_transaction()` to wait for finality. Public facilitator: `https://facilitator.goplausible.xyz`

**Paywall** — Browser UI component (`@x402-avm/paywall`) for manual payment when automatic client payment isn't available. Renders a payment form and handles wallet interaction.

**Bazaar Extension** — Discovery extension (`@x402-avm/extensions` / `x402-avm[extensions]`) that registers facilitator and server capabilities for API cataloging. Clients can query available facilitators, their supported networks, and pricing through standardized endpoints.

### Signer Protocols (Core Architecture)

Protocol definitions live in the SDK; implementations are provided by users/examples:

| Protocol                | Role         | Key Methods                                                               |
| ----------------------- | ------------ | ------------------------------------------------------------------------- |
| `ClientAvmSigner`       | Client-side  | `address`, `sign_transactions(unsigned_txns, indexes_to_sign)`            |
| `FacilitatorAvmSigner`  | Facilitator  | `get_addresses`, `sign_transaction`, `sign_group`, `simulate_group`, `send_group`, `confirm_transaction` |

### Packages

**TypeScript** (npm):

| Package               | Purpose                              |
| --------------------- | ------------------------------------ |
| `@x402-avm/core`      | Base protocol (client, server, facilitator, types) |
| `@x402-avm/avm`       | Algorand mechanism + constants       |
| `@x402-avm/evm`       | Ethereum mechanism                   |
| `@x402-avm/svm`       | Solana mechanism                     |
| `@x402-avm/express`   | Express.js server middleware         |
| `@x402-avm/hono`      | Hono server middleware               |
| `@x402-avm/next`      | Next.js middleware (paymentProxy)    |
| `@x402-avm/fetch`     | Fetch API client wrapper             |
| `@x402-avm/axios`     | Axios client wrapper                 |
| `@x402-avm/paywall`   | Browser paywall UI                   |
| `@x402-avm/extensions`| Extensions (Bazaar discovery)        |

**Python** (pip) — single package `x402-avm` with extras:

| Install Extra          | Purpose                              |
| ---------------------- | ------------------------------------ |
| `x402-avm[avm]`        | Algorand mechanism + constants       |
| `x402-avm[evm]`        | Ethereum mechanism                   |
| `x402-avm[svm]`        | Solana mechanism                     |
| `x402-avm[fastapi]`    | FastAPI server middleware            |
| `x402-avm[flask]`      | Flask server middleware              |
| `x402-avm[httpx]`      | Async HTTP client (httpx)            |
| `x402-avm[requests]`   | Sync HTTP client (requests)          |
| `x402-avm[extensions]` | Extensions (Bazaar discovery)        |
| `x402-avm[all]`        | Everything                           |

### X402 Skills

**Educational:**

| Task                      | Skill                              |
| ------------------------- | ---------------------------------- |
| Teach x402 concepts       | `teach-algorand-x402`              |
| Explain x402 for Python   | `explain-algorand-x402-python`     |
| Explain x402 for TS       | `explain-algorand-x402-typescript` |

**TypeScript:**

| Task                      | Skill                                  |
| ------------------------- | -------------------------------------- |
| TS client (fetch/axios)   | `create-typescript-x402-client`        |
| TS server (Express/Hono)  | `create-typescript-x402-server`        |
| TS facilitator + Bazaar   | `create-typescript-x402-facilitator`   |
| TS paywall UI             | `create-typescript-x402-paywall`       |
| TS Next.js fullstack      | `create-typescript-x402-nextjs`        |
| TS core/AVM direct usage  | `use-typescript-x402-core-avm`         |

**Python:**

| Task                      | Skill                                  |
| ------------------------- | -------------------------------------- |
| Py client (httpx/requests)| `create-python-x402-client`            |
| Py server (FastAPI/Flask) | `create-python-x402-server`            |
| Py facilitator            | `create-python-x402-facilitator`       |
| Py facilitator + Bazaar   | `create-python-x402-facilitator-bazaar`|
| Py core/AVM direct usage  | `use-python-x402-core-avm`             |

### Building X402 Applications

1. **Understand**: Load `teach-algorand-x402` to explain the protocol, components, and payment flow
2. **Choose components**: Client, server, facilitator, paywall — or a subset
3. **Pick language**: TypeScript (`@x402-avm/*` packages) or Python (`x402-avm[extras]`)
4. **Load creation skill**: Use the appropriate skill for each component (see tables above)
5. **Implement signers**: `ClientAvmSigner` for clients, `FacilitatorAvmSigner` for facilitators — protocol definitions are in the SDK, implementations in your code
6. **Use core skills**: `use-typescript-x402-core-avm` or `use-python-x402-core-avm` for direct AVM integration beyond the HTTP wrappers
7. **Use explanation skills**: `explain-algorand-x402-typescript` or `explain-algorand-x402-python` to understand language-specific patterns

### Environment Variables

| Variable          | Purpose                                      |
| ----------------- | -------------------------------------------- |
| `AVM_PRIVATE_KEY` | Base64-encoded 64-byte key (32 seed + 32 pub)|
| `ALGOD_SERVER`    | Custom Algod node URL (optional, defaults to AlgoNode) |
| `ALGOD_TOKEN`     | Algod node API token (optional)              |
| `PAY_TO`          | Algorand address to receive payments (server)|
