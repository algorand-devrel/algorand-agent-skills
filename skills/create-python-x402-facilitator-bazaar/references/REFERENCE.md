# Python x402 Facilitator Bazaar Discovery Reference

Detailed API reference for the Bazaar discovery extension in the x402-avm Python package.

## Bazaar Extension API

### declare_discovery_extension()

```python
from x402.extensions.bazaar import declare_discovery_extension
```

Creates a discovery extension dict for route configuration.

**Signature:**
```python
def declare_discovery_extension(
    input: dict,
    input_schema: dict,
    body_type: str | None = None,
    output: OutputConfig | None = None,
) -> dict:
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `input` | `dict` | Yes | Example values for query parameters or request body |
| `input_schema` | `dict` | Yes | JSON Schema describing the expected input |
| `body_type` | `str` or `None` | No | `None` for query (GET), `"json"` / `"form-data"` / `"text"` for body (POST) |
| `output` | `OutputConfig` or `None` | No | Output configuration with example and optional schema |

**Returns:** `{"bazaar": {"info": {...}, "schema": {...}}}`

**body_type values:**

| Value | HTTP Methods | Description |
|-------|-------------|-------------|
| `None` (default) | GET, HEAD, DELETE | Query parameter extension |
| `"json"` | POST, PUT, PATCH | JSON body extension |
| `"form-data"` | POST, PUT, PATCH | Form-data body extension |
| `"text"` | POST, PUT, PATCH | Plain text body extension |

---

### extract_discovery_info()

```python
from x402.extensions.bazaar import extract_discovery_info
```

Extracts discovery info from a payment request. Handles both v2 (extensions in PaymentPayload) and v1 (output_schema in PaymentRequirements) formats.

**Signature:**
```python
def extract_discovery_info(
    payment_payload: PaymentPayload | dict,
    payment_requirements: PaymentRequirements | dict,
    validate: bool = True,
) -> DiscoveredResource | None:
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `payment_payload` | `PaymentPayload` or `dict` | Yes | The payment payload from the client |
| `payment_requirements` | `PaymentRequirements` or `dict` | Yes | The payment requirements from the server |
| `validate` | `bool` | No | Validate v2 extensions before extracting (default: `True`) |

**Returns:** `DiscoveredResource` or `None` if no Bazaar extension found

---

### extract_discovery_info_from_extension()

```python
from x402.extensions.bazaar import extract_discovery_info_from_extension
```

Extracts discovery info from an extension object directly.

**Signature:**
```python
def extract_discovery_info_from_extension(
    extension: dict | DiscoveryExtension,
    validate: bool = True,
) -> DiscoveryInfo:
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `extension` | `dict` or `DiscoveryExtension` | Yes | Extension with `"info"` and `"schema"` keys |
| `validate` | `bool` | No | Raises `ValueError` if validation fails (default: `True`) |

**Returns:** `QueryDiscoveryInfo` or `BodyDiscoveryInfo`

---

### validate_discovery_extension()

```python
from x402.extensions.bazaar import validate_discovery_extension
```

Validates that an extension's `info` data conforms to its `schema`.

**Signature:**
```python
def validate_discovery_extension(
    extension: dict | DiscoveryExtension,
) -> ValidationResult:
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `extension` | `dict` or `DiscoveryExtension` | Yes | Extension to validate |

**Returns:** `ValidationResult` with `valid: bool` and `errors: list[str]`

---

### validate_and_extract()

```python
from x402.extensions.bazaar import validate_and_extract
```

Validates and extracts discovery info in one step.

**Signature:**
```python
def validate_and_extract(
    extension: dict | DiscoveryExtension,
) -> ValidationExtractResult:
```

**Returns:** Object with `valid: bool`, `errors: list[str]`, and `info: DiscoveryInfo | None`

---

### bazaar_resource_server_extension

```python
from x402.extensions.bazaar import bazaar_resource_server_extension
```

A server-side extension that enriches discovery declarations with HTTP method information at runtime. Must be registered on an `x402ResourceServer` or `x402ResourceServerSync` instance.

**Usage:**
```python
server.register_extension(bazaar_resource_server_extension)
```

**What it does at runtime:**
1. Intercepts the declaration enrichment step when an HTTP request arrives for a payment-protected route with a `"bazaar"` extension
2. Reads the HTTP method from the transport context (e.g., `request.method`)
3. Injects the method into `info.input.method` and updates the schema
4. The enriched extension is included in the 402 Payment Required response

---

### with_bazaar()

```python
from x402.extensions.bazaar import with_bazaar
```

Extends a facilitator client with discovery query capabilities.

**Signature:**
```python
def with_bazaar(
    client: HTTPFacilitatorClient,
) -> BazaarExtendedClient:
```

**Returns:** Extended client with `client.extensions.discovery.list_resources()` method. All original facilitator client methods are delegated transparently.

---

### OutputConfig

```python
from x402.extensions.bazaar import OutputConfig
```

Configuration for the output portion of a discovery extension.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `example` | `dict` | Yes | Example response value |
| `schema` | `dict` or `None` | No | JSON Schema for the response |

---

## Data Types

### DiscoveredResource

```python
@dataclass
class DiscoveredResource:
    resource_url: str          # Normalized URL (no query/hash)
    method: str                # HTTP method (GET, POST, etc.)
    x402_version: int          # 1 or 2
    discovery_info: DiscoveryInfo  # QueryDiscoveryInfo or BodyDiscoveryInfo
    description: str | None    # From resource info or requirements
    mime_type: str | None      # From resource info or requirements
```

### DiscoveryInfo (Union Type)

```python
DiscoveryInfo = QueryDiscoveryInfo | BodyDiscoveryInfo
```

### ValidationResult

```python
@dataclass
class ValidationResult:
    valid: bool
    errors: list[str]  # Empty when valid
```

---

## Pydantic Models (from `x402.extensions.bazaar.types`)

| Type | Fields | Description |
|------|--------|-------------|
| `QueryInput` | `type`, `method`, `query_params`, `headers` | Input spec for GET/HEAD/DELETE |
| `BodyInput` | `type`, `method`, `body_type`, `body`, `query_params`, `headers` | Input spec for POST/PUT/PATCH |
| `OutputInfo` | `type`, `format`, `example` | Output specification |
| `QueryDiscoveryInfo` | `input: QueryInput`, `output: OutputInfo` | Discovery info for query methods |
| `BodyDiscoveryInfo` | `input: BodyInput`, `output: OutputInfo` | Discovery info for body methods |
| `QueryDiscoveryExtension` | `info: QueryDiscoveryInfo`, `schema_: dict` | Full extension with schema (query) |
| `BodyDiscoveryExtension` | `info: BodyDiscoveryInfo`, `schema_: dict` | Full extension with schema (body) |

### Union Types

| Name | Members | Description |
|------|---------|-------------|
| `DiscoveryInfo` | `QueryDiscoveryInfo \| BodyDiscoveryInfo` | Any discovery info |
| `DiscoveryExtension` | `QueryDiscoveryExtension \| BodyDiscoveryExtension` | Any extension |

---

## Type Constants and Literals

| Name | Value | Description |
|------|-------|-------------|
| `BAZAAR` | `"bazaar"` | Extension key identifier in route configs |

| Literal Type | Values | Description |
|-------------|--------|-------------|
| `QueryParamMethods` | `"GET"`, `"HEAD"`, `"DELETE"` | HTTP methods using query parameters |
| `BodyMethods` | `"POST"`, `"PUT"`, `"PATCH"` | HTTP methods using request bodies |
| `BodyType` | `"json"`, `"form-data"`, `"text"` | Content types for body requests |

---

## Config Dataclasses

| Type | Fields | Description |
|------|--------|-------------|
| `OutputConfig` | `example`, `schema` | Configure output for `declare_discovery_extension` |
| `DeclareQueryDiscoveryConfig` | `input`, `input_schema`, `output` | Config for query discovery |
| `DeclareBodyDiscoveryConfig` | `input`, `input_schema`, `body_type`, `output` | Config for body discovery |

---

## Client Types (from `x402.extensions.bazaar.facilitator_client`)

| Type | Description |
|------|-------------|
| `ListDiscoveryResourcesParams` | Params for `list_resources()`: `type`, `limit`, `offset` |
| `DiscoveryResource` | A discovered resource: `url`, `type`, `metadata` |
| `DiscoveryResourcesResponse` | Response: `resources`, `total`, `limit`, `offset` |
| `BazaarDiscoveryExtension` | Discovery query class with `list_resources()` method |
| `BazaarClientExtension` | Container with `.discovery` attribute |
| `BazaarExtendedClient` | Extended client with `.extensions` attribute |

---

## Helper Functions (from `x402.extensions.bazaar.types`)

| Function | Import | Description |
|----------|--------|-------------|
| `parse_discovery_extension(data)` | `from x402.extensions.bazaar.types import parse_discovery_extension` | Parse raw dict into typed extension |
| `parse_discovery_info(data)` | `from x402.extensions.bazaar.types import parse_discovery_info` | Parse raw dict into typed info |
| `is_query_method(method)` | `from x402.extensions.bazaar.types import is_query_method` | Check if method is GET/HEAD/DELETE |
| `is_body_method(method)` | `from x402.extensions.bazaar.types import is_body_method` | Check if method is POST/PUT/PATCH |

---

## Functions Summary Table

| Function | Import | Description |
|----------|--------|-------------|
| `declare_discovery_extension` | `from x402.extensions.bazaar import ...` | Create discovery extension dict for route config |
| `validate_discovery_extension` | `from x402.extensions.bazaar import ...` | Validate extension info against its schema |
| `extract_discovery_info` | `from x402.extensions.bazaar import ...` | Extract discovery info from payment request (v1 + v2) |
| `extract_discovery_info_from_extension` | `from x402.extensions.bazaar import ...` | Extract info from extension object directly |
| `validate_and_extract` | `from x402.extensions.bazaar import ...` | Validate and extract in one step |
| `with_bazaar` | `from x402.extensions.bazaar import ...` | Extend facilitator client with discovery queries |
| `parse_discovery_extension` | `from x402.extensions.bazaar.types import ...` | Parse raw dict into typed extension |
| `parse_discovery_info` | `from x402.extensions.bazaar.types import ...` | Parse raw dict into typed info |
| `is_query_method` | `from x402.extensions.bazaar.types import ...` | Check if method is GET/HEAD/DELETE |
| `is_body_method` | `from x402.extensions.bazaar.types import ...` | Check if method is POST/PUT/PATCH |

---

## Installation Commands

```bash
# Extensions only
pip install "x402-avm[extensions]"

# Extensions + Algorand support
pip install "x402-avm[extensions,avm]"

# Extensions + Algorand + FastAPI
pip install "x402-avm[extensions,avm,fastapi]"

# Extensions + Algorand + Flask
pip install "x402-avm[extensions,avm,flask]"

# Everything
pip install "x402-avm[all]"
```

The `[extensions]` extra adds one dependency: `jsonschema>=4.0.0`.

---

## Testing

```bash
# Start the server with Bazaar discovery
AVM_ADDRESS="your-address" uvicorn server:app --port 4021

# Check health
curl http://localhost:4021/health

# Access the payment-gated endpoint (will return 402 with discovery metadata)
curl -v http://localhost:4021/weather?city=London
# Response includes 402 status with PaymentRequired body containing bazaar extension
```

---

## External Resources

- [Extensions Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm AVM Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [JSON Schema Specification](https://json-schema.org/)
- [CAIP-2 Chain ID Specification](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md)
