# @x402/core and @x402/avm Reference

Detailed API reference for the x402-avm TypeScript SDK packages.

## Dependencies

```json
{
  "dependencies": {
    "@x402/core": "latest",
    "@x402/avm": "latest",
    "algosdk": "^3.0.0"
  }
}
```

For browser wallet integration:

```json
{
  "dependencies": {
    "@txnlab/use-wallet": "^4.0.0",
    "@txnlab/use-wallet-react": "^4.0.0"
  }
}
```

## Package Exports: @x402/core

| Import Path | Exports |
|-------------|---------|
| `@x402/core/client` | `x402Client`, `PaymentPolicy` |
| `@x402/core/server` | `x402ResourceServer`, `x402HTTPResourceServer`, `HTTPFacilitatorClient`, `ResourceConfig`, `RouteConfig` |
| `@x402/core/facilitator` | `x402Facilitator` |
| `@x402/core/http` | HTTP utilities and header parsing |
| `@x402/core/types` | `PaymentRequirements`, `PaymentRequirementsV1`, `PaymentPayload`, `PaymentRequired`, `Network` |

## Package Exports: @x402/avm

| Import Path | Exports |
|-------------|---------|
| `@x402/avm` | All constants, types, and utilities |
| `@x402/avm/exact/client` | `.register()` (client variant) |
| `@x402/avm/exact/server` | `.register()` (server variant) |
| `@x402/avm/exact/facilitator` | `.register()` (facilitator variant) |

## x402Client

The client automatically handles HTTP 402 responses by creating payment payloads and retrying.

```typescript
import { x402Client } from "@x402/core/client";

// Optional argument is a selector FUNCTION: (x402Version, requirements) => requirements[n]
const client = new x402Client();
// Schemes are added via client.register(network, new ExactAvmScheme(signer))

// x402Client has no fetch() — wrap fetch with @x402/fetch
import { wrapFetchWithPayment } from "@x402/fetch";
const fetchWithPayment = wrapFetchWithPayment(fetch, client);
```

### Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `register` | `(network: Network, scheme: SchemeNetworkClient) => this` | Register a scheme for a network (glob `"algorand:*"` ok) |
| `registerPolicy` | `(policy: PaymentPolicy) => this` | Add a payment filtering policy |
| `createPaymentPayload` | `(paymentRequired: PaymentRequired) => Promise<PaymentPayload>` | Build a signed payload for a 402 response |

Automatic 402 handling is provided by `wrapFetchWithPayment(fetch, client)` from `@x402/fetch` (there is no `client.fetch`).

### Lifecycle

1. Client sends request to resource URL
2. Server responds with `402 Payment Required` + `PaymentRequired` body
3. Client selects a matching `PaymentRequirements` (filtered by policies)
4. Registered scheme creates and signs payment
5. Client retries with `PAYMENT-SIGNATURE` header containing signed payload

## PaymentPolicy

```typescript
type PaymentPolicy = (
  version: number,
  requirements: PaymentRequirements[],
) => PaymentRequirements[];
```

Policies receive the full list of `PaymentRequirements` from the 402 response and return a filtered subset. If the filtered list is empty, the client cannot pay.

## x402ResourceServer

Transport-agnostic server that creates 402 responses and processes payments.

```typescript
import { x402ResourceServer } from "@x402/core/server";

const server = new x402ResourceServer(facilitatorClient);
```

### Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `register` | `(network: Network, server: SchemeNetworkServer) => this` | Register a scheme for a network |
| `buildPaymentRequirements` | `(resourceConfig: ResourceConfig) => Promise<PaymentRequirements[]>` | Build requirements from a price/payTo config |
| `createPaymentRequiredResponse` | `(requirements, resourceInfo, error?, extensions?) => Promise<PaymentRequired>` | Create a 402 response body |
| `verifyPayment` | `(payload, requirements) => Promise<VerifyResponse>` | Verify via the facilitator |
| `settlePayment` | `(payload, requirements) => Promise<SettleResponse>` | Settle via the facilitator |

(There is no `createPaymentRequired` or `processPayment`.)

## x402HTTPResourceServer

Adds HTTP route matching on top of `x402ResourceServer`.

```typescript
import { x402ResourceServer, x402HTTPResourceServer } from "@x402/core/server";

// Constructor takes a configured x402ResourceServer (not a facilitator client) and a RoutesConfig
const resourceServer = new x402ResourceServer(facilitatorClient);
const httpServer = new x402HTTPResourceServer(resourceServer, routes);
```

### Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `processHTTPRequest` | `(context: HTTPRequestContext, paywallConfig?) => Promise<HTTPProcessResult>` | Match route + verify; result `type` is `"no-payment-required"`, `"payment-verified"` or `"payment-error"` |
| `processSettlement` | `(payload, requirements, declaredExtensions?, ...) => Promise<ProcessSettleResultResponse>` | Settle after the handler runs |
| `requiresPayment` | `(context: HTTPRequestContext) => boolean` | Whether the request matches a protected route |
| `onProtectedRequest` | `(hook) => this` | Register a hook for protected requests |
| `createSettlementHeaders` | `(settleResponse) => Record<string, string>` | Build `PAYMENT-RESPONSE` headers |

`HTTPRequestContext = { adapter: HTTPAdapter; path: string; method: string; paymentHeader?: string; routePattern?: string }`. There is no `processRequest` method and no `.resourceServer` property — keep your own reference to the `x402ResourceServer`.

### Route Configuration

```typescript
// RoutesConfig is keyed by route pattern: "GET /api/premium/*"
type RoutesConfig = Record<string, RouteConfig> | RouteConfig;

interface RouteConfig {
  accepts: PaymentOption | PaymentOption[];   // no `path` — the pattern is the RoutesConfig key
  resource?: string;
  description?: string;
  mimeType?: string;
  serviceName?: string;
  tags?: string[];
  iconUrl?: string;
  extensions?: Record<string, unknown>;
}

interface PaymentOption {
  scheme: string;
  payTo: string;
  price: Price;          // "$0.01" (Money) or { asset, amount, extra? } (AssetAmount)
  network: Network;      // CAIP-2, e.g. ALGORAND_TESTNET_CAIP2
  maxTimeoutSeconds?: number;
  extra?: Record<string, unknown>;
}
```

## HTTPFacilitatorClient

Communicates with a remote facilitator service over HTTP.

```typescript
import { HTTPFacilitatorClient } from "@x402/core/server";

const client = new HTTPFacilitatorClient({
  url: string;
  headers?: Record<string, string>;
});
```

### Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `supported` | `() => Promise<{ networks }>` | Get supported networks |
| `verify` | `(payload) => Promise<VerifyResult>` | Verify a payment |
| `settle` | `(payload) => Promise<SettleResult>` | Settle a payment on-chain |

## x402Facilitator

Local facilitator that verifies and settles payments directly.

```typescript
import { x402Facilitator } from "@x402/core/facilitator";

const facilitator = new x402Facilitator();
```

### Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `verify` | `(payload, requirements) => Promise<VerifyResult>` | Verify payment signature and amounts |
| `settle` | `(payload, requirements) => Promise<SettleResult>` | Sign fee payer txn and submit group |
| `getSupported` | `() => { kinds: { x402Version, scheme, network, extra }[]; extensions: string[]; signers: Record<string, string[]> }` | Get registered scheme/network kinds and signer addresses |
| `register` | `(networks: Network \| Network[], facilitator) => this` | Register a facilitator scheme for one or more networks |

`SettleResponse` is `{ success: boolean; errorReason?: string; errorMessage?: string; payer?: string; transaction: string; network: Network; amount?: string }` — the on-chain transaction ID is in `transaction` (there is no `txId` field). `VerifyResponse` is `{ isValid: boolean; invalidReason?: string; invalidMessage?: string; payer?: string }`.

## ExactAvmScheme

A single class exported from three subpaths — one per role. Register on a client/server/facilitator via the builder `.register(networkPattern, schemeInstance)` method.

### Client Registration

```typescript
import { ExactAvmScheme } from "@x402/avm/exact/client";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

// Constructor: new ExactAvmScheme(signer: ClientAvmSigner, config?: ClientAvmConfig)
client.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(signer));
// Or for all Algorand networks:
client.register("algorand:*", new ExactAvmScheme(signer));
```

### Server Registration

```typescript
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

// Constructor: new ExactAvmScheme()  -- no signer needed server-side
server.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme());
// Or for all Algorand networks:
server.register("algorand:*", new ExactAvmScheme());
```

### Facilitator Registration

```typescript
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

// Constructor: new ExactAvmScheme(signer: FacilitatorAvmSigner)
facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(signer));
// Or for all Algorand networks:
facilitator.register("algorand:*", new ExactAvmScheme(signer));
```

When importing from multiple subpaths in the same file, alias each `ExactAvmScheme` (e.g., `import { ExactAvmScheme as ServerExactAvmScheme } from "@x402/avm/exact/server"`).

## ClientAvmSigner Interface

```typescript
interface ClientAvmSigner {
  address: string;
  signTransactions(
    txns: Uint8Array[],
    indexesToSign?: number[],
  ): Promise<(Uint8Array | null)[]>;
}
```

Compatible with `@txnlab/use-wallet`'s `signTransactions` function. The `indexesToSign` parameter allows selective signing in atomic groups (e.g., sign only the payment transaction, leave the fee payer unsigned for the facilitator).

## FacilitatorAvmSigner Interface

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

Prefer the built-in factory instead of hand-rolling this interface. A signer built on `algosdk.Algodv2` does not type-check; `getAlgodClient` must return an algokit-utils `AlgodClient` (e.g. `AlgorandClient.testNet().client.algod`).

### Signer Helpers

```typescript
toClientAvmSigner(privateKeyBase64: string): ClientAvmSigner
toFacilitatorAvmSigner(
  privateKeyBase64: string,
  config?: { mainnetUrl?: string; testnetUrl?: string; algodToken?: string },
): FacilitatorAvmSigner
```

`privateKeyBase64` is the base64 encoding of the 64-byte algosdk secret key (32-byte seed + 32-byte pubkey). A mnemonic is not accepted (throws `AVM private key must be a Base64-encoded 64-byte key`).

### Method Details

| Method | Purpose |
|--------|---------|
| `getAddresses` | Returns fee payer addresses managed by this facilitator |
| `signTransaction` | Signs a single unsigned transaction (fee payer txn) |
| `getAlgodClient` | Returns an algokit-utils `AlgodClient` for the given network |
| `simulateTransactions` | Simulates an atomic group to validate before submission |
| `sendTransactions` | Submits signed transaction group to the network |
| `waitForConfirmation` | Waits for on-chain confirmation of a transaction |

## Type Guard

```typescript
import { isAvmSignerWallet } from "@x402/avm";

// Returns true if the object has { address: string, signTransactions: Function }
isAvmSignerWallet(wallet): wallet is ClientAvmSigner;
```

## Constants

### Network Identifiers

| Constant | Value |
|----------|-------|
| `ALGORAND_MAINNET_CAIP2` | `"algorand:wGHE2Pwdvd7S12BL5FaOP20EGYesN73k"` (since @x402/avm 2.20.0; earlier releases and the Python `x402-avm` package use the full genesis hash) |
| `ALGORAND_TESTNET_CAIP2` | `"algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe"` (since @x402/avm 2.20.0; earlier releases and the Python `x402-avm` package use the full genesis hash) |
| `CAIP2_NETWORKS` | `[ALGORAND_MAINNET_CAIP2, ALGORAND_TESTNET_CAIP2]` |
| `ALGORAND_MAINNET_GENESIS_HASH` | `"wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8="` |
| `ALGORAND_TESTNET_GENESIS_HASH` | `"SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="` |

Only CAIP-2 identifiers are supported. There are no V1 network-name constants (`"algorand-testnet"`) or V1/CAIP-2 mapping tables; `normalizeAlgorandNetwork("algorand-testnet")` throws.

### USDC / Default Assets

| Constant | Value |
|----------|-------|
| `USDC_MAINNET_ASA_ID` | `"31566704"` |
| `USDC_TESTNET_ASA_ID` | `"10458941"` |
| `USDC_DECIMALS` | `6` |
| `DEFAULT_ASSETS` | `Record<caip2Network, { asset, decimals, symbol }[]>` — default USD assets per network |
| `getDefaultAsset(network, symbol?)` | Look up a default asset (throws if unknown) |
| `findDefaultAsset(asset, network)` | Reverse lookup by ASA id (or `undefined`) |

### Algod Endpoints

No algod URL constants are exported. Configure the node via `ClientAvmConfig` (`new ExactAvmScheme(signer, { algodUrl, algodToken })` or `{ algorandClient: AlgorandClient.testNet() }`) on the client, and via `toFacilitatorAvmSigner(key, { testnetUrl, mainnetUrl, algodToken })` on the facilitator.

### Transaction Limits

| Constant | Value | Description |
|----------|-------|-------------|
| `ALGORAND_MIN_TX_FEE` | `1000` microAlgos (`AlgoAmount`, re-exported from algokit-utils) | Minimum transaction fee |
| `MAX_REASONABLE_FEE_PER_TXN` | `5000` | Per-transaction fee sanity cap (microAlgos) |
| `maxReasonableGroupFee(groupSize)` | `MAX_REASONABLE_FEE_PER_TXN * groupSize` | Fee cap for a fee-payer transaction |

The Algorand protocol limit of 16 transactions per atomic group is not exported as a constant.

### Address Validation

| Constant | Value |
|----------|-------|
| `ALGORAND_ADDRESS_LENGTH` | `58` |

Use `isValidAlgorandAddress(address)` (below) — there is no exported address regex.

## Utility Functions

### Address Validation

```typescript
isValidAlgorandAddress(address: string): boolean
```

Full validation including format check and algosdk checksum verification.

### Amount Conversion

```typescript
convertToTokenAmount(amount: string, decimals: number): string
convertFromTokenAmount(amount: string, decimals: number): string
```

Convert between human-readable decimal amounts and atomic integer units.

### Transaction Encoding/Decoding

```typescript
encodeTransaction(txnBytes: Uint8Array): string          // Uint8Array -> base64
decodeTransaction(base64Str: string): Uint8Array          // base64 -> Uint8Array
decodeSignedTransaction(base64Str: string): SignedTransaction
decodeUnsignedTransaction(base64Str: string): Transaction
```

### Network Utilities

```typescript
getNetworkFromCaip2(caip2: string): "testnet" | "mainnet" | null
isAlgorandNetwork(network: string): boolean    // true for any "algorand:*" CAIP-2 identifier
isTestnetNetwork(network: string): boolean
normalizeAlgorandNetwork(network: string): Network  // accepts short or full-genesis-hash CAIP-2; throws on "algorand-testnet"
```

There are no `v1ToCaip2` / `caip2ToV1` / `createAlgodClient` helpers. For an algod client use algokit-utils: `AlgorandClient.testNet().client.algod`.

### Transaction Inspection

```typescript
getSenderFromTransaction(txnBytes: Uint8Array, isSigned: boolean): string
getTransactionId(txnBytes: Uint8Array): string
hasSignature(txnBytes: Uint8Array): boolean
getGenesisHashFromTransaction(txn: { genesisHash?: Uint8Array }): string
validateGroupId(txnBytesArray: Uint8Array[]): boolean
```

There is no `assignGroupId` — group with algokit-utils `groupTransactions` (from `@algorandfoundation/algokit-utils/transact`) or `algosdk.assignGroupID`.

## Type Definitions

### PaymentRequirements (V2)

```typescript
interface PaymentRequirements {
  scheme: "exact";
  network: Network;           // CAIP-2 identifier (`${string}:${string}`)
  asset: string;              // ASA ID ("0" for native ALGO)
  amount: string;             // Atomic units as string
  payTo: string;              // Receiver address
  maxTimeoutSeconds: number;
  extra?: {
    name: string;             // Token name (e.g., "USDC")
    decimals: number;         // Token decimals (e.g., 6)
  };
}
```

V2 `PaymentRequirements` has no `resource`, `description`, or `mimeType` fields — that metadata lives on `PaymentRequired.resource` (below).

### PaymentPayload

```typescript
interface PaymentPayload {
  x402Version: 2;
  resource?: ResourceInfo;      // { url, description?, mimeType? }
  accepted: PaymentRequirements; // the selected option — scheme/network live here, not at top level
  extensions?: Record<string, unknown>;
  payload: {
    paymentGroup: string[];   // base64-encoded msgpack transaction bytes
    paymentIndex: number;     // Index of the payment transaction
  };
}
```

### PaymentRequired

```typescript
interface PaymentRequired {
  x402Version: 2;
  resource: {
    url: string;
    description: string;
    mimeType: string;
  };
  accepts: PaymentRequirements[];
  error: string;
}
```

## Fee Abstraction Flow

Fee abstraction uses Algorand atomic transaction groups and pooled fees:

1. **Client** creates a 2-transaction atomic group:
   - Transaction 0: USDC/ALGO transfer from client to resource owner (fee = 0)
   - Transaction 1: Self-payment by fee payer address (fee covers both transactions)
2. **Client** signs only Transaction 0 (their payment)
3. **Client** sends both transactions in `paymentGroup` array
4. **Facilitator** validates the fee payer transaction:
   - Must be a self-payment (from == to)
   - Amount must be 0
   - No rekey, close-to, or other dangerous operations
   - Fee must be within `maxReasonableGroupFee(groupSize)` (`MAX_REASONABLE_FEE_PER_TXN` × group size)
5. **Facilitator** signs Transaction 1 and submits the atomic group
6. **Atomic execution** ensures all-or-nothing on-chain

### Security Guarantees

- Fee payer transaction validated for safety (no value extraction)
- Atomic group ensures both transactions succeed or both fail
- Maximum fee cap prevents excessive fee draining
- Group ID consistency validated before submission

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AVM_PRIVATE_KEY` | Base64-encoded 64-byte key | Required for signing |
| `ALGOD_MAINNET_URL` | Custom mainnet Algod URL | `https://mainnet-api.algonode.cloud` |
| `ALGOD_TESTNET_URL` | Custom testnet Algod URL | `https://testnet-api.algonode.cloud` |
| `FACILITATOR_URL` | Facilitator service URL | Varies |
| `FACILITATOR_API_KEY` | Facilitator auth token | Optional |

## Private Key Format

The `AVM_PRIVATE_KEY` is a Base64-encoded 64-byte key:
- Bytes 0-31: Ed25519 seed (private key)
- Bytes 32-63: Ed25519 public key
- Address derivation: `algosdk.encodeAddress(secretKey.slice(32))`

## Testing

Use Algorand TestNet for development:

1. Get testnet ALGO from the [Algorand Dispenser](https://bank.testnet.algorand.network/)
2. Opt in to USDC TestNet ASA (ID: 10458941)
3. Get testnet USDC from [TestNet USDC Dispenser](https://asset-dispenser.testnet.algorand.network/)
4. Use `ALGORAND_TESTNET_CAIP2` as the network identifier

## Import Summary

| Component | TypeScript Import |
|-----------|-------------------|
| Client | `x402Client` from `@x402/core/client` |
| Resource Server | `x402ResourceServer` from `@x402/core/server` |
| HTTP Resource Server | `x402HTTPResourceServer` from `@x402/core/server` |
| Facilitator | `x402Facilitator` from `@x402/core/facilitator` |
| Facilitator Client | `HTTPFacilitatorClient` from `@x402/core/server` |
| AVM Registration (Client) | `.register()` from `@x402/avm/exact/client` |
| AVM Registration (Server) | `.register()` from `@x402/avm/exact/server` |
| AVM Registration (Facilitator) | `.register()` from `@x402/avm/exact/facilitator` |
| Types | `@x402/core/types` |
| Constants | `@x402/avm` |
| Signer Interfaces | `ClientAvmSigner`, `FacilitatorAvmSigner` from `@x402/avm` |
| Type Guard | `isAvmSignerWallet` from `@x402/avm` |

## External Links

- [x402-avm Examples Repository](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [algosdk TypeScript Documentation](https://algorand.github.io/js-algorand-sdk/)
- [CAIP-2 Specification](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md)
- [Algorand Atomic Transfers](https://developer.algorand.org/docs/get-details/atomic_transfers/)
- [@txnlab/use-wallet Documentation](https://txnlab.gitbook.io/use-wallet)
