# x402 Algorand (AVM) Reference

## Architecture Overview

x402 is an HTTP-native payment protocol built on the HTTP 402 status code. The Algorand (AVM) implementation is a first-class citizen alongside EVM (Ethereum) and SVM (Solana), providing identical treatment in registration, configuration, and usage patterns.

### Component Architecture

```
                    +-----------------+
                    |    Client       |
                    | (fetch/axios)   |
                    +--------+--------+
                             |
                    HTTP Request + X-PAYMENT header
                             |
                    +--------v--------+
                    | Resource Server |
                    | (express/hono/  |
                    |  next/fastapi/  |
                    |  flask)         |
                    +--------+--------+
                             |
                    HTTP to Facilitator
                             |
                    +--------v--------+
                    |   Facilitator   |
                    | (verify/settle) |
                    +--------+--------+
                             |
                    Algorand Network
                    (simulate/send)
```

### Payment Flow (Detailed)

1. **Client** requests a protected resource -- receives `402 Payment Required` with `PaymentRequirements` in the response body
2. **Client** inspects `PaymentRequirements`: scheme, network, asset, amount, payTo, extra (feePayer, decimals)
3. **Client** builds an atomic transaction group:
   - Without fee abstraction: single ASA transfer transaction
   - With fee abstraction: 2-transaction group (fee payer + ASA transfer)
4. **Client** signs its own transactions, encodes all as base64 msgpack strings
5. **Client** retries the request with `X-PAYMENT` header containing the payload
6. **Resource Server** forwards to the **Facilitator** for verification
7. **Facilitator** runs `verify()`: validates structure, decodes transactions, checks security (no rekey, no close-to, no keyreg), validates payment amount/receiver/asset, signs fee payer, simulates on-chain
8. **Facilitator** runs `settle()`: re-verifies, signs facilitator transactions, submits atomic group, returns txId
9. **Resource Server** grants access and returns the protected resource

### Security Checks (Facilitator Verify)

The facilitator performs these security checks on every transaction in the group:

- No `keyreg` (key registration) transactions allowed
- No `rekeyTo` unless balanced sandwich pattern (A to B then B to A)
- No `closeRemainderTo` or `assetCloseTo` fields (prevents account draining)
- Fee payer must be in facilitator-managed addresses
- Fee payer transaction must be `pay` type, amount=0, no close-to, no rekey
- Fee must not exceed `MAX_REASONABLE_FEE` (10 Algo / 10,000,000 microAlgos)
- Group size must not exceed 16 transactions
- Group ID must be consistent across all transactions

## TypeScript Package Ecosystem

### Core and Mechanism Packages

| Package | npm | Description |
|---------|-----|-------------|
| `@x402-avm/core` | [@x402-avm/core](https://www.npmjs.com/package/@x402-avm/core) | Core types, client, server, and facilitator base classes |
| `@x402-avm/avm` | [@x402-avm/avm](https://www.npmjs.com/package/@x402-avm/avm) | Algorand (AVM) mechanism: signer interfaces, constants, utilities |

### Server Middleware Packages

| Package | npm | Description |
|---------|-----|-------------|
| `@x402-avm/express` | [@x402-avm/express](https://www.npmjs.com/package/@x402-avm/express) | Express.js payment middleware |
| `@x402-avm/hono` | [@x402-avm/hono](https://www.npmjs.com/package/@x402-avm/hono) | Hono payment middleware |
| `@x402-avm/next` | [@x402-avm/next](https://www.npmjs.com/package/@x402-avm/next) | Next.js payment middleware |

### Client Packages

| Package | npm | Description |
|---------|-----|-------------|
| `@x402-avm/fetch` | [@x402-avm/fetch](https://www.npmjs.com/package/@x402-avm/fetch) | Fetch API wrapper with automatic 402 handling |
| `@x402-avm/axios` | [@x402-avm/axios](https://www.npmjs.com/package/@x402-avm/axios) | Axios interceptor with automatic 402 handling |

### Extensions and UI Packages

| Package | npm | Description |
|---------|-----|-------------|
| `@x402-avm/extensions` | [@x402-avm/extensions](https://www.npmjs.com/package/@x402-avm/extensions) | Protocol extensions (bazaar, etc.) |
| `@x402-avm/paywall` | [@x402-avm/paywall](https://www.npmjs.com/package/@x402-avm/paywall) | Browser paywall UI component |

## Python Package Ecosystem

The Python SDK is distributed as a single package with extras:

| Package | PyPI | Description |
|---------|------|-------------|
| `x402-avm` | [x402-avm](https://pypi.org/project/x402-avm/) | Python SDK for x402-avm |

### Python Extras

| Extra | Includes | Description |
|-------|----------|-------------|
| `[avm]` | AVM mechanism | Algorand signer protocols, constants, utilities |
| `[fastapi]` | FastAPI middleware | Payment middleware for FastAPI servers |
| `[flask]` | Flask middleware | Payment middleware for Flask servers |
| `[httpx]` | HTTPX client | Async HTTP client with 402 handling |
| `[requests]` | Requests client | Sync HTTP client with 402 handling |
| `[evm]` | EVM mechanism | Ethereum support |
| `[svm]` | SVM mechanism | Solana support |
| `[extensions]` | Extensions | Protocol extensions |
| `[clients]` | All clients | All HTTP client packages |
| `[servers]` | All servers | All server middleware packages |
| `[mechanisms]` | All mechanisms | AVM + EVM + SVM |
| `[all]` | Everything | All extras combined |

## Network Identifiers

### CAIP-2 Format (V2 -- Primary)

| Network | Identifier | TypeScript Constant |
|---------|------------|---------------------|
| Algorand Testnet | `algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=` | `ALGORAND_TESTNET_CAIP2` |
| Algorand Mainnet | `algorand:wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=` | `ALGORAND_MAINNET_CAIP2` |

### V1 Format (Legacy -- Still Supported)

| Network | Identifier | TypeScript Constant |
|---------|------------|---------------------|
| Algorand Testnet | `algorand-testnet` | `V1_ALGORAND_TESTNET` |
| Algorand Mainnet | `algorand-mainnet` | `V1_ALGORAND_MAINNET` |

Automatic mapping between V1 and V2 formats is available through `V1_TO_CAIP2` and `CAIP2_TO_V1` dictionaries.

## Constants Reference

| Constant | Value | Description |
|----------|-------|-------------|
| USDC Testnet ASA ID | `10458941` | USDC on Algorand Testnet |
| USDC Mainnet ASA ID | `31566704` | USDC on Algorand Mainnet |
| USDC Decimals | `6` | Decimal places for USDC |
| Min Transaction Fee | `1000` microAlgos | Minimum fee per transaction |
| Max Atomic Group Size | `16` | Maximum transactions per group |
| Max Reasonable Fee | `10,000,000` microAlgos (10 Algo) | Safety cap for fee payer |
| Algorand Address Length | `58` characters | Base32-encoded with checksum |

## Environment Variables

### Resource Server

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AVM_ADDRESS` | Yes | Algorand address to receive payments | 58-char address |
| `FACILITATOR_URL` | Yes | Facilitator endpoint | `https://facilitator.goplausible.xyz` |

### Facilitator

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AVM_PRIVATE_KEY` | Yes | Base64-encoded 64-byte key | Base64 string |
| `ALGOD_SERVER` | No | Algod endpoint (defaults to AlgoNode) | `https://testnet-api.algonode.cloud` |
| `ALGOD_TOKEN` | No | Algod API token (empty for public) | `""` |
| `PORT` | No | Server port (defaults to 4022) | `4022` |

### Client

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AVM_PRIVATE_KEY` | Yes | Base64-encoded 64-byte key | Base64 string |
| `RESOURCE_SERVER_URL` | Yes | Protected resource server | `http://localhost:4021` |
| `ENDPOINT_PATH` | No | Path to protected endpoint | `/weather` |

### SDK (Optional Overrides)

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `ALGOD_MAINNET_URL` | No | Custom mainnet Algod | `https://mainnet-api.algonode.cloud` |
| `ALGOD_TESTNET_URL` | No | Custom testnet Algod | `https://testnet-api.algonode.cloud` |
| `INDEXER_MAINNET_URL` | No | Custom mainnet Indexer (Python) | `https://mainnet-idx.algonode.cloud` |
| `INDEXER_TESTNET_URL` | No | Custom testnet Indexer (Python) | `https://testnet-idx.algonode.cloud` |

### Next.js Reference Site

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `NEXT_PUBLIC_FACILITATOR_URL` | Yes | Client-side facilitator URL | `http://localhost:3000/facilitator` |
| `FACILITATOR_URL` | Yes | Server-side facilitator URL | `http://localhost:3000/facilitator` |
| `FACILITATOR_AVM_PRIVATE_KEY` | Yes | Facilitator private key | Base64 string |
| `RESOURCE_AVM_ADDRESS` | Yes | Payee address | 58-char address |

## Private Key Format

The `AVM_PRIVATE_KEY` is a Base64-encoded 64-byte value:

- **Bytes 0-31:** Ed25519 seed (private key material)
- **Bytes 32-63:** Ed25519 public key
- **Address derivation:** `algosdk.encodeAddress(secretKey.slice(32))` (TypeScript) or `encode_address(secret_key[32:])` (Python)

## Testing

### Manual Testing Flow

1. Start a facilitator on port 4020
2. Start a resource server on port 4021 pointing to the facilitator
3. Run a client that hits the resource server
4. Verify: client receives 402, pays, receives 200 with data

### Online Facilitator

Use the public GoPlausible facilitator for testing without running your own:
`https://facilitator.goplausible.xyz`

### Algorand Testnet

- Algod: `https://testnet-api.algonode.cloud`
- Indexer: `https://testnet-idx.algonode.cloud`
- USDC ASA ID: `10458941`
- Fund testnet accounts via the [Algorand Testnet Dispenser](https://bank.testnet.algorand.network/)

## Design Decisions

### Signer Separation

Protocol definitions (interfaces) live in the SDK packages (`@x402-avm/avm` / `x402-avm`). Concrete implementations using `algosdk` live in example code. This keeps the SDK core free of `algosdk` dependencies and allows any wallet library to provide signers.

### Raw Bytes Protocol

The SDK passes raw msgpack bytes (`Uint8Array`) between methods. This matches the `@txnlab/use-wallet` ecosystem standard. Encoding/decoding to/from base64 happens only at protocol boundaries (X-PAYMENT header serialization).

### TypeScript vs Python algosdk Encoding

- **TypeScript algosdk:** Works with raw `Uint8Array` directly -- no conversion needed
- **Python algosdk:** `msgpack_decode()` expects base64 strings, `msgpack_encode()` returns base64 strings. Boundary conversion: `msgpack_decode(base64.b64encode(raw_bytes).decode())` / `base64.b64decode(msgpack_encode(obj))`

## External Resources

- [GoPlausible x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [GoPlausible x402-avm Examples Repository](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [Coinbase x402 Protocol](https://github.com/coinbase/x402)
- [Coinbase x402 Algorand Spec (Merged)](https://github.com/coinbase/x402/blob/main/specs/schemes/exact/scheme_exact_algo.md)
- [Coinbase x402 PR #361](https://github.com/coinbase/x402/pull/361/)
- [CAIP-2 Specification](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md)
- [Algorand Developer Portal](https://dev.algorand.co/)
- [algosdk TypeScript](https://github.com/algorand/js-algorand-sdk)
- [algosdk Python](https://github.com/algorand/py-algorand-sdk)
- [@txnlab/use-wallet](https://github.com/TxnLab/use-wallet)
