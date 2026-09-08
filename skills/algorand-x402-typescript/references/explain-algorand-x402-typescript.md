# x402-avm for TypeScript Developers

Understand the @x402/* TypeScript package ecosystem, signer interfaces, registration patterns, and how to integrate Algorand payments into TypeScript applications.

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
2. Register AVM scheme via .register()
3. Use the component (fetch, middleware, verify/settle)
```

The `.register()` function is the bridge between the generic x402 core and Algorand-specific logic.

## How to Proceed

### Step 1: Install Packages

The package ecosystem is modular. Install only what you need:

```bash
# Core + AVM mechanism (always needed)
npm install @x402/core @x402/avm algosdk

# For a client application (pick one)
npm install @x402/fetch      # Fetch API wrapper
npm install @x402/axios      # Axios interceptor

# For a server application (pick one)
npm install @x402/express    # Express.js middleware
npm install @x402/hono       # Hono middleware
npm install @x402/next       # Next.js middleware

# For browser wallet integration (React; `useWallet` is exported from the -react package)
npm install @txnlab/use-wallet-react

# Optional
npm install @x402/paywall    # Browser paywall UI
npm install @x402/extensions # Protocol extensions
```

### Step 2: Understand the Package Structure

| Package | Role | Key Exports |
|---------|------|-------------|
| `@x402/core` | Base protocol | `x402Client`, `x402ResourceServer`, `x402Facilitator`, `HTTPFacilitatorClient` |
| `@x402/avm` | AVM mechanism | `ClientAvmSigner`, `FacilitatorAvmSigner`, constants, utilities |
| `@x402/express` | Express middleware | `paymentMiddleware`, `paymentMiddlewareFromConfig` |
| `@x402/hono` | Hono middleware | `paymentMiddleware`, `paymentMiddlewareFromConfig` |
| `@x402/next` | Next.js middleware | `paymentMiddleware` |
| `@x402/fetch` | Fetch client | `wrapFetch` |
| `@x402/axios` | Axios client | `wrapAxios` |
| `@x402/paywall` | Paywall UI | `PaywallProvider` |
| `@x402/extensions` | Extensions | Bazaar, custom schemes |

### Step 3: Implement a Signer

The signer is the only component that touches `algosdk` directly. The SDK defines the interface; you provide the implementation.

**For clients (browser with wallet):**
```typescript
import type { ClientAvmSigner } from "@x402/avm";
import { useWallet } from "@txnlab/use-wallet-react";

const { activeAccount, signTransactions } = useWallet();

const signer: ClientAvmSigner = {
  address: activeAccount!.address,
  signTransactions: async (txns, indexesToSign) => {
    return signTransactions(txns, indexesToSign);
  },
};
```

**For clients (server-side with private key):**

The simplest option is the built-in helper, which takes the base64-encoded 64-byte algosdk secret key (not a mnemonic):

```typescript
import { toClientAvmSigner } from "@x402/avm";

const signer = toClientAvmSigner(process.env.AVM_PRIVATE_KEY!); // base64 of 64-byte secret key
```

Or hand-roll one with `algosdk`:

```typescript
import type { ClientAvmSigner } from "@x402/avm";
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

Use the built-in helper. It takes the base64-encoded 64-byte algosdk secret key (not a mnemonic) and returns a `FacilitatorAvmSigner` backed by `@algorandfoundation/algokit-utils` algod clients for TestNet and MainNet:

```typescript
import { toFacilitatorAvmSigner } from "@x402/avm";

const signer = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!, {
  testnetUrl: "https://testnet-api.algonode.cloud", // optional overrides
  // mainnetUrl, algodToken
});
```

A hand-rolled `FacilitatorAvmSigner` must return an `AlgodClient` from `@algorandfoundation/algokit-utils/algod-client` (e.g. `AlgorandClient.testNet().client.algod`) from `getAlgodClient` — an `algosdk.Algodv2` instance does not type-check.

### Step 4: Register the AVM Scheme

Registration connects the AVM mechanism to the core component. Each role has its own registration function from a different subpath (all three classes are named `ExactAvmScheme`, so import only the one for your role in a given module):

```typescript
// Client
import { ExactAvmScheme } from "@x402/avm/exact/client";
client.register("algorand:*", new ExactAvmScheme(signer));
```

```typescript
// Server
import { ExactAvmScheme } from "@x402/avm/exact/server";
server.register("algorand:*", new ExactAvmScheme());
```

```typescript
// Facilitator
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";
facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(signer));
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
  normalizeAlgorandNetwork,
} from "@x402/avm";
```

There is no algod client factory in `@x402/avm`; use algokit-utils `AlgorandClient.testNet()` (or pass `algodUrl` in the `ExactAvmScheme` client config). Only CAIP-2 network identifiers are supported — `normalizeAlgorandNetwork` throws on v1 names such as `"algorand-testnet"`.

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
import type { Network } from "@x402/core/types"; // `${string}:${string}`
import type { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
// SimulateResponse / PendingTransactionResponse are the algokit-utils algod models

interface FacilitatorAvmSigner {
  getAddresses(): readonly string[];
  signTransaction(txn: Uint8Array, senderAddress: string): Promise<Uint8Array>;
  getAlgodClient(network: Network): AlgodClient;
  simulateTransactions(txns: Uint8Array[], network: Network): Promise<SimulateResponse>;
  sendTransactions(signedTxns: Uint8Array[], network: Network): Promise<string>;
  waitForConfirmation(txId: string, network: Network, waitRounds?: number): Promise<PendingTransactionResponse>;
}
```

- `getAddresses`: Returns all fee payer addresses the facilitator manages
- `signTransaction`: Signs a single transaction for the given sender address
- `getAlgodClient`: Returns an algokit-utils `AlgodClient` (not `algosdk.Algodv2`) for the specified network
- `simulateTransactions`: Simulates a transaction group before submission
- `sendTransactions`: Submits signed transactions to the network, returns txId
- `waitForConfirmation`: Waits for transaction confirmation

## Important Rules / Guidelines

1. **Import paths matter** -- `.register()` comes from different subpaths for client, server, and facilitator
2. **Signer is the boundary** -- only signer implementations import `algosdk`. The SDK core never touches `algosdk` directly
3. **Raw bytes everywhere** -- the SDK passes `Uint8Array` msgpack bytes. No base64 conversion needed within the SDK (unlike Python)
4. **Registration is unconditional** -- never wrap `.register()` in `if (env.AVM_*)` checks
5. **Type imports** -- use `import type { ... }` for interfaces to avoid bundling issues
6. **Network constants** -- always import `ALGORAND_TESTNET_CAIP2` / `ALGORAND_MAINNET_CAIP2` from `@x402/avm` in SDK code

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot find module '@x402/avm/exact/client'` | Package not installed or wrong version | Run `npm install @x402/avm` |
| `signTransactions is not a function` | Signer object missing method | Ensure signer implements `ClientAvmSigner` interface |
| `Invalid key length: expected 64` | Wrong private key format | Key must be 64 bytes Base64-encoded |
| `No scheme registered for network` | AVM scheme not registered | Call `.register()` before use |
| `getAddresses is not a function` | Wrong signer type | Use `FacilitatorAvmSigner` for facilitators, `ClientAvmSigner` for clients |
| `Simulation failed` | Transaction would fail on-chain | Check balances, ASA opt-in, correct network |
| `global is not defined` | algosdk references `global` in browser | Add `define: { global: 'globalThis' }` to vite.config.ts |
| Type errors in wallet integration | `@txnlab/use-wallet` version mismatch | Ensure compatible version of `@txnlab/use-wallet` |

## References / Further Reading

- [explain-algorand-x402-typescript-reference.md](./explain-algorand-x402-typescript-reference.md) - Detailed package API reference
- [explain-algorand-x402-typescript-examples.md](./explain-algorand-x402-typescript-examples.md) - Complete TypeScript code examples
- [@x402/core on npm](https://www.npmjs.com/package/@x402/core)
- [@x402/avm on npm](https://www.npmjs.com/package/@x402/avm)
- [GoPlausible x402-avm Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [GoPlausible x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [@txnlab/use-wallet Documentation](https://txnlab.gitbook.io/use-wallet)
