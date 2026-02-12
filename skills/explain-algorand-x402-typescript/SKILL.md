---
name: explain-algorand-x402-typescript
description: Explain x402-avm for TypeScript/JavaScript developers. Use when explaining @x402-avm/* package structure, signer interfaces (ClientAvmSigner, FacilitatorAvmSigner), registration patterns (registerExactAvmScheme), builder patterns, constants, utilities, and TypeScript-specific integration patterns. Strong triggers include "how do I use @x402-avm", "explain the TypeScript packages", "what is ClientAvmSigner", "what is FacilitatorAvmSigner", "how to register AVM scheme", "TypeScript x402 signer", "x402 avm package structure", "how does @x402-avm/avm work", "@x402-avm/core imports".
---

# x402-avm for TypeScript Developers

Understand the @x402-avm/* TypeScript package ecosystem, signer interfaces, registration patterns, and how to integrate Algorand payments into TypeScript applications.

## Prerequisites

Before using x402-avm in TypeScript:

1. **Node.js 18+** or a modern browser runtime
2. **TypeScript 5+** recommended (JavaScript also works)
3. **npm or yarn** for package management
4. **algosdk** -- the Algorand JavaScript SDK (peer dependency for signer implementations)

## Core Workflow: Register, Configure, Use

Every x402-avm TypeScript application follows the same pattern:

```
1. Create component instance (client/server/facilitator)
2. Register AVM scheme via registerExactAvmScheme()
3. Use the component (fetch, middleware, verify/settle)
```

The `registerExactAvmScheme` function is the bridge between the generic x402 core and Algorand-specific logic.

## How to Proceed

### Step 1: Install Packages

The package ecosystem is modular. Install only what you need:

```bash
# Core + AVM mechanism (always needed)
npm install @x402-avm/core @x402-avm/avm algosdk

# For a client application (pick one)
npm install @x402-avm/fetch      # Fetch API wrapper
npm install @x402-avm/axios      # Axios interceptor

# For a server application (pick one)
npm install @x402-avm/express    # Express.js middleware
npm install @x402-avm/hono       # Hono middleware
npm install @x402-avm/next       # Next.js middleware

# For browser wallet integration
npm install @txnlab/use-wallet

# Optional
npm install @x402-avm/paywall    # Browser paywall UI
npm install @x402-avm/extensions # Protocol extensions
```

### Step 2: Understand the Package Structure

| Package | Role | Key Exports |
|---------|------|-------------|
| `@x402-avm/core` | Base protocol | `x402Client`, `x402ResourceServer`, `x402Facilitator`, `HTTPFacilitatorClient` |
| `@x402-avm/avm` | AVM mechanism | `ClientAvmSigner`, `FacilitatorAvmSigner`, constants, utilities |
| `@x402-avm/express` | Express middleware | `paymentMiddleware`, `paymentMiddlewareFromConfig` |
| `@x402-avm/hono` | Hono middleware | `paymentMiddleware`, `paymentMiddlewareFromConfig` |
| `@x402-avm/next` | Next.js middleware | `paymentMiddleware` |
| `@x402-avm/fetch` | Fetch client | `wrapFetch` |
| `@x402-avm/axios` | Axios client | `wrapAxios` |
| `@x402-avm/paywall` | Paywall UI | `PaywallProvider` |
| `@x402-avm/extensions` | Extensions | Bazaar, custom schemes |

### Step 3: Implement a Signer

The signer is the only component that touches `algosdk` directly. The SDK defines the interface; you provide the implementation.

**For clients (browser with wallet):**
```typescript
import type { ClientAvmSigner } from "@x402-avm/avm";
import { useWallet } from "@txnlab/use-wallet";

const { activeAccount, signTransactions } = useWallet();

const signer: ClientAvmSigner = {
  address: activeAccount.address,
  signTransactions: async (txns, indexesToSign) => {
    return signTransactions(txns, indexesToSign);
  },
};
```

**For clients (server-side with private key):**
```typescript
import type { ClientAvmSigner } from "@x402-avm/avm";
import algosdk from "algosdk";

const secretKey = Buffer.from(process.env.AVM_PRIVATE_KEY!, "base64");
const address = algosdk.encodeAddress(secretKey.slice(32));

const signer: ClientAvmSigner = {
  address,
  signTransactions: async (txns, indexesToSign) => {
    return txns.map((txn, i) => {
      if (indexesToSign && !indexesToSign.includes(i)) return null;
      const decoded = algosdk.decodeUnsignedTransaction(txn);
      return algosdk.signTransaction(decoded, secretKey).blob;
    });
  },
};
```

**For facilitators:**
```typescript
import type { FacilitatorAvmSigner } from "@x402-avm/avm";
import algosdk from "algosdk";

const secretKey = Buffer.from(process.env.AVM_PRIVATE_KEY!, "base64");
const address = algosdk.encodeAddress(secretKey.slice(32));
const algodClient = new algosdk.Algodv2("", "https://testnet-api.algonode.cloud", "");

const signer: FacilitatorAvmSigner = {
  getAddresses: () => [address],
  signTransaction: async (txn, _addr) => {
    const decoded = algosdk.decodeUnsignedTransaction(txn);
    return algosdk.signTransaction(decoded, secretKey).blob;
  },
  getAlgodClient: () => algodClient,
  simulateTransactions: async (txns) => { /* ... */ },
  sendTransactions: async (signedTxns) => { /* ... */ },
  waitForConfirmation: async (txId, _net, rounds) => { /* ... */ },
};
```

### Step 4: Register the AVM Scheme

Registration connects the AVM mechanism to the core component. Each role has its own registration function from a different subpath:

```typescript
// Client
import { registerExactAvmScheme } from "@x402-avm/avm/exact/client";
registerExactAvmScheme(client, { signer });

// Server
import { registerExactAvmScheme } from "@x402-avm/avm/exact/server";
registerExactAvmScheme(server);

// Facilitator
import { registerExactAvmScheme } from "@x402-avm/avm/exact/facilitator";
registerExactAvmScheme(facilitator, { signer, networks: ALGORAND_TESTNET_CAIP2 });
```

### Step 5: Use Constants and Utilities

```typescript
import {
  ALGORAND_TESTNET_CAIP2,
  ALGORAND_MAINNET_CAIP2,
  USDC_TESTNET_ASA_ID,
  USDC_MAINNET_ASA_ID,
  isAlgorandNetwork,
  isValidAlgorandAddress,
  convertToTokenAmount,
  createAlgodClient,
} from "@x402-avm/avm";
```

## Signer Interfaces

### ClientAvmSigner

```typescript
interface ClientAvmSigner {
  address: string;
  signTransactions(
    txns: Uint8Array[],
    indexesToSign?: number[],
  ): Promise<(Uint8Array | null)[]>;
}
```

- `address`: The 58-character Algorand address of the payer
- `signTransactions`: Signs one or more transactions. Returns `null` for transactions the client should not sign (e.g., fee payer transactions)
- `txns`: Array of unsigned transactions as raw msgpack `Uint8Array`
- `indexesToSign`: Optional array of indexes to sign. If not provided, sign all

This interface is directly compatible with `@txnlab/use-wallet`'s `signTransactions`.

### FacilitatorAvmSigner

```typescript
interface FacilitatorAvmSigner {
  getAddresses(): readonly string[];
  signTransaction(txn: Uint8Array, senderAddress: string): Promise<Uint8Array>;
  getAlgodClient(network: Network): unknown;
  simulateTransactions(txns: Uint8Array[], network: Network): Promise<unknown>;
  sendTransactions(signedTxns: Uint8Array[], network: Network): Promise<string>;
  waitForConfirmation(txId: string, network: Network, waitRounds?: number): Promise<unknown>;
}
```

- `getAddresses`: Returns all fee payer addresses the facilitator manages
- `signTransaction`: Signs a single transaction for the given sender address
- `getAlgodClient`: Returns an Algod client for the specified network
- `simulateTransactions`: Simulates a transaction group before submission
- `sendTransactions`: Submits signed transactions to the network, returns txId
- `waitForConfirmation`: Waits for transaction confirmation

## Important Rules / Guidelines

1. **Import paths matter** -- `registerExactAvmScheme` comes from different subpaths for client, server, and facilitator
2. **Signer is the boundary** -- only signer implementations import `algosdk`. The SDK core never touches `algosdk` directly
3. **Raw bytes everywhere** -- the SDK passes `Uint8Array` msgpack bytes. No base64 conversion needed within the SDK (unlike Python)
4. **Registration is unconditional** -- never wrap `registerExactAvmScheme()` in `if (env.AVM_*)` checks
5. **Type imports** -- use `import type { ... }` for interfaces to avoid bundling issues
6. **Network constants** -- always import `ALGORAND_TESTNET_CAIP2` / `ALGORAND_MAINNET_CAIP2` from `@x402-avm/avm` in SDK code

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot find module '@x402-avm/avm/exact/client'` | Package not installed or wrong version | Run `npm install @x402-avm/avm` |
| `signTransactions is not a function` | Signer object missing method | Ensure signer implements `ClientAvmSigner` interface |
| `Invalid key length: expected 64` | Wrong private key format | Key must be 64 bytes Base64-encoded |
| `No scheme registered for network` | AVM scheme not registered | Call `registerExactAvmScheme()` before use |
| `getAddresses is not a function` | Wrong signer type | Use `FacilitatorAvmSigner` for facilitators, `ClientAvmSigner` for clients |
| `Simulation failed` | Transaction would fail on-chain | Check balances, ASA opt-in, correct network |
| `global is not defined` | algosdk references `global` in browser | Add `define: { global: 'globalThis' }` to vite.config.ts |
| Type errors in wallet integration | `@txnlab/use-wallet` version mismatch | Ensure compatible version of `@txnlab/use-wallet` |

## References / Further Reading

- [REFERENCE.md](./references/REFERENCE.md) - Detailed package API reference
- [EXAMPLES.md](./references/EXAMPLES.md) - Complete TypeScript code examples
- [@x402-avm/core on npm](https://www.npmjs.com/package/@x402-avm/core)
- [@x402-avm/avm on npm](https://www.npmjs.com/package/@x402-avm/avm)
- [GoPlausible x402-avm Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [GoPlausible x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [@txnlab/use-wallet Documentation](https://txnlab.gitbook.io/use-wallet)
