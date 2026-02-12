# Python x402 Facilitator Bazaar Discovery Examples

## Declaring Discovery Extension (GET with Query Parameters)

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
# discovery is: {"bazaar": {"info": {...}, "schema": {...}}}
```

---

## Declaring Discovery Extension (POST with JSON Body)

```python
from x402.extensions.bazaar import declare_discovery_extension, OutputConfig

discovery = declare_discovery_extension(
    input={"prompt": "Tell me about Algorand", "max_tokens": 100},
    input_schema={
        "properties": {
            "prompt": {"type": "string", "description": "The text prompt"},
            "max_tokens": {"type": "integer", "description": "Maximum tokens"},
        },
        "required": ["prompt"],
    },
    body_type="json",
    output=OutputConfig(
        example={"text": "Algorand is a...", "tokens_used": 42},
        schema={
            "properties": {
                "text": {"type": "string"},
                "tokens_used": {"type": "integer"},
            },
            "required": ["text"],
        },
    ),
)
```

---

## Minimal Declaration (No Output)

```python
from x402.extensions.bazaar import declare_discovery_extension

discovery = declare_discovery_extension(
    input={"query": "example search term"},
    input_schema={
        "properties": {"query": {"type": "string"}},
        "required": ["query"],
    },
)
```

---

## Route Configuration with Bazaar Discovery (FastAPI)

```python
from x402.extensions.bazaar import declare_discovery_extension, OutputConfig
from x402.http import PaymentOption
from x402.http.types import RouteConfig
from x402.schemas import Network

AVM_NETWORK: Network = "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="
AVM_ADDRESS = "YOUR_ALGORAND_ADDRESS..."

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
                    schema={
                        "properties": {
                            "weather": {"type": "string"},
                            "temperature": {"type": "number"},
                        },
                        "required": ["weather", "temperature"],
                    },
                ),
            )
        },
    ),
}
```

---

## Multi-Chain Route (Algorand + EVM)

```python
routes = {
    "GET /weather": RouteConfig(
        accepts=[
            PaymentOption(
                scheme="exact",
                pay_to=AVM_ADDRESS,
                price="$0.001",
                network="algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            ),
            PaymentOption(
                scheme="exact",
                pay_to=EVM_ADDRESS,
                price="$0.001",
                network="eip155:84532",
            ),
        ],
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

---

## Registering Bazaar Extension on Async Server (FastAPI)

```python
from x402.server import x402ResourceServer
from x402.http import FacilitatorConfig, HTTPFacilitatorClient
from x402.extensions.bazaar import bazaar_resource_server_extension
from x402.mechanisms.avm.exact import ExactAvmServerScheme
from x402.schemas import Network

AVM_NETWORK: Network = "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="

facilitator = HTTPFacilitatorClient(
    FacilitatorConfig(url="https://x402.org/facilitator")
)
server = x402ResourceServer(facilitator)
server.register(AVM_NETWORK, ExactAvmServerScheme())
server.register_extension(bazaar_resource_server_extension)
```

---

## Registering Bazaar Extension on Sync Server (Flask)

```python
from x402.server import x402ResourceServerSync
from x402.http import FacilitatorConfig, HTTPFacilitatorClientSync
from x402.extensions.bazaar import bazaar_resource_server_extension
from x402.mechanisms.avm.exact import ExactAvmServerScheme
from x402.schemas import Network

AVM_NETWORK: Network = "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="

facilitator = HTTPFacilitatorClientSync(
    FacilitatorConfig(url="https://x402.org/facilitator")
)
server = x402ResourceServerSync(facilitator)
server.register(AVM_NETWORK, ExactAvmServerScheme())
server.register_extension(bazaar_resource_server_extension)
```

---

## Extracting Discovery Info (Facilitator Side)

```python
from x402.extensions.bazaar import extract_discovery_info

discovered = extract_discovery_info(
    payment_payload=payment_payload,
    payment_requirements=payment_requirements,
    validate=True,
)

if discovered:
    print(f"Resource URL: {discovered.resource_url}")
    print(f"HTTP Method: {discovered.method}")
    print(f"x402 Version: {discovered.x402_version}")
    print(f"Description: {discovered.description}")
    print(f"MIME Type: {discovered.mime_type}")

    info = discovered.discovery_info
    if hasattr(info.input, "query_params"):
        print(f"Query params: {info.input.query_params}")
    elif hasattr(info.input, "body"):
        print(f"Body: {info.input.body}")

    if info.output:
        print(f"Output example: {info.output.example}")
```

---

## Validating Discovery Extensions

```python
from x402.extensions.bazaar import (
    declare_discovery_extension,
    validate_discovery_extension,
    OutputConfig,
)
from x402.extensions.bazaar.types import parse_discovery_extension

ext_dict = declare_discovery_extension(
    input={"city": "San Francisco"},
    input_schema={
        "properties": {"city": {"type": "string"}},
        "required": ["city"],
    },
    output=OutputConfig(example={"weather": "sunny", "temperature": 70}),
)

extension = parse_discovery_extension(ext_dict["bazaar"])

result = validate_discovery_extension(extension)

if result.valid:
    print("Extension is valid")
else:
    print("Validation errors:", result.errors)
```

---

## Validate and Extract in One Step

```python
from x402.extensions.bazaar import validate_and_extract

result = validate_and_extract(extension_data)

if result.valid and result.info:
    print(f"Method: {result.info.input.method}")
else:
    print("Validation errors:", result.errors)
```

---

## Querying Discovery Resources (Client Side)

```python
from x402.http import HTTPFacilitatorClient, FacilitatorConfig
from x402.extensions.bazaar import with_bazaar, ListDiscoveryResourcesParams

facilitator = HTTPFacilitatorClient(
    FacilitatorConfig(url="https://x402.org/facilitator")
)
client = with_bazaar(facilitator)

response = client.extensions.discovery.list_resources()
for resource in response.resources:
    print(f"URL: {resource.url}")
    print(f"Type: {resource.type}")
    print(f"Metadata: {resource.metadata}")

# Filter and paginate
response = client.extensions.discovery.list_resources(
    ListDiscoveryResourcesParams(type="http", limit=10, offset=0)
)
print(f"Total resources: {response.total}")
```

---

## Complete FastAPI Server with Bazaar Discovery

```python
"""Algorand-gated weather API with Bazaar discovery."""

import os

from dotenv import load_dotenv
from fastapi import FastAPI
from pydantic import BaseModel

from x402.extensions.bazaar import (
    OutputConfig,
    bazaar_resource_server_extension,
    declare_discovery_extension,
)
from x402.http import FacilitatorConfig, HTTPFacilitatorClient, PaymentOption
from x402.http.middleware.fastapi import PaymentMiddlewareASGI
from x402.http.types import RouteConfig
from x402.mechanisms.avm.exact import ExactAvmServerScheme
from x402.schemas import Network
from x402.server import x402ResourceServer

load_dotenv()

AVM_ADDRESS = os.environ["AVM_ADDRESS"]
AVM_NETWORK: Network = "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="
FACILITATOR_URL = os.getenv("FACILITATOR_URL", "https://x402.org/facilitator")


class WeatherReport(BaseModel):
    weather: str
    temperature: int


class WeatherResponse(BaseModel):
    report: WeatherReport


app = FastAPI(title="Weather API (x402 + Algorand + Bazaar)")

facilitator = HTTPFacilitatorClient(FacilitatorConfig(url=FACILITATOR_URL))
server = x402ResourceServer(facilitator)
server.register(AVM_NETWORK, ExactAvmServerScheme())
server.register_extension(bazaar_resource_server_extension)

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
        description="Get weather data for a city",
        mime_type="application/json",
        extensions={
            **declare_discovery_extension(
                input={"city": "San Francisco"},
                input_schema={
                    "properties": {
                        "city": {
                            "type": "string",
                            "description": "City name to get weather for",
                        },
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
        },
    ),
}

app.add_middleware(PaymentMiddlewareASGI, routes=routes, server=server)


@app.get("/weather")
async def get_weather(city: str = "San Francisco") -> WeatherResponse:
    return WeatherResponse(
        report=WeatherReport(weather="sunny", temperature=70)
    )


@app.get("/health")
async def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=4021)
```

---

## Complete Flask Server with Bazaar Discovery

```python
"""Flask version of the Algorand-gated weather API with Bazaar discovery."""

import os

from dotenv import load_dotenv
from flask import Flask, jsonify

from x402.extensions.bazaar import (
    OutputConfig,
    bazaar_resource_server_extension,
    declare_discovery_extension,
)
from x402.http import FacilitatorConfig, HTTPFacilitatorClientSync, PaymentOption
from x402.http.middleware.flask import payment_middleware
from x402.http.types import RouteConfig
from x402.mechanisms.avm.exact import ExactAvmServerScheme
from x402.schemas import Network
from x402.server import x402ResourceServerSync

load_dotenv()

AVM_ADDRESS = os.environ["AVM_ADDRESS"]
AVM_NETWORK: Network = "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="

app = Flask(__name__)

facilitator = HTTPFacilitatorClientSync(
    FacilitatorConfig(url=os.getenv("FACILITATOR_URL", "https://x402.org/facilitator"))
)
server = x402ResourceServerSync(facilitator)
server.register(AVM_NETWORK, ExactAvmServerScheme())
server.register_extension(bazaar_resource_server_extension)

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
payment_middleware(app, routes=routes, server=server)


@app.route("/weather")
def get_weather():
    return jsonify({"report": {"weather": "sunny", "temperature": 70}})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=4021, debug=False)
```

---

## Client Discovering and Calling the API

```python
"""Client that discovers and calls the Algorand-gated weather API."""

import httpx

from x402.http import FacilitatorConfig, HTTPFacilitatorClient
from x402.extensions.bazaar import with_bazaar, ListDiscoveryResourcesParams

FACILITATOR_URL = "https://x402.org/facilitator"

facilitator = HTTPFacilitatorClient(FacilitatorConfig(url=FACILITATOR_URL))
client = with_bazaar(facilitator)

resources = client.extensions.discovery.list_resources(
    ListDiscoveryResourcesParams(type="http", limit=50)
)

for resource in resources.resources:
    print(f"Discovered: {resource.url} ({resource.type})")
    if resource.metadata:
        print(f"  Metadata: {resource.metadata}")
```
