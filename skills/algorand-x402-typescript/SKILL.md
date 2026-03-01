---
name: algorand-x402-typescript
description: Comprehensive guide for building x402 HTTP-native payment applications on Algorand using TypeScript. This is the parent skill that aggregates all TypeScript x402 sub-skills. Use when working with x402 payments in TypeScript/JavaScript, building clients, servers, facilitators, paywalls, or Next.js apps with Algorand x402, or when explaining x402 concepts to TypeScript developers. Strong triggers include "x402 TypeScript", "x402 Algorand TypeScript", "@x402-avm", "payment protocol TypeScript", "402 payment TypeScript", "x402 client fetch axios", "x402 server express hono", "x402 facilitator TypeScript", "x402 paywall", "x402 Next.js", "x402 core avm TypeScript", "explain x402 TypeScript", "teach x402".
---

# x402 on Algorand - TypeScript

This is the aggregated parent skill for all x402 HTTP-native payment protocol skills targeting TypeScript/JavaScript. Use the reference files below to find detailed guidance for each component.

## TypeScript Quick Start

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

### Register AVM Scheme

Every component registers the AVM exact scheme unconditionally — no environment variable guards:

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

### TypeScript algosdk Encoding

TypeScript algosdk works with raw `Uint8Array` directly — no conversion needed. This matches the `@txnlab/use-wallet` ecosystem standard. Encoding/decoding to/from base64 happens only at protocol boundaries (PAYMENT-SIGNATURE header serialization).

## Reference Guide

Navigate to the appropriate reference based on your task. Each topic has three files:
- **`{name}.md`** — Step-by-step implementation guide
- **`{name}-reference.md`** — API details and type signatures
- **`{name}-examples.md`** — Complete, runnable code samples

### Explaining x402 for TypeScript

Understand @x402-avm/* TypeScript package structure, signer interfaces (ClientAvmSigner, FacilitatorAvmSigner), registration patterns, builder patterns, constants, and utilities.

- [explain-algorand-x402-typescript.md](./references/explain-algorand-x402-typescript.md) — Package ecosystem explanation
- [explain-algorand-x402-typescript-reference.md](./references/explain-algorand-x402-typescript-reference.md) — API reference for @x402-avm/* packages
- [explain-algorand-x402-typescript-examples.md](./references/explain-algorand-x402-typescript-examples.md) — TypeScript pattern examples

### Building Clients

Build HTTP clients with Fetch or Axios that automatically handle 402 payments. Covers wrapFetchWithPayment, wrapAxiosWithPayment, ClientAvmSigner for browser wallets or Node.js private keys.

- [create-typescript-x402-client.md](./references/create-typescript-x402-client.md) — Client creation guide
- [create-typescript-x402-client-reference.md](./references/create-typescript-x402-client-reference.md) — Fetch/Axios API reference
- [create-typescript-x402-client-examples.md](./references/create-typescript-x402-client-examples.md) — Client code examples

### Building Servers

Build payment-protected servers with Express.js or Hono middleware. Covers route pricing, multi-network support (AVM+EVM+SVM), 402 responses, and dynamic pricing.

- [create-typescript-x402-server.md](./references/create-typescript-x402-server.md) — Server creation guide
- [create-typescript-x402-server-reference.md](./references/create-typescript-x402-server-reference.md) — Express/Hono middleware API reference
- [create-typescript-x402-server-examples.md](./references/create-typescript-x402-server-examples.md) — Server code examples

### Building Next.js Apps

Build fullstack Next.js apps with x402 payment protection using paymentProxy and withX402. Covers App Router integration, middleware-level protection, and per-endpoint control.

- [create-typescript-x402-nextjs.md](./references/create-typescript-x402-nextjs.md) — Next.js integration guide
- [create-typescript-x402-nextjs-reference.md](./references/create-typescript-x402-nextjs-reference.md) — Next.js API reference
- [create-typescript-x402-nextjs-examples.md](./references/create-typescript-x402-nextjs-examples.md) — Next.js code examples

### Building Facilitators and Bazaar Discovery

Build facilitator services that verify and settle Algorand payments on-chain. Covers FacilitatorAvmSigner, Express.js facilitator servers, and Bazaar discovery extension for API cataloging (bazaarResourceServerExtension, withBazaar, declare_discovery_extension on servers).

- [create-typescript-x402-facilitator.md](./references/create-typescript-x402-facilitator.md) — Facilitator creation guide (includes Bazaar setup in Step 5)
- [create-typescript-x402-facilitator-reference.md](./references/create-typescript-x402-facilitator-reference.md) — Facilitator + Bazaar API reference
- [create-typescript-x402-facilitator-examples.md](./references/create-typescript-x402-facilitator-examples.md) — Facilitator + Bazaar code examples

### Building Paywalls

Build browser paywall UIs with server-side middleware and client-side wallet integration (Pera, Defly, Lute). Covers PaywallBuilder, avmPaywall, multi-network paywalls.

- [create-typescript-x402-paywall.md](./references/create-typescript-x402-paywall.md) — Paywall creation guide
- [create-typescript-x402-paywall-reference.md](./references/create-typescript-x402-paywall-reference.md) — Paywall API reference
- [create-typescript-x402-paywall-examples.md](./references/create-typescript-x402-paywall-examples.md) — Paywall code examples

### Low-Level SDK Usage

Use @x402-avm/core and @x402-avm/avm packages directly for custom integrations. Covers payment policies, AVM signer interfaces, transaction groups, fee abstraction, and low-level primitives.

- [use-typescript-x402-core-avm.md](./references/use-typescript-x402-core-avm.md) — Core SDK usage guide
- [use-typescript-x402-core-avm-reference.md](./references/use-typescript-x402-core-avm-reference.md) — Core/AVM API reference
- [use-typescript-x402-core-avm-examples.md](./references/use-typescript-x402-core-avm-examples.md) — Core SDK code examples

## TypeScript Package Quick Reference

| Package | Purpose |
| ------- | ------- |
| `@x402-avm/fetch` | Wrap fetch with automatic 402 payment handling |
| `@x402-avm/axios` | Wrap axios with automatic 402 payment handling |
| `@x402-avm/express` | Express.js payment middleware |
| `@x402-avm/hono` | Hono payment middleware |
| `@x402-avm/next` | Next.js payment middleware and route wrappers |
| `@x402-avm/paywall` | Browser paywall UI components |
| `@x402-avm/core` | Core protocol primitives (client, server, facilitator) |
| `@x402-avm/avm` | AVM mechanism (signers, transaction builders, constants) |

## How to Use This Skill

1. **Start here** to understand which reference you need
2. **Read the `{name}.md`** file for step-by-step implementation guidance
3. **Consult `{name}-reference.md`** for API details
4. **Use `{name}-examples.md`** for complete, runnable code samples
