# Creating x402 Facilitator Services

Build facilitator services that verify payment transactions are valid, settle them on-chain, and optionally catalog discovered resources via the Bazaar extension.

## Prerequisites

Before using this skill, ensure:

1. **Node.js with TypeScript** support
2. **An Algorand account with ALGO** for covering transaction fees during settlement
3. **@x402/avm** installed -- its `toFacilitatorAvmSigner` helper handles transaction signing, simulation, and submission (via `@algorandfoundation/algokit-utils`, a transitive dependency of `@x402/avm`)

## Core Workflow: What a Facilitator Does

A facilitator is the trusted intermediary between a resource server and the blockchain. It performs two operations:

1. **Verify** -- Confirms that a payment transaction group is valid (correct amounts, recipients, signatures, timing) without submitting to the network
2. **Settle** -- Submits the verified transaction group to the Algorand network, co-signing the fee-payer transaction

```
Client                    Resource Server              Facilitator              Algorand
  |                            |                            |                      |
  |--- Request + Payment ----->|                            |                      |
  |                            |--- Verify(payload) ------->|                      |
  |                            |<-- { isValid: true } ------|                      |
  |                            |--- Settle(payload) ------->|                      |
  |                            |                            |--- Sign fee txn ---->|
  |                            |                            |--- Send group ------>|
  |                            |                            |<-- Confirmation -----|
  |                            |<-- { success, transaction }|                      |
  |<--- 200 + Content ---------|                            |                      |
```

## How to Proceed

### Step 1: Install Dependencies

```bash
npm install @x402/core @x402/avm express
```

`@algorandfoundation/algokit-utils` is pulled in as a transitive dependency of `@x402/avm`; `algosdk` is not needed for the facilitator.

For Bazaar discovery extension:
```bash
npm install @x402/extensions
```

### Step 2: Create the FacilitatorAvmSigner

The `FacilitatorAvmSigner` interface bridges the facilitator to the Algorand blockchain. It handles signing, simulation, submission, and confirmation. Use the `toFacilitatorAvmSigner` helper from `@x402/avm` rather than hand-rolling one:

```typescript
import { toFacilitatorAvmSigner } from "@x402/avm";

// AVM_PRIVATE_KEY: Base64 of the 64-byte algosdk secret key (seed || pubkey). Mnemonics are not accepted.
const facilitatorSigner = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!, {
  testnetUrl: process.env.ALGOD_TESTNET_URL, // optional; defaults to https://testnet-api.algonode.cloud
  // mainnetUrl: process.env.ALGOD_MAINNET_URL,
  // algodToken: process.env.ALGOD_TOKEN,
});
```

### Step 3: Create and Register the Facilitator

```typescript
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const facilitator = new x402Facilitator();

facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(facilitatorSigner));
```

### Step 4: Create the Express.js Server

```typescript
import express from "express";

const app = express();
app.use(express.json());

app.get("/supported", (_req, res) => {
  res.json(facilitator.getSupported());
});

app.post("/verify", async (req, res) => {
  try {
    const { paymentPayload, paymentRequirements } = req.body;
    const result = await facilitator.verify(paymentPayload, paymentRequirements);
    res.json(result);
  } catch (error) {
    res.status(400).json({ isValid: false, invalidReason: "invalid_request", invalidMessage: String(error) });
  }
});

app.post("/settle", async (req, res) => {
  try {
    const { paymentPayload, paymentRequirements } = req.body;
    const result = await facilitator.settle(paymentPayload, paymentRequirements);
    res.json(result);
  } catch (error) {
    res.status(400).json({ success: false, errorReason: "settle_failed", errorMessage: String(error) });
  }
});

app.listen(4000, () => console.log("Facilitator running on :4000"));
```

### Step 5: Add Bazaar Discovery Extension (Optional)

The Bazaar extension enables automatic cataloging of x402-protected resources. When resource servers declare discovery metadata, the facilitator can index and serve a discovery API:

**On the resource server side -- declare discovery info:**

```typescript
import { declareDiscoveryExtension } from "@x402/extensions";

const weatherDiscovery = declareDiscoveryExtension({
  input: { city: "San Francisco", units: "metric" },
  inputSchema: {
    properties: {
      city: { type: "string" },
      units: { type: "string", enum: ["metric", "imperial"] },
    },
    required: ["city"],
  },
  output: {
    example: { temperature: 18.5, condition: "Partly Cloudy", humidity: 65 },
  },
});
```

**On the facilitator side -- extract and catalog:**

```typescript
import { extractDiscoveryInfo, type DiscoveredResource } from "@x402/extensions";

facilitator.onAfterSettle(async (context) => {
  if (context.result.success) {
    const discovered = extractDiscoveryInfo(
      context.paymentPayload,
      context.requirements,
    );

    if (discovered) {
      // DiscoveredResource is a union (HTTP | MCP); `method` only exists on the HTTP variant
      const method = "method" in discovered ? discovered.method : undefined;
      console.log("Cataloged:", discovered.resourceUrl, method);
      // Store in database for the discovery API
    }
  }
});
```

### Step 6: Add Lifecycle Hooks (Optional)

```typescript
facilitator.onBeforeVerify(async (context) => {
  console.log(`Verifying ${context.requirements.scheme} payment on ${context.requirements.network}`);
});

facilitator.onAfterSettle(async (context) => {
  if (context.result.success) {
    console.log(`Settled: ${context.result.transaction}`);
  }
});
```

## Important Rules / Guidelines

1. **Facilitator needs ALGO** -- The facilitator address must have ALGO to pay transaction fees during settlement
2. **Private key security** -- Store `AVM_PRIVATE_KEY` securely. The facilitator co-signs the fee-payer transaction in each group
3. **Use the signer helper** -- `toFacilitatorAvmSigner()` already handles simulation of mixed signed/unsigned groups (`allowEmptySignatures`), concatenated submission, and confirmation. Only implement `FacilitatorAvmSigner` yourself if you need a custom key store (see the reference)
4. **Key format** -- `AVM_PRIVATE_KEY` must be the Base64 of the 64-byte secret key; a mnemonic is rejected with `AVM private key must be a Base64-encoded 64-byte key`
5. **Network registration** -- Use `ALGORAND_TESTNET_CAIP2` or `ALGORAND_MAINNET_CAIP2` constants, not string literals in SDK code
6. **Bazaar is optional** -- The Bazaar discovery extension adds cataloging capability but is not required for basic facilitator operation

## FacilitatorAvmSigner Interface

This is what `toFacilitatorAvmSigner()` returns. `Network` is `` `${string}:${string}` `` from `@x402/core/types`; the algod client and response models come from `@algorandfoundation/algokit-utils`, not `algosdk`.

```typescript
import type { Network } from "@x402/core/types";
import type {
  AlgodClient,
  SimulateResponse,
  PendingTransactionResponse,
} from "@algorandfoundation/algokit-utils/algod-client";

interface FacilitatorAvmSigner {
  /** Returns the list of addresses this signer controls */
  getAddresses(): readonly string[];

  /** Sign a single transaction for the given sender address */
  signTransaction(txn: Uint8Array, senderAddress: string): Promise<Uint8Array>;

  /** Get an algokit-utils AlgodClient for the specified network */
  getAlgodClient(network: Network): AlgodClient;

  /** Simulate a transaction group (for verification without submission) */
  simulateTransactions(txns: Uint8Array[], network: Network): Promise<SimulateResponse>;

  /** Send signed transactions to the network */
  sendTransactions(signedTxns: Uint8Array[], network: Network): Promise<string>;

  /** Wait for a transaction to be confirmed */
  waitForConfirmation(
    txId: string,
    network: Network,
    waitRounds?: number,
  ): Promise<PendingTransactionResponse>;
}
```

## Bazaar Discovery Architecture

```
Resource Server                        Facilitator                    Client
     |                                      |                           |
     |-- declareDiscoveryExtension() ------>|                           |
     |   (extensions in PaymentRequired)    |                           |
     |                                      |                           |
     |                  Client pays ------->|                           |
     |                                      |-- extractDiscoveryInfo()  |
     |                                      |   catalogs resource       |
     |                                      |                           |
     |                                      |<--- /discovery/resources -|
     |                                      |---> list of resources --->|
```

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `AVM private key must be a Base64-encoded 64-byte key` | `AVM_PRIVATE_KEY` missing, a mnemonic, or wrong format | Ensure Base64-encoded 64-byte key (seed + pubkey) |
| Simulation fails in a custom signer | Mixed signed/unsigned transactions | Use `toFacilitatorAvmSigner()`, which simulates with `allowEmptySignatures: true` |
| Signer does not type-check | Hand-rolled signer built on `algosdk.Algodv2` | `getAlgodClient` must return an algokit-utils `AlgodClient`; prefer `toFacilitatorAvmSigner()` |
| Settlement times out | Network congestion or low fee | Increase `waitRounds` parameter |
| `No scheme registered` | `.register()` not called | Register before handling requests |
| Discovery not extracted | Extensions not passed through payload | Ensure resource server includes extensions in PaymentRequired |

## References / Further Reading

- [create-typescript-x402-facilitator-reference.md](./create-typescript-x402-facilitator-reference.md) - Detailed API reference
- [create-typescript-x402-facilitator-examples.md](./create-typescript-x402-facilitator-examples.md) - Complete code examples
- [x402-avm Examples Repository](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
