---
name: teach-algorand-x402
description: Teach the x402 protocol with Algorand (AVM) integration. Use when explaining what x402 is, how Algorand integrates as a first-class citizen alongside EVM/SVM, the HTTP 402 payment flow, architecture of the three components (client, server, facilitator), CAIP-2 network identifiers, fee abstraction, ASA support, and both TypeScript and Python package ecosystems. Strong triggers include "what is x402", "how does x402 work with Algorand", "explain the payment flow", "what are the three components", "how do client server and facilitator interact", "x402 architecture", "teach me about x402-avm", "how does fee abstraction work".
---

# x402 Protocol with Algorand (AVM)

Understand the x402 protocol, how Algorand integrates as a first-class blockchain alongside EVM and SVM, and how the three components (client, server, facilitator) work together to enable HTTP-native payments.

## Prerequisites

Before diving into x402, ensure you understand:

1. **HTTP basics** -- request/response cycle, status codes (especially 402 Payment Required)
2. **Algorand fundamentals** -- addresses, transactions, ASAs, atomic groups
3. **Package managers** -- npm (TypeScript) or pip (Python) for installing SDK packages

## Core Concept: HTTP 402 Payment Required

x402 turns the HTTP 402 status code into a machine-readable payment protocol. When a client requests a protected resource, the server responds with 402 and structured payment requirements. The client pays, then retries the request with proof of payment.

```
Client              Resource Server         Facilitator         Algorand
  |                      |                      |                  |
  | 1. GET /api/data     |                      |                  |
  |--------------------->|                      |                  |
  | 2. 402 + requirements|                      |                  |
  |<---------------------|                      |                  |
  | 3. Build + sign txn  |                      |                  |
  | 4. GET + X-PAYMENT   |                      |                  |
  |--------------------->| 5. verify()          |                  |
  |                      |--------------------->| 6. simulate      |
  |                      |                      |----------------->|
  |                      |                      |<-----------------|
  |                      |<---------------------| valid            |
  |                      | 7. settle()          |                  |
  |                      |--------------------->| 8. sign + send   |
  |                      |                      |----------------->|
  |                      |                      |<-----------------| confirmed
  |                      |<---------------------| txId             |
  | 9. 200 + data        |                      |                  |
  |<---------------------|                      |                  |
```

## Algorand as a First-Class Citizen

Algorand (AVM) is treated identically to EVM and SVM in x402 -- never conditional, always registered unconditionally. Where EVM hardcodes `"eip155:84532"` and SVM hardcodes `"solana:EtWTRABZaYq6iMfeYKouRu166VU2xqa1"`, AVM hardcodes `"algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="`.

### CAIP-2 Network Identifiers

x402 V2 uses [CAIP-2](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md) identifiers based on genesis hashes:

| Network          | CAIP-2 Identifier                                       |
| ---------------- | ------------------------------------------------------- |
| Algorand Testnet | `algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=` |
| Algorand Mainnet | `algorand:wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=` |

V1 legacy identifiers (`algorand-mainnet`, `algorand-testnet`) are still supported via automatic mapping.

## The Three Components

### 1. Client

The client requests protected resources and handles payments. It:
- Makes initial HTTP request, receives 402 with `PaymentRequirements`
- Builds an Algorand transaction group (optionally with fee abstraction)
- Signs its own transactions (via wallet or private key)
- Retries the request with the `X-PAYMENT` header containing the signed payload

**TypeScript packages:** `@x402-avm/fetch`, `@x402-avm/axios`, `@x402-avm/core/client`
**Python packages:** `x402-avm[httpx]`, `x402-avm[requests]`

### 2. Resource Server

The resource server protects endpoints behind payment gates. It:
- Returns 402 with payment requirements for protected routes
- Forwards payment headers to the facilitator for verification
- Grants access after successful verification and settlement

**TypeScript packages:** `@x402-avm/express`, `@x402-avm/hono`, `@x402-avm/next`
**Python packages:** `x402-avm[fastapi]`, `x402-avm[flask]`

### 3. Facilitator

The facilitator verifies and settles payments. It:
- Verifies payment transaction structure and signatures
- Simulates the transaction group on-chain
- Signs fee payer transactions (for fee abstraction)
- Submits the atomic group to the Algorand network
- Returns the transaction ID

**TypeScript packages:** `@x402-avm/core/facilitator`, `@x402-avm/avm/exact/facilitator`
**Python packages:** `x402-avm[avm]`

**Online facilitator:** `https://facilitator.goplausible.xyz` is available for testing.

## How to Proceed

### Step 1: Understand the Payment Flow

1. Client makes `GET /api/data` -- server returns `402` with `PaymentRequirements`
2. `PaymentRequirements` contain: scheme (`exact`), network (CAIP-2), asset (ASA ID), amount (atomic units), payTo (Algorand address), extra (feePayer, decimals)
3. Client builds a transaction group, signs its own transactions, encodes as base64
4. Client retries with `X-PAYMENT` header containing `{ x402Version, scheme, network, payload: { paymentGroup, paymentIndex } }`
5. Server forwards to facilitator -- facilitator verifies, simulates, settles
6. Server returns 200 with the protected resource

### Step 2: Choose Your Stack

**TypeScript:**
```bash
# Core + AVM mechanism
npm install @x402-avm/core @x402-avm/avm algosdk

# Server middleware (pick one)
npm install @x402-avm/express    # Express.js
npm install @x402-avm/hono       # Hono
npm install @x402-avm/next       # Next.js

# Client (pick one)
npm install @x402-avm/fetch      # Fetch API
npm install @x402-avm/axios      # Axios
```

**Python:**
```bash
# Minimal AVM support
pip install x402-avm[avm]

# Server frameworks (pick one)
pip install x402-avm[avm,fastapi]
pip install x402-avm[avm,flask]

# HTTP clients (pick one)
pip install x402-avm[avm,httpx]
pip install x402-avm[avm,requests]

# Everything
pip install x402-avm[all]
```

### Step 3: Set Up Environment Variables

**For a Resource Server:**
```bash
AVM_ADDRESS=YOUR_ALGORAND_ADDRESS_HERE
FACILITATOR_URL=https://facilitator.goplausible.xyz
```

**For a Facilitator:**
```bash
AVM_PRIVATE_KEY=<base64-encoded-64-byte-key>
ALGOD_SERVER=https://testnet-api.algonode.cloud
ALGOD_TOKEN=
```

**For a Client:**
```bash
AVM_PRIVATE_KEY=<base64-encoded-64-byte-key>
RESOURCE_SERVER_URL=http://localhost:4021
```

### Step 4: Register the AVM Scheme

Every component registers the AVM exact scheme. The registration is unconditional -- no environment variable guards:

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

## Algorand-Specific Features

### Fee Abstraction

Algorand's atomic transaction groups enable fee abstraction. The facilitator pays transaction fees on behalf of the client through a 2-transaction group:

1. **Transaction 0 (fee payer):** Self-payment by facilitator, amount=0, fee covers both txns
2. **Transaction 1 (payment):** ASA transfer from client to payTo, fee=0

Both transactions share an atomic group ID -- they execute all-or-nothing.

### ASA Support

x402-avm supports both native ALGO and Algorand Standard Assets (ASAs) like USDC:

| Asset | Testnet ASA ID | Mainnet ASA ID | Decimals |
|-------|---------------|----------------|----------|
| USDC  | `10458941`    | `31566704`     | 6        |
| ALGO  | `0` (native)  | `0` (native)   | 6        |

### Atomic Groups

Payment groups can include up to 16 transactions, enabling composability -- additional smart contract calls or opt-ins alongside the payment.

### Fast Finality

Algorand transactions finalize in ~3.3 seconds with no reorgs or rollbacks.

## Important Rules / Guidelines

1. **AVM is always first-class** -- never wrap AVM registration in conditional checks
2. **Use CAIP-2 identifiers** -- `algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=` for testnet
3. **Signer separation** -- protocol definitions live in the SDK, implementations live in examples
4. **Raw bytes protocol** -- the SDK passes raw msgpack bytes between methods; algosdk conversions happen at boundaries
5. **Private key format** -- `AVM_PRIVATE_KEY` is Base64-encoded, 64 bytes (32-byte seed + 32-byte pubkey)
6. **Address derivation** -- `encode_address(secret_key[32:])` in both Python and TypeScript

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `402 Payment Required` with no payment options | AVM scheme not registered on server | Call `registerExactAvmScheme(server)` |
| `Invalid network` | Using V1 identifier where V2 expected | Use CAIP-2 format: `algorand:SGO1...` |
| `Simulation failed` | Transaction would fail on-chain | Check balances, ASA opt-in, group structure |
| `Invalid key length` | Wrong private key format | Key must be 64 bytes, Base64-encoded |
| `No signer for address` | Facilitator does not manage that address | Check `getAddresses()` returns the fee payer |
| `Group ID mismatch` | Transactions not properly grouped | Use `algosdk.assignGroupID()` before encoding |
| `Amount mismatch` | Payment amount differs from requirements | Use atomic units matching `paymentRequirements.amount` |

## References / Further Reading

- [REFERENCE.md](./references/REFERENCE.md) - Full architecture reference and package listings
- [EXAMPLES.md](./references/EXAMPLES.md) - Complete code examples for all components
- [GoPlausible x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [GoPlausible x402-avm Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [Coinbase x402 Protocol](https://github.com/coinbase/x402)
- [CAIP-2 Specification](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md)
