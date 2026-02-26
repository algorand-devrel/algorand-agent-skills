# AGENTS.md

## Overview

This project develops Algorand blockchain applications including smart contracts, frontend interfaces and x402 applications. When working here, always leverage the available skills and MCP tools before writing code—they provide canonical syntax, examples, and documentation that prevent errors and save time.

## Creating New Projects

Before initializing any AlgoKit project:

1. **Load the skill**: Use `algorand-development` skill (create-project topic)
2. **For TypeScript**: `algokit init -n <name> -t typescript --answer preset_name production --defaults`
3. **For Python**: `algokit init -n <name> -t python --answer preset_name production --defaults`

## Writing Smart Contracts

Before writing ANY Algorand contract code:

1. **Load the skill first**: Use `algorand-typescript` or `algorand-python` skill (build-smart-contracts topic)
2. **Search docs**: Call `kapa_search_algorand_knowledge_sources` for concepts
3. **Get examples**: Use `github_get_file_contents` from:
   - `algorandfoundation/devportal-code-examples`
   - `algorandfoundation/puya-ts` (TypeScript) or `algorandfoundation/puya` (Python)
4. **Write code** following skill guidance
5. **Build/test**: `algokit project run build && algokit project run test`

## Deploying & Calling Contracts

Use the **CLI and generated typed clients** for deployment and interaction.

### Workflow

1. **Load the skill**: Use `algorand-typescript` skill (call-smart-contracts topic) or `algorand-python` skill
2. **Start localnet**: `algokit localnet start`
3. **Build contracts**: `algokit project run build`
4. **Deploy to localnet**: `algokit project deploy localnet`
   - This runs `deploy-config.ts` which uses the generated client
   - Handles idempotent deployment (safe to re-run)
   - Note the App ID from the deployment output

### Contract Interaction

After deployment, interact with contracts using the generated typed client:

1. **Write interaction scripts** in `deploy-config.ts` or separate scripts
2. **Use the typed client** generated from the ARC-56 app spec
3. **Run scripts**: `npx tsx scripts/call-contract.ts`

See the `algorand-typescript` skill (call-smart-contracts topic) for detailed patterns and examples.

## Building React Frontends

Before building a React frontend that interacts with Algorand contracts:

1. **Load the skill**: Use `algorand-typescript` skill (deploy-react-frontend topic)
2. **Prerequisites**: Deployed contract with known App ID, ARC-56 app spec
3. **Generate typed client**: `algokit generate client MyContract.arc56.json --output src/contracts/MyContractClient.ts`
4. **Install deps**: `npm install @algorandfoundation/algokit-utils @txnlab/use-wallet-react algosdk`
5. **Follow the "signer handoff" pattern**:
   - Set up `WalletProvider` with `@txnlab/use-wallet-react`
   - Get `transactionSigner` from `useWallet()` hook
   - Register signer: `algorand.setSigner(activeAddress, transactionSigner)`
   - Create typed client with `defaultSender: activeAddress`

## Available Skills

Three aggregated skills cover all core Algorand development. Each skill has a single `SKILL.md` router plus a `references/` folder with all implementation guides and API references.

| Task                              | Skill                    |
| --------------------------------- | ------------------------ |
| CLI, examples, general workflows  | `algorand-development`   |
| TypeScript contracts & tools      | `algorand-typescript`    |
| Python contracts & tools          | `algorand-python`        |

**Skill structure:**
```
algorand-development/           algorand-typescript/            algorand-python/
├── SKILL.md  (router)          ├── SKILL.md  (router)          ├── SKILL.md  (router)
└── references/                 └── references/                 └── references/
    ├── use-algokit-cli.md          ├── algorand-typescript-         ├── build-smart-contracts-
    ├── search-algorand-                syntax.md                        decorators.md
    │   examples.md                 ├── test-smart-contracts.md      ├── build-smart-contracts-
    ├── create-project.md           ├── call-smart-contracts.md          storage.md
    ├── build-smart-contracts.md    ├── deploy-react-frontend.md     ├── use-algokit-utils-
    ├── implement-arc-standards.md  ├── use-algokit-utils.md             reference.md
    └── troubleshoot-errors.md      └── ...                          └── ...
```

**algorand-development topics:** `use-algokit-cli`, `search-algorand-examples`, `create-project`, `build-smart-contracts`, `implement-arc-standards`, `troubleshoot-errors`

**algorand-typescript topics:** `algorand-typescript-syntax`, `algorand-ts-migration`, `test-smart-contracts`, `call-smart-contracts`, `deploy-react-frontend`, `create-project`, `build-smart-contracts`, `use-algokit-utils`, `implement-arc-standards`, `troubleshoot-errors`

**algorand-python topics:** `create-project`, `build-smart-contracts`, `use-algokit-utils`, `implement-arc-standards`, `troubleshoot-errors`

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

**Detailed flow:**
1. Client makes `GET /api/data` — server returns `402` with `PaymentRequirements`
2. `PaymentRequirements` contain: scheme (`exact`), network (CAIP-2), asset (ASA ID), amount (atomic units), payTo (Algorand address), extra (feePayer, decimals)
3. Client builds a transaction group, signs its own transactions, encodes as base64
4. Client retries with `X-PAYMENT` header containing `{ x402Version, scheme, network, payload: { paymentGroup, paymentIndex } }`
5. Server forwards to facilitator — facilitator verifies, simulates, settles
6. Server returns 200 with the protected resource

### CAIP-2 Network Identifiers

x402 V2 uses [CAIP-2](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md) identifiers based on genesis hashes:

| Network            | Identifier                                               |
| ------------------ | -------------------------------------------------------- |
| Algorand Testnet   | `algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=` |
| Algorand Mainnet   | `algorand:wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=`  |

V1 legacy identifiers (`algorand-mainnet`, `algorand-testnet`) are still supported via automatic mapping.

### X402 Components

**Client** — Wraps HTTP clients (fetch/axios/httpx/requests) to automatically handle 402 responses. Builds Algorand transaction groups using `ClientAvmSigner`, signs them, encodes as `X-PAYMENT` header, and retries the request.

**Resource Server** — Middleware for Express/Hono/Next.js/FastAPI/Flask that intercepts requests to protected routes. Returns 402 with `PaymentRequirements` (scheme, network, payTo, price, asset) when no payment header is present. Forwards valid payments to facilitator for verification and settlement.

**Facilitator** — On-chain payment processor implementing `FacilitatorAvmSigner` protocol: `simulate_group()` to verify transaction structure, `sign_group()` for fee abstraction (signs fee payer transactions), `send_group()` to submit atomic groups, and `confirm_transaction()` to wait for finality. Public facilitator: `https://facilitator.goplausible.xyz`

**Paywall** — Browser UI component (`@x402-avm/paywall`) for manual payment when automatic client payment isn't available. Renders a payment form and handles wallet interaction.

**Bazaar Extension** — Discovery extension (`@x402-avm/extensions` / `x402-avm[extensions]`) that registers facilitator and server capabilities for API cataloging. Clients can query available facilitators, their supported networks, and pricing through standardized endpoints.

### Algorand-Specific Features

**Fee Abstraction** — Algorand's atomic transaction groups enable fee abstraction. The facilitator pays transaction fees on behalf of the client through a 2-transaction group:
1. Transaction 0 (fee payer): Self-payment by facilitator, amount=0, fee covers both txns
2. Transaction 1 (payment): ASA transfer from client to payTo, fee=0
Both transactions share an atomic group ID — they execute all-or-nothing.

**ASA Support:**

| Asset | Testnet ASA ID | Mainnet ASA ID | Decimals |
|-------|---------------|----------------|----------|
| USDC  | `10458941`    | `31566704`     | 6        |
| ALGO  | `0` (native)  | `0` (native)   | 6        |

**Atomic Groups** — Payment groups can include up to 16 transactions, enabling composability — additional smart contract calls or opt-ins alongside the payment.

**Fast Finality** — Algorand transactions finalize in ~3.3 seconds with no reorgs or rollbacks.

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

### Important Rules

1. **AVM is always first-class** — never wrap AVM registration in conditional checks
2. **Use CAIP-2 identifiers** — `algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=` for testnet
3. **Signer separation** — protocol definitions live in the SDK, implementations live in examples
4. **Raw bytes protocol** — the SDK passes raw msgpack bytes between methods; algosdk conversions happen at boundaries
5. **Private key format** — `AVM_PRIVATE_KEY` is Base64-encoded, 64 bytes (32-byte seed + 32-byte pubkey)
6. **Address derivation** — `encode_address(secret_key[32:])` in both Python and TypeScript

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `402 Payment Required` with no payment options | AVM scheme not registered on server | Call `registerExactAvmScheme(server)` |
| `Invalid network` | Using V1 identifier where V2 expected | Use CAIP-2 format: `algorand:SGO1...` |
| `Simulation failed` | Transaction would fail on-chain | Check balances, ASA opt-in, group structure |
| `Invalid key length` | Wrong private key format | Key must be 64 bytes, Base64-encoded |
| `No signer for address` | Facilitator does not manage that address | Check `getAddresses()` returns the fee payer |
| `Group ID mismatch` | Transactions not properly grouped | Use `algosdk.assignGroupID()` before encoding |
| `Amount mismatch` | Payment amount differs from requirements | Use atomic units matching `paymentRequirements.amount` |

### X402 Skills

Two aggregated skills cover all x402 development. Each skill has a single `SKILL.md` that acts as a router, plus a `references/` folder containing all implementation guides, API references, and code examples as named files.

| Task                        | Skill                      |
| --------------------------- | -------------------------- |
| TypeScript x402 development | `algorand-x402-typescript` |
| Python x402 development     | `algorand-x402-python`     |

**Skill structure:**
```
algorand-x402-typescript/          algorand-x402-python/
├── SKILL.md  (router)             ├── SKILL.md  (router)
└── references/                    └── references/
    ├── {topic}.md                     ├── {topic}.md
    ├── {topic}-reference.md           ├── {topic}-reference.md
    └── {topic}-examples.md            └── {topic}-examples.md
```

Each topic has three reference files:
- **`{topic}.md`** — Step-by-step implementation guide (formerly the sub-skill's SKILL.md)
- **`{topic}-reference.md`** — API details and type signatures
- **`{topic}-examples.md`** — Complete, runnable code samples

**TypeScript topics:** `explain-algorand-x402-typescript`, `create-typescript-x402-client`, `create-typescript-x402-server`, `create-typescript-x402-nextjs`, `create-typescript-x402-facilitator`, `create-typescript-x402-paywall`, `use-typescript-x402-core-avm`

**Python topics:** `explain-algorand-x402-python`, `create-python-x402-client`, `create-python-x402-server`, `create-python-x402-facilitator`, `use-python-x402-core-avm`

### Building X402 Applications

1. **Pick language**: TypeScript (`@x402-avm/*` packages) or Python (`x402-avm[extras]`)
2. **Load the parent skill**: `algorand-x402-typescript` or `algorand-x402-python`
3. **Choose components**: Client, server, facilitator, paywall — or a subset
4. **Read the SKILL.md** router to find the right reference files for your component
5. **Implement signers**: `ClientAvmSigner` for clients, `FacilitatorAvmSigner` for facilitators — protocol definitions are in the SDK, implementations in your code

### x402 Algorand Environment Variables

| Variable          | Purpose                                      |
| ----------------- | -------------------------------------------- |
| `AVM_PRIVATE_KEY` | Base64-encoded 64-byte key (32 seed + 32 pub)|
| `ALGOD_SERVER`    | Custom Algod node URL (optional, defaults to AlgoNode) |
| `ALGOD_TOKEN`     | Algod node API token (optional)              |
| `PAY_TO`          | Algorand address to receive payments (server)|

### External Algorand x402 Resources

- [GoPlausible x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/README.md)
- [GoPlausible x402-avm Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [Coinbase x402 Protocol](https://github.com/coinbase/x402)
- [CAIP-2 Specification](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md)
