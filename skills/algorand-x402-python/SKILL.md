---
name: algorand-x402-python
description: Builds x402 HTTP-native payment applications on Algorand using Python. Covers clients (httpx, requests), servers (FastAPI, Flask), facilitators, Bazaar discovery, and the x402-core library. Use when implementing x402 payment flows in Python, creating payment-gated APIs, building x402 facilitators, or integrating x402 packages.
---

# x402 on Algorand - Python

Build x402 HTTP-native payment applications on Algorand with Python. Use the reference files below for detailed guidance on each component.

## Python Quick Start

```bash
# Core + AVM mechanism
pip install x402-core x402-avm

# Server middleware (pick one)
pip install x402-core[fastapi]   # FastAPI
pip install x402-core[flask]     # Flask

# HTTP clients (pick one)
pip install x402-fetch[httpx]    # Async with httpx
pip install x402-fetch[requests]  # Sync with requests
```

### Register AVM Scheme

Every component registers the AVM exact scheme unconditionally — no environment variable guards:

```python
# Client
from x402_core.client import x402_client
from x402_avm.mechanisms.avm.exact.client import ExactAvmClient

client = x402_client()
client.register("algorand:*", ExactAvmClient(signer=my_signer))

# Server
from x402_core.server import x402_resource_server
from x402_avm.mechanisms.avm.exact.server import ExactAvmServer

server = x402_resource_server()
server.register("algorand:*", ExactAvmServer())

# Facilitator
from x402_core.facilitator import x402_facilitator
from x402_avm.mechanisms.avm.exact.facilitator import ExactAvmFacilitator

facilitator = x402_facilitator()
facilitator.register("algorand:*", ExactAvmFacilitator(signer=my_signer))
```

### Python algosdk Encoding

Python algosdk's `msgpack_decode()` expects base64 strings, `msgpack_encode()` returns base64 strings. Boundary conversion: `msgpack_decode(base64.b64encode(raw_bytes).decode())` / `base64.b64decode(msgpack_encode(obj))`.

## Reference Guide

Navigate to the appropriate reference based on your task. Each topic has three files:
- **`{name}.md`** — Step-by-step implementation guide
- **`{name}-reference.md`** — API details and type signatures
- **`{name}-examples.md`** — Complete, runnable code samples

### Explaining x402 for Python

Understand x402-core and x402-avm Python package structure, extras installation ([fastapi], [flask], [httpx], [requests]), signer protocols, async vs sync variants, and algosdk encoding boundaries.

- [explain-algorand-x402-python.md](./references/explain-algorand-x402-python.md) — Package ecosystem explanation
- [explain-algorand-x402-python-reference.md](./references/explain-algorand-x402-python-reference.md) — API reference for x402-core and x402-avm packages
- [explain-algorand-x402-python-examples.md](./references/explain-algorand-x402-python-examples.md) — Python pattern examples

### Building Clients

Build HTTP clients with httpx (async) or requests (sync) that automatically handle 402 payments. Covers wrapHttpxWithPayment, wrapRequestsWithPayment, ClientAvmSigner for payment signing.

- [create-python-x402-client.md](./references/create-python-x402-client.md) — Client creation guide
- [create-python-x402-client-reference.md](./references/create-python-x402-client-reference.md) — httpx/requests API reference
- [create-python-x402-client-examples.md](./references/create-python-x402-client-examples.md) — Client code examples

### Building Servers

Build payment-protected servers with FastAPI (async) or Flask (sync) middleware. Covers route pricing, PaymentMiddlewareASGI, Flask PaymentMiddleware, and multi-network support.

- [create-python-x402-server.md](./references/create-python-x402-server.md) — Server creation guide
- [create-python-x402-server-reference.md](./references/create-python-x402-server-reference.md) — FastAPI/Flask middleware API reference
- [create-python-x402-server-examples.md](./references/create-python-x402-server-examples.md) — Server code examples

### Building Facilitators and Bazaar Discovery

Build facilitator services that verify and settle Algorand payments on-chain. Covers FacilitatorAvmSigner protocol, register_exact_avm_facilitator, FastAPI facilitator endpoints (/verify, /settle, /supported), and Bazaar discovery extension for automatic cataloging and indexing of payment-gated APIs (declare_discovery_extension, extract_discovery_info, bazaar_resource_server_extension).

- [create-python-x402-facilitator.md](./references/create-python-x402-facilitator.md) — Facilitator creation guide (includes Bazaar setup in Steps 6-10)
- [create-python-x402-facilitator-reference.md](./references/create-python-x402-facilitator-reference.md) — Facilitator + Bazaar API reference
- [create-python-x402-facilitator-examples.md](./references/create-python-x402-facilitator-examples.md) — Facilitator + Bazaar code examples

### Low-Level SDK Usage

Use x402-avm core components and AVM mechanism directly for custom integrations. Covers x402Client, x402ResourceServer, x402Facilitator, AVM signer protocols, constants, utilities, transaction encoding, and fee abstraction.

- [use-python-x402-core-avm.md](./references/use-python-x402-core-avm.md) — Core SDK usage guide
- [use-python-x402-core-avm-reference.md](./references/use-python-x402-core-avm-reference.md) — Core/AVM API reference
- [use-python-x402-core-avm-examples.md](./references/use-python-x402-core-avm-examples.md) — Core SDK code examples

## Python Package Quick Reference

| Package | Purpose |
| ------- | ------- |
| `x402-core` | Core protocol types and client/server/facilitator implementations |
| `x402-avm` | Algorand Virtual Machine implementation with signers and transaction builders |
| `x402-fetch[httpx]` | Async HTTP client wrapper with automatic 402 payment handling |
| `x402-fetch[requests]` | Sync HTTP client wrapper with automatic 402 payment handling |
| `x402-core[fastapi]` | FastAPI async payment middleware |
| `x402-core[flask]` | Flask sync payment middleware |

## How to Use This Skill

1. **Start here** to understand which reference you need
2. **Read the `{name}.md`** file for step-by-step implementation guidance
3. **Consult `{name}-reference.md`** for API details
4. **Use `{name}-examples.md`** for complete, runnable code samples
