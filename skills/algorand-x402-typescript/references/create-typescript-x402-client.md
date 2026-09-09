# Creating x402 HTTP Clients (Fetch and Axios)

Build HTTP clients that automatically detect `402 Payment Required` responses, sign Algorand transactions, and retry requests with payment proof -- all transparently.

## Prerequisites

Before using this skill, ensure:

1. **Node.js or browser environment** with TypeScript support
2. **An Algorand wallet or private key** for signing payment transactions
3. **USDC balance** on the target network (testnet or mainnet) in the payer's account

## Core Workflow: The 402 Payment Flow

The key insight is that `wrapFetchWithPayment` and `wrapAxiosWithPayment` intercept 402 responses, sign a transaction group, and retry the original request with the payment header -- all automatically:

```
Client Request (GET /api/premium)
         |
         v
   Server Response
         |
         +-- Status != 402 --> Return response as-is
         |
         +-- Status == 402 -->
               |
               +-- Parse PaymentRequired (headers V2 / body V1)
               +-- Select scheme via registered x402Client
               +-- Build atomic transaction group
               +-- Sign with ClientAvmSigner (wallet or private key)
               +-- Encode PAYMENT-SIGNATURE header
               +-- Retry original request with payment header
               |
               v
           Return retried response
```

## How to Proceed

### Step 1: Install Dependencies

For Fetch-based clients:
```bash
npm install @x402/fetch @x402/avm
```

For Axios-based clients:
```bash
npm install @x402/axios @x402/avm axios
```

`algosdk` is only needed if you build a custom `ClientAvmSigner` (browser wallets, advanced flows):
```bash
npm install algosdk
```

### Step 2: Create a ClientAvmSigner

The `ClientAvmSigner` interface is what bridges your wallet or private key to the x402 payment system.

**For Node.js (private key) -- use `toClientAvmSigner` from `@x402/avm`:**
```typescript
import { toClientAvmSigner } from "@x402/avm";

// AVM_PRIVATE_KEY is the base64 of the 64-byte algosdk secret key (32-byte seed + 32-byte pubkey).
// It is NOT a mnemonic -- toClientAvmSigner throws on anything other than a 64-byte base64 key.
// To produce it from an algosdk account: Buffer.from(account.sk).toString("base64")
const signer = toClientAvmSigner(process.env.AVM_PRIVATE_KEY!);
console.log("Payer address:", signer.address);
```

**For browser wallets -- implement the interface manually:**
```typescript
interface ClientAvmSigner {
  address: string;
  signTransactions(
    txns: Uint8Array[],
    indexesToSign?: number[],
  ): Promise<(Uint8Array | null)[]>;
}
```

**Browser (@txnlab/use-wallet):**
```typescript
import { useWallet } from "@txnlab/use-wallet-react";
import type { ClientAvmSigner } from "@x402/avm";

function useAvmSigner(): ClientAvmSigner | null {
  const { activeAccount, signTransactions } = useWallet();
  if (!activeAccount) return null;
  return {
    address: activeAccount.address,
    signTransactions: async (txns: Uint8Array[], indexesToSign?: number[]) => {
      return signTransactions(txns, indexesToSign);
    },
  };
}
```

### Step 3: Create and Configure the x402Client

```typescript
import { x402Client } from "@x402/fetch"; // or "@x402/axios"
import { ExactAvmScheme } from "@x402/avm/exact/client";

const client = new x402Client();
client.register("algorand:*", new ExactAvmScheme(signer));
```

### Step 4: Wrap Fetch or Axios

**Fetch:**
```typescript
import { wrapFetchWithPayment } from "@x402/fetch";

const fetchWithPay = wrapFetchWithPayment(fetch, client);
const response = await fetchWithPay("https://api.example.com/premium-data");
```

**Axios:**
```typescript
import axios from "axios";
import { wrapAxiosWithPayment } from "@x402/axios";

const api = wrapAxiosWithPayment(axios.create(), client);
const response = await api.get("https://api.example.com/premium-data");
```

### Step 5: Add Payment Policies (Optional)

Policies filter payment requirements before selection. They are applied in order:

```typescript
import type { PaymentPolicy } from "@x402/fetch";

const maxAmount: PaymentPolicy = (version, reqs) => {
  return reqs.filter((r) => BigInt(r.amount ?? "0") <= BigInt("5000000"));
};

const preferAlgorand: PaymentPolicy = (version, reqs) => {
  const algoReqs = reqs.filter((r) => r.network.startsWith("algorand:"));
  return algoReqs.length > 0 ? algoReqs : reqs;
};

client.registerPolicy(preferAlgorand).registerPolicy(maxAmount);
```

### Step 6: Add Lifecycle Hooks (Optional)

Monitor and control the payment lifecycle:

```typescript
client.onBeforePaymentCreation(async ({ selectedRequirements }) => {
  const amountUSDC = Number(selectedRequirements.amount) / 1_000_000;
  console.log(`Paying $${amountUSDC.toFixed(6)} USDC`);
  if (amountUSDC > 10) {
    return { abort: true, reason: "Amount exceeds $10 limit" };
  }
});

client.onAfterPaymentCreation(async () => {
  console.log("Payment signed successfully");
});

client.onPaymentCreationFailure(async ({ error }) => {
  console.error("Payment failed:", error.message);
});
```

## Important Rules / Guidelines

1. **Always register a scheme before wrapping** -- `client.register("algorand:*", new ExactAvmScheme(signer))` must be called before `wrapFetchWithPayment` or `wrapAxiosWithPayment`
2. **AVM_PRIVATE_KEY format** -- Base64-encoded 64-byte key (32-byte seed + 32-byte public key), i.e. `Buffer.from(account.sk).toString("base64")`. Not a mnemonic; `toClientAvmSigner` does no mnemonic derivation
3. **Prefer `toClientAvmSigner`** -- For private-key signers use `toClientAvmSigner(privateKeyBase64)` from `@x402/avm`; it derives the address for you. Only hand-roll a `ClientAvmSigner` for browser wallets (if you do, derive the address with `algosdk.encodeAddress(secretKey.slice(32))`, never the first 32 bytes)
4. **Single retry** -- The wrapper retries exactly once after 402. If the retry also returns 402, the error is propagated
5. **Interceptor order for Axios** -- Add your own interceptors first, then call `wrapAxiosWithPayment` last
6. **Config-based alternative** -- Use `wrapFetchWithPaymentFromConfig` / `wrapAxiosWithPaymentFromConfig` for declarative setup without manual `x402Client` construction
7. **Wildcard networks** -- Use `"algorand:*"` in config-based setups to match any Algorand network

## Config-Based Setup (Alternative)

Instead of creating an `x402Client` manually, use the config-based approach:

```typescript
import { wrapFetchWithPaymentFromConfig, type x402ClientConfig } from "@x402/fetch";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const config: x402ClientConfig = {
  schemes: [
    {
      network: ALGORAND_TESTNET_CAIP2,
      client: new ExactAvmScheme(signer),
    },
  ],
  policies: [maxAmount],
};

const fetchWithPay = wrapFetchWithPaymentFromConfig(fetch, config);
```

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Failed to parse payment requirements` | Server returned 402 with invalid body | Check server is running x402-compatible middleware |
| `Failed to create payment payload` | Insufficient balance or wrong network | Ensure USDC balance on the correct network |
| `Payment already attempted` | Server returned 402 after payment was sent | Payment was rejected; check facilitator logs |
| `No network/scheme registered` | Server requires an unregistered network | Register the needed scheme with `.register()` |
| `Payment creation aborted` | A `beforePaymentCreation` hook returned abort | Review hook logic; check amount limits |
| `All payment requirements were filtered out` | Policies removed all options | Relax policies or register additional schemes |
| `No client registered for x402 version: 2` | No schemes registered at all | Call `client.register("algorand:*", new ExactAvmScheme(signer))` |

## Reading Payment Receipts

After a successful paid request, check the response header:

```typescript
import { decodePaymentResponseHeader } from "@x402/fetch";

const paymentResponseHeader = response.headers.get("PAYMENT-RESPONSE");
if (paymentResponseHeader) {
  const receipt = decodePaymentResponseHeader(paymentResponseHeader);
  console.log("Transaction settled:", receipt);
}
```

## References / Further Reading

- [create-typescript-x402-client-reference.md](./create-typescript-x402-client-reference.md) - Detailed API reference
- [create-typescript-x402-client-examples.md](./create-typescript-x402-client-examples.md) - Complete code examples
- [x402-avm Fetch Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
