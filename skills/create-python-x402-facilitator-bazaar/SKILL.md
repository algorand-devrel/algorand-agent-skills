---
name: create-python-x402-facilitator-bazaar
description: Create Python x402 facilitator with Bazaar discovery extension for API cataloging. Use when adding Bazaar discovery to x402 resource servers, declaring discovery extensions on payment-gated routes, extracting discovery info on the facilitator side, validating extensions, building API catalogs for paid services, or integrating Bazaar with FastAPI/Flask servers. Strong triggers include "Bazaar discovery extension", "declare_discovery_extension", "API catalog for x402", "resource discovery", "bazaar_resource_server_extension", "extract_discovery_info", "paid API catalog", "machine-readable API menu", "x402 discovery".
---

# Creating Python x402 Facilitator with Bazaar Discovery

Build Python x402 services with the Bazaar discovery extension for automatic cataloging and indexing of payment-gated APIs.

## Prerequisites

Before using this skill, ensure:

1. **Python 3.10+** is installed
2. **x402-avm with extensions** is available: `pip install "x402-avm[extensions,avm]"`
3. **Familiarity with x402 resource server** and facilitator concepts
4. **Web framework** installed: `pip install "x402-avm[extensions,avm,fastapi]"` or `[...,flask]`

## What Bazaar Discovery Does

Bazaar is a resource discovery protocol built into x402. It allows payment-gated APIs to advertise:

- **What they accept as input** -- query parameters for GET/HEAD/DELETE, or request body schemas for POST/PUT/PATCH
- **What they return as output** -- the shape, type, and examples of the response data

This metadata enables facilitators to automatically catalog and index x402-enabled resources, so clients can discover APIs by their capabilities rather than just by URL. It is a machine-readable menu for paid APIs.

```
Resource Server (declares)         Facilitator (catalogs)        Client (discovers)
+---------------------------+      +----------------------+      +-------------------+
| RouteConfig + extensions: |      | extract_discovery_   |      | with_bazaar()     |
|   **declare_discovery_    | ---> |   info()             | ---> |   .list_resources()|
|     extension(...)        |      | validate_discovery_  |      |                   |
+---------------------------+      |   extension()        |      +-------------------+
                                   +----------------------+
```

## How to Proceed

### Step 1: Install Dependencies

```bash
# Extensions + Algorand + FastAPI
pip install "x402-avm[extensions,avm,fastapi]"

# Extensions + Algorand + Flask
pip install "x402-avm[extensions,avm,flask]"
```

The `extensions` extra installs `jsonschema>=4.0.0` for schema validation.

### Step 2: Declare Discovery Extensions on Routes

Use `declare_discovery_extension()` on your route configurations to describe what each endpoint accepts and returns.

**For GET endpoints (query parameters):**

```python
from x402.extensions.bazaar import declare_discovery_extension, OutputConfig

discovery = declare_discovery_extension(
    input={"city": "San Francisco"},
    input_schema={
        "properties": {
            "city": {"type": "string", "description": "City name"},
        },
        "required": ["city"],
    },
    output=OutputConfig(
        example={"weather": "sunny", "temperature": 70},
        schema={
            "properties": {
                "weather": {"type": "string"},
                "temperature": {"type": "number"},
            },
            "required": ["weather", "temperature"],
        },
    ),
)
```

**For POST endpoints (JSON body):**

```python
discovery = declare_discovery_extension(
    input={"prompt": "Tell me about Algorand", "max_tokens": 100},
    input_schema={
        "properties": {
            "prompt": {"type": "string"},
            "max_tokens": {"type": "integer"},
        },
        "required": ["prompt"],
    },
    body_type="json",
    output=OutputConfig(
        example={"text": "Algorand is a...", "tokens_used": 42},
    ),
)
```

### Step 3: Add Extensions to Route Configuration

Spread the discovery dict into your route's `extensions` field:

```python
from x402.http import PaymentOption
from x402.http.types import RouteConfig
from x402.schemas import Network

AVM_NETWORK: Network = "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="

routes = {
    "GET /weather": RouteConfig(
        accepts=[
            PaymentOption(
                scheme="exact",
                pay_to=AVM_ADDRESS,
                price="$0.001",
                network=AVM_NETWORK,
            ),
        ],
        description="Weather report",
        mime_type="application/json",
        extensions={
            **declare_discovery_extension(
                input={"city": "San Francisco"},
                input_schema={
                    "properties": {"city": {"type": "string"}},
                    "required": ["city"],
                },
                output=OutputConfig(
                    example={"weather": "sunny", "temperature": 70},
                ),
            )
        },
    ),
}
```

### Step 4: Register Bazaar Extension on Server

```python
from x402.server import x402ResourceServer
from x402.http import FacilitatorConfig, HTTPFacilitatorClient
from x402.extensions.bazaar import bazaar_resource_server_extension
from x402.mechanisms.avm.exact import ExactAvmServerScheme

facilitator = HTTPFacilitatorClient(FacilitatorConfig(url="https://x402.org/facilitator"))
server = x402ResourceServer(facilitator)
server.register(AVM_NETWORK, ExactAvmServerScheme())
server.register_extension(bazaar_resource_server_extension)
```

### Step 5: Extract and Validate on Facilitator Side

```python
from x402.extensions.bazaar import extract_discovery_info, validate_discovery_extension

# Extract discovery info from a payment request
discovered = extract_discovery_info(
    payment_payload=payment_payload,
    payment_requirements=payment_requirements,
    validate=True,
)

if discovered:
    print(f"URL: {discovered.resource_url}")
    print(f"Method: {discovered.method}")
    print(f"Description: {discovered.description}")
```

### Step 6: Apply Payment Middleware

**FastAPI:**

```python
from fastapi import FastAPI
from x402.http.middleware.fastapi import PaymentMiddlewareASGI

app = FastAPI()
app.add_middleware(PaymentMiddlewareASGI, routes=routes, server=server)
```

**Flask:**

```python
from flask import Flask
from x402.http.middleware.flask import payment_middleware

app = Flask(__name__)
payment_middleware(app, routes=routes, server=server)
```

## Important Rules / Guidelines

1. **Discovery is chain-agnostic** -- The same Bazaar metadata applies regardless of which payment network (AVM, EVM, SVM) the client uses.
2. **Extensions spread into routes** -- Use `**declare_discovery_extension(...)` to merge the `{"bazaar": {...}}` dict into the route's `extensions` dict.
3. **body_type determines input type** -- `None` (default) creates a query extension (GET/HEAD/DELETE). `"json"` creates a body extension (POST/PUT/PATCH).
4. **Server extension is required** -- Register `bazaar_resource_server_extension` on the server to enrich declarations with HTTP method at runtime.
5. **Validation uses jsonschema** -- The `[extensions]` extra installs jsonschema. Validation checks that `info` data conforms to its `schema`.

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `ImportError: jsonschema` | Missing `[extensions]` extra | Install with `pip install "x402-avm[extensions]"` |
| `KeyError: 'bazaar'` | Extension not declared on route | Add `**declare_discovery_extension(...)` to route config `extensions` |
| `ValidationResult.valid is False` | Extension info does not match schema | Check that example data matches the declared input/output schema |
| `discovered is None` | No Bazaar extension in the payment request | Ensure both server-side declaration and extension registration are in place |
| `body_type not set for POST` | POST route treated as query extension | Add `body_type="json"` to `declare_discovery_extension()` |

## References / Further Reading

- [REFERENCE.md](./references/REFERENCE.md) -- Detailed API reference for Bazaar extension
- [EXAMPLES.md](./references/EXAMPLES.md) -- Complete code examples
- [Extensions Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm AVM Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
