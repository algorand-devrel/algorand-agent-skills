# x402 Facilitator Examples

## FacilitatorAvmSigner Setup

```typescript
import { toFacilitatorAvmSigner } from "@x402/avm";
import type { FacilitatorAvmSigner } from "@x402/avm";

// AVM_PRIVATE_KEY: Base64 of the 64-byte secret key (seed || pubkey). Mnemonics are not accepted.
const facilitatorSigner: FacilitatorAvmSigner = toFacilitatorAvmSigner(
  process.env.AVM_PRIVATE_KEY!,
  {
    testnetUrl: process.env.ALGOD_TESTNET_URL, // optional; defaults to https://testnet-api.algonode.cloud
    mainnetUrl: process.env.ALGOD_MAINNET_URL, // optional; defaults to https://mainnet-api.algonode.cloud
    algodToken: process.env.ALGOD_TOKEN,       // optional
  },
);
```

---

## Facilitator Setup and Scheme Registration

```typescript
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const facilitator = new x402Facilitator();

facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(facilitatorSigner));
```

---

## Basic Express.js Facilitator Server

```typescript
import express from "express";
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2, toFacilitatorAvmSigner } from "@x402/avm";

const signer = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!, {
  testnetUrl: process.env.ALGOD_TESTNET_URL,
});

const facilitator = new x402Facilitator();
facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(signer));

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

---

## Facilitator with Lifecycle Hooks

```typescript
const facilitator = new x402Facilitator();
facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(signer));

facilitator.onBeforeVerify(async (context) => {
  console.log(`Verifying ${context.requirements.scheme} payment on ${context.requirements.network}`);
});

facilitator.onAfterSettle(async (context) => {
  if (context.result.success) {
    console.log(`Settled: ${context.result.transaction}`);
  } else {
    console.error(`Settlement failed: ${context.result.errorReason} - ${context.result.errorMessage}`);
  }
});
```

---

## Bazaar: Declaring Discovery Extension (Resource Server)

```typescript
import {
  declareDiscoveryExtension,
  BAZAAR,
} from "@x402/extensions";

// GET endpoint with query parameters
const weatherExtension = declareDiscoveryExtension({
  input: { city: "San Francisco", units: "metric" },
  inputSchema: {
    properties: {
      city: { type: "string", description: "City name" },
      units: {
        type: "string",
        enum: ["metric", "imperial"],
        description: "Temperature units",
      },
    },
    required: ["city"],
  },
  output: {
    example: {
      temperature: 18.5,
      condition: "Partly Cloudy",
      humidity: 65,
    },
    schema: {
      properties: {
        temperature: { type: "number" },
        condition: { type: "string" },
        humidity: { type: "number" },
      },
    },
  },
});
```

---

## Bazaar: GET Endpoint with No Input

```typescript
const priceExtension = declareDiscoveryExtension({
  output: {
    example: {
      price: 42000.50,
      currency: "USD",
      timestamp: "2025-01-01T00:00:00Z",
    },
  },
});
```

---

## Bazaar: POST Endpoint with JSON Body

```typescript
const analysisExtension = declareDiscoveryExtension({
  bodyType: "json",
  input: {
    text: "Analyze this text for sentiment",
    language: "en",
  },
  inputSchema: {
    properties: {
      text: { type: "string", maxLength: 10000 },
      language: { type: "string", enum: ["en", "es", "fr", "de"] },
    },
    required: ["text"],
  },
  output: {
    example: {
      sentiment: "positive",
      confidence: 0.92,
      keywords: ["analyze", "sentiment"],
    },
  },
});
```

---

## Bazaar: POST Endpoint with Form-Data Body

```typescript
const uploadExtension = declareDiscoveryExtension({
  bodyType: "form-data",
  input: {
    file: "(binary)",
    description: "A photo to process",
  },
  inputSchema: {
    properties: {
      file: { type: "string", format: "binary" },
      description: { type: "string" },
    },
    required: ["file"],
  },
  output: {
    example: {
      processedUrl: "https://cdn.example.com/processed/abc123.jpg",
      width: 1920,
      height: 1080,
    },
  },
});
```

---

## Bazaar: Resource Server Extension Registration

```typescript
import {
  x402ResourceServer,
  x402HTTPResourceServer,
  HTTPFacilitatorClient,
} from "@x402/core/server";
import type { RoutesConfig } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import {
  bazaarResourceServerExtension,
  declareDiscoveryExtension,
} from "@x402/extensions";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
});

// Register schemes/extensions on the core x402ResourceServer, then wrap it
const resourceServer = new x402ResourceServer(facilitatorClient);
resourceServer.register("algorand:*", new ExactAvmScheme());
resourceServer.registerExtension(bazaarResourceServerExtension);

// The route pattern is the RoutesConfig key (there is no `path` property)
const routes: RoutesConfig = {
  "GET /api/weather": {
    accepts: {
      scheme: "exact",
      payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
      price: {
        asset: USDC_TESTNET_ASA_ID,
        amount: "10000",
        extra: { name: "USDC", decimals: 6 },
      },
      network: ALGORAND_TESTNET_CAIP2,
      maxTimeoutSeconds: 60,
    },
    description: "Weather data API",
    mimeType: "application/json",
  },
};

const httpServer = new x402HTTPResourceServer(resourceServer, routes);
```

---

## Bazaar: Extracting Discovery Info (Facilitator)

```typescript
import {
  extractDiscoveryInfo,
  validateDiscoveryExtension,
  validateAndExtract,
  extractDiscoveryInfoFromExtension,
  type DiscoveryInfo,
  type DiscoveredResource,
  type ValidationResult,
} from "@x402/extensions";
import type { PaymentPayload, PaymentRequirements } from "@x402/core/types";

// Method 1: Full extraction from payload + requirements
async function processPaymentWithDiscovery(
  paymentPayload: PaymentPayload,
  paymentRequirements: PaymentRequirements,
) {
  const discovered: DiscoveredResource | null = extractDiscoveryInfo(
    paymentPayload,
    paymentRequirements,
  );

  if (discovered) {
    console.log("Resource URL:", discovered.resourceUrl);
    // DiscoveredResource = DiscoveredHTTPResource | DiscoveredMCPResource;
    // `method` (optional) only exists on the HTTP variant, so narrow first
    if ("method" in discovered) {
      console.log("HTTP Method:", discovered.method);
    }
    console.log("x402 Version:", discovered.x402Version);
    console.log("Description:", discovered.description);
    console.log("MIME Type:", discovered.mimeType);
    console.log("Discovery Info:", discovered.discoveryInfo);
  }
}

// Method 2: Validate and extract in one step
function processExtension(extension: unknown) {
  const { valid, info, errors } = validateAndExtract(extension as any);

  if (valid && info) {
    console.log("Type:", info.input.type);
    if (info.input.type === "http") {
      console.log("Method:", info.input.method); // MCP discovery info has no method
    }

    if ("queryParams" in info.input) {
      console.log("Query params:", info.input.queryParams);
    }
    if ("body" in info.input) {
      console.log("Body type:", (info.input as any).bodyType);
    }
  } else {
    console.error("Invalid:", errors);
  }
}

// Method 3: Direct validation
function validateExtension(extension: unknown) {
  const result: ValidationResult = validateDiscoveryExtension(extension as any);

  if (result.valid) {
    console.log("Extension is valid");
  } else {
    console.error("Validation errors:", result.errors);
  }
}

// Method 4: Skip validation (trusted source)
function extractWithoutValidation(
  paymentPayload: PaymentPayload,
  paymentRequirements: PaymentRequirements,
) {
  const discovered = extractDiscoveryInfo(
    paymentPayload,
    paymentRequirements,
    false,
  );

  if (discovered) {
    console.log("Resource:", discovered.resourceUrl);
  }
}
```

---

## Bazaar: Facilitator Client Querying the Bazaar

```typescript
import { HTTPFacilitatorClient } from "@x402/core/server";
import {
  withBazaar,
  type DiscoveryResourcesResponse,
  type DiscoveryResource,
} from "@x402/extensions";

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
});

const client = withBazaar(facilitatorClient);

// List all discovered resources
const allResources: DiscoveryResourcesResponse =
  await client.extensions.bazaar.listResources();

console.log("Total resources:", allResources.pagination.total);
for (const resource of allResources.items) {
  console.log(`- ${resource.resource} (${resource.type})`);
  console.log(`  Payment: ${resource.accepts.length} method(s)`);
  console.log(`  Updated: ${resource.lastUpdated}`);
}

// Filtered query
const httpResources = await client.extensions.bazaar.listResources({
  type: "http",
  limit: 10,
  offset: 0,
});

// Pagination
async function getAllResources() {
  const allItems: DiscoveryResource[] = [];
  let offset = 0;
  const limit = 50;

  while (true) {
    const page = await client.extensions.bazaar.listResources({
      limit,
      offset,
    });

    allItems.push(...page.items);

    if (allItems.length >= page.pagination.total) {
      break;
    }
    offset += limit;
  }

  return allItems;
}

// Finding Algorand-compatible resources
async function findAlgorandResources() {
  const resources = await client.extensions.bazaar.listResources({
    type: "http",
  });

  return resources.items.filter((resource) =>
    resource.accepts.some((req) =>
      req.network.startsWith("algorand:"),
    ),
  );
}
```

---

## Bazaar: WithExtensions Type Utility

```typescript
import { WithExtensions } from "@x402/extensions";
import { HTTPFacilitatorClient } from "@x402/core/server";

type ClientWithBazaar = WithExtensions<
  HTTPFacilitatorClient,
  { discovery: { listResources(): Promise<any> } }
>;

type ClientWithBazaarAndAuth = WithExtensions<
  ClientWithBazaar,
  { auth: { login(): Promise<void> } }
>;
```

---

## Bazaar: Chaining Multiple Extensions

```typescript
import { HTTPFacilitatorClient } from "@x402/core/server";
import { withBazaar } from "@x402/extensions";

interface MyCustomExtension {
  custom: {
    doSomething(): Promise<string>;
  };
}

function withCustom<T extends HTTPFacilitatorClient>(
  client: T,
): T & { extensions: MyCustomExtension } {
  const extended = client as T & { extensions: MyCustomExtension };
  const existingExtensions = (client as any).extensions ?? {};

  extended.extensions = {
    ...existingExtensions,
    custom: {
      async doSomething() {
        return "done";
      },
    },
  } as any;

  return extended;
}

const client = withBazaar(withCustom(new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
})));

const resources = await client.extensions.bazaar.listResources();
const result = await client.extensions.custom.doSomething();
```

---

## Complete Resource Server with Bazaar Discovery

```typescript
import express from "express";
import {
  x402ResourceServer,
  x402HTTPResourceServer,
  HTTPFacilitatorClient,
} from "@x402/core/server";
import type { RoutesConfig } from "@x402/core/server";
import { ExpressAdapter } from "@x402/express";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import {
  bazaarResourceServerExtension,
  declareDiscoveryExtension,
} from "@x402/extensions";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

const app = express();

const facilitatorClient = new HTTPFacilitatorClient({
  url: process.env.FACILITATOR_URL || "https://facilitator.example.com",
});

const resourceServer = new x402ResourceServer(facilitatorClient);
resourceServer.register("algorand:*", new ExactAvmScheme());
resourceServer.registerExtension(bazaarResourceServerExtension);

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
    example: {
      temperature: 18.5,
      condition: "Partly Cloudy",
      humidity: 65,
      windSpeed: 12.3,
    },
  },
});

const analysisDiscovery = declareDiscoveryExtension({
  bodyType: "json",
  input: { text: "Sample text for analysis", language: "en" },
  inputSchema: {
    properties: {
      text: { type: "string", maxLength: 50000 },
      language: { type: "string" },
    },
    required: ["text"],
  },
  output: {
    example: {
      sentiment: "neutral",
      confidence: 0.85,
      entities: ["person", "location"],
      summary: "A brief summary of the analyzed text.",
    },
  },
});

// Route patterns are the RoutesConfig keys; discovery metadata goes in `extensions`
const routes: RoutesConfig = {
  "GET /api/weather": {
    accepts: {
      scheme: "exact",
      payTo: process.env.RECEIVER_ADDRESS!,
      price: {
        asset: USDC_TESTNET_ASA_ID,
        amount: "10000",
        extra: { name: "USDC", decimals: 6 },
      },
      network: ALGORAND_TESTNET_CAIP2,
      maxTimeoutSeconds: 60,
    },
    description: "Real-time weather data",
    mimeType: "application/json",
    extensions: weatherDiscovery,
  },
  "POST /api/analyze": {
    accepts: {
      scheme: "exact",
      payTo: process.env.RECEIVER_ADDRESS!,
      price: {
        asset: USDC_TESTNET_ASA_ID,
        amount: "500000",
        extra: { name: "USDC", decimals: 6 },
      },
      network: ALGORAND_TESTNET_CAIP2,
      maxTimeoutSeconds: 120,
    },
    description: "AI text analysis",
    mimeType: "application/json",
    extensions: analysisDiscovery,
  },
};

const httpServer = new x402HTTPResourceServer(resourceServer, routes);

// Manual integration: processHTTPRequest(context) + processSettlement(...) after the handler.
// (In practice, prefer `paymentMiddleware(routes, resourceServer)` from @x402/express.)
async function requirePayment(
  req: express.Request,
  res: express.Response,
  handler: () => unknown,
) {
  const result = await httpServer.processHTTPRequest({
    adapter: new ExpressAdapter(req),
    path: req.path,
    method: req.method,
    paymentHeader: req.header("payment-signature"),
  });

  if (result.type === "payment-error") {
    return res.status(result.response.status).set(result.response.headers).json(result.response.body ?? {});
  }

  const body = handler();

  if (result.type === "payment-verified") {
    const settlement = await httpServer.processSettlement(
      result.paymentPayload,
      result.paymentRequirements,
      result.declaredExtensions,
    );
    if (!settlement.success) {
      return res.status(settlement.response.status).set(settlement.response.headers).json(settlement.response.body ?? {});
    }
    res.set(settlement.headers);
  }

  res.json(body);
}

app.get("/api/weather", async (req, res) => {
  const city = (req.query.city as string) || "San Francisco";
  await requirePayment(req, res, () => ({
    temperature: 18.5,
    condition: "Partly Cloudy",
    humidity: 65,
    windSpeed: 12.3,
    city,
  }));
});

app.post("/api/analyze", express.json(), async (req, res) => {
  const { text, language } = req.body;
  await requirePayment(req, res, () => ({
    sentiment: "neutral",
    confidence: 0.85,
    entities: ["person", "location"],
    summary: `Analysis of ${text.length} characters in ${language || "en"}.`,
  }));
});

const PORT = parseInt(process.env.PORT || "3000", 10);
app.listen(PORT, () => {
  console.log(`Resource server with Bazaar discovery on port ${PORT}`);
});
```

---

## Complete Facilitator with Bazaar Cataloging

```typescript
import express from "express";
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2, toFacilitatorAvmSigner } from "@x402/avm";
import {
  extractDiscoveryInfo,
  type DiscoveredResource,
} from "@x402/extensions";

// In-memory catalog (use a database in production)
const catalog: Map<string, DiscoveredResource & { settledCount: number }> = new Map();

const signer = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!, {
  testnetUrl: process.env.ALGOD_TESTNET_URL,
});

const facilitator = new x402Facilitator();
facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(signer));

// Register after-settle hook to catalog discovered resources
facilitator.onAfterSettle(async (context) => {
  if (context.result.success) {
    const discovered = extractDiscoveryInfo(
      context.paymentPayload,
      context.requirements,
    );

    if (discovered) {
      // `method` only exists on the HTTP variant of DiscoveredResource
      const method = "method" in discovered ? discovered.method ?? "GET" : "MCP";
      const key = `${method}:${discovered.resourceUrl}`;
      const existing = catalog.get(key);

      if (existing) {
        existing.settledCount += 1;
      } else {
        catalog.set(key, { ...discovered, settledCount: 1 });
      }

      console.log(`Cataloged: ${key} (${catalog.get(key)!.settledCount} settlements)`);
    }
  }
});

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

app.get("/discovery/resources", (req, res) => {
  const type = req.query.type as string | undefined;
  const limit = parseInt(req.query.limit as string || "50", 10);
  const offset = parseInt(req.query.offset as string || "0", 10);

  let items = Array.from(catalog.values());

  if (type) {
    items = items.filter(
      (r) => r.discoveryInfo.input.type === type,
    );
  }

  const total = items.length;
  const paged = items.slice(offset, offset + limit);

  res.json({
    x402Version: 2,
    items: paged.map((r) => ({
      resource: r.resourceUrl,
      type: r.discoveryInfo.input.type,
      x402Version: r.x402Version,
      accepts: [],
      lastUpdated: new Date().toISOString(),
      metadata: {
        method: "method" in r ? r.method : undefined,
        description: r.description,
        mimeType: r.mimeType,
        settledCount: r.settledCount,
      },
    })),
    pagination: { limit, offset, total },
  });
});

app.listen(4000, () => {
  console.log("Facilitator with Bazaar discovery on port 4000");
});
```

---

## Full Stack: Shared Config

```typescript
// shared/config.ts
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

export const NETWORK = ALGORAND_TESTNET_CAIP2;
export const USDC_ASA = USDC_TESTNET_ASA_ID;
export const RESOURCE_WALLET = "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA";
export const FACILITATOR_URL = "http://localhost:4000";
export const RESOURCE_SERVER_URL = "http://localhost:3000";
```

---

## HTTPFacilitatorClient

```typescript
import { HTTPFacilitatorClient } from "@x402/core/server";

// Basic configuration
const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
});

// With authentication (headers are keyed by request path, not a flat object)
const authHeaders = { Authorization: `Bearer ${process.env.FACILITATOR_API_KEY}` };
const authenticatedClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
  createAuthHeaders: async () => ({
    verify: authHeaders,
    settle: authHeaders,
    supported: authHeaders,
  }),
});

// Check supported scheme/network kinds
const supported = await facilitatorClient.getSupported();
console.log("Supported kinds:", supported.kinds.map((k) => `${k.scheme} on ${k.network}`));

// Verify a payment directly
const verifyResult = await facilitatorClient.verify(paymentPayload, paymentRequirements);

// Settle a payment directly
const settleResult = await facilitatorClient.settle(paymentPayload, paymentRequirements);
```
