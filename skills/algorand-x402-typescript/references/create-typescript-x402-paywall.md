# Creating Paywall UIs for x402-Protected Endpoints

Build server-side middleware that serves payment HTML pages to browsers and JSON 402 responses to API clients, with automatic wallet integration for Algorand (Pera, Defly, Lute).

## Prerequisites

Before using this skill, ensure:

1. **A backend framework** (Express.js, Hono, or Next.js)
2. **A facilitator service** running and accessible via URL
3. **An Algorand address** to receive payments (payTo address)

## Core Workflow: Server-Side Paywall Architecture

The paywall system has two sides. The server middleware detects missing payments and serves either a JSON 402 or an HTML paywall page. The HTML page handles wallet connection, signing, and retry:

```
Browser Request
     |
     v
[Server Middleware]
     |
     +-- Has PAYMENT-SIGNATURE header?
     |     |
     |     +-- Yes: Verify payment, settle transaction, return content
     |     +-- No: Is this a browser request (Accept: text/html)?
     |           |
     |           +-- Yes: Return paywall HTML page (402)
     |           +-- No: Return JSON 402 response
     |
     v
[Paywall HTML Page]
     |
     +-- Reads window.x402 config
     +-- Shows wallet connection UI (Pera/Defly/Lute)
     +-- User connects wallet and approves payment
     +-- Retries request with PAYMENT-SIGNATURE header
     +-- Redirects to paid content
```

## How to Proceed

### Step 1: Install Dependencies

Server-side packages:
```bash
npm install @x402/paywall @x402/avm @x402/core
```

Plus your framework middleware:
```bash
# Express.js
npm install @x402/express

# Hono
npm install @x402/hono

# Next.js
npm install @x402/next
```

### Step 2: Create the Paywall with PaywallBuilder

The `PaywallBuilder` creates a `PaywallProvider` that generates HTML paywall pages. Register network handlers in priority order -- first match wins:

```typescript
import { createPaywall, avmPaywall } from "@x402/paywall";

const paywall = createPaywall()
  .withNetwork(avmPaywall)    // Supports algorand:* networks
  .withConfig({
    appName: "My Premium API",
    appLogo: "https://example.com/logo.png",
    testnet: true,
  })
  .build();
```

For multi-network support, register multiple handlers:

```typescript
import { createPaywall, avmPaywall, evmPaywall, svmPaywall } from "@x402/paywall";

const paywall = createPaywall()
  .withNetwork(avmPaywall)    // algorand:*
  .withNetwork(evmPaywall)    // eip155:*
  .withNetwork(svmPaywall)    // solana:*
  .withConfig({ appName: "Universal Paywall", testnet: true })
  .build();
```

### Step 3: Define Protected Routes

Routes specify what payment is required for each endpoint:

```typescript
import type { RoutesConfig } from "@x402/core/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const routes: RoutesConfig = {
  "/api/premium-content": {
    accepts: {
      scheme: "exact",
      network: ALGORAND_TESTNET_CAIP2,
      payTo: "YOUR_ALGORAND_ADDRESS_HERE",
      price: "$0.01",             // 0.01 USDC (Money prices resolve to the network's default asset, USDC)
      maxTimeoutSeconds: 300,
    },
    description: "Access to premium content",
    mimeType: "application/json",
  },
};
```

### Step 4: Apply Middleware (Express.js)

```typescript
import express from "express";
import { paymentMiddleware, x402ResourceServer } from "@x402/express";
import { HTTPFacilitatorClient } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const app = express();
const server = new x402ResourceServer(new HTTPFacilitatorClient({ url: process.env.FACILITATOR_URL! })).register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(),
);

app.use(paymentMiddleware(routes, server, { testnet: true }, paywall));

app.get("/api/premium-content", (req, res) => {
  res.json({ content: "This is the paid content." });
});

app.listen(3000);
```

### Step 4 (Alt): Apply Middleware (Hono)

```typescript
import { Hono } from "hono";
import { paymentMiddleware, x402ResourceServer } from "@x402/hono";
import { HTTPFacilitatorClient } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const app = new Hono();
const server = new x402ResourceServer(new HTTPFacilitatorClient({ url: process.env.FACILITATOR_URL! })).register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(),
);

app.use("*", paymentMiddleware(routes, server, { testnet: true }, paywall));

app.get("/api/premium-content", (c) => {
  return c.json({ content: "Premium content unlocked!" });
});

export default app;
```

### Step 4 (Alt): Apply Middleware (Next.js)

**Middleware approach:**
```typescript
// middleware.ts
import { paymentProxy, x402ResourceServer } from "@x402/next";
import { HTTPFacilitatorClient } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const server = new x402ResourceServer(new HTTPFacilitatorClient({ url: process.env.FACILITATOR_URL! })).register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(),
);
const proxy = paymentProxy(routes, server, { testnet: true }, paywall);

export async function middleware(request: NextRequest) {
  if (request.nextUrl.pathname.startsWith("/api/premium")) {
    return proxy(request);
  }
  return NextResponse.next();
}
```

**Route handler approach (withX402):**
```typescript
// app/api/premium/route.ts
import { withX402, x402ResourceServer } from "@x402/next";
import { HTTPFacilitatorClient } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const server = new x402ResourceServer(new HTTPFacilitatorClient({ url: process.env.FACILITATOR_URL! })).register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(),
);

async function handler(request: NextRequest) {
  return NextResponse.json({ content: "Premium content!" });
}

export const GET = withX402(handler, routeConfig, server, { testnet: true }, paywall);
```

## Important Rules / Guidelines

1. **Handler order matters** -- `withNetwork()` calls determine priority. The first handler whose `supports()` returns true for a payment requirement is used
2. **avmPaywall supports `algorand:*`** -- Any network starting with `algorand:` is matched
3. **Testnet vs Mainnet** -- Set `testnet: true/false` in both `PaywallConfig` and middleware config
4. **USDC ASA IDs** -- Testnet: `10458941`, Mainnet: `31566704`
5. **Facilitator URL is required** -- The middleware needs a running facilitator to verify and settle payments. Pass it as `new x402ResourceServer(new HTTPFacilitatorClient({ url }))` (not `{ url }` directly) and call `.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme())` so the server knows the AVM scheme
6. **Tree-shaking** -- Import only the network handlers you need. `avmPaywall` can be imported from `@x402/paywall` or `@x402/paywall/avm`
7. **Multiple routes** -- Define multiple entries in the routes object, each with its own price and description. `PaymentOption` has no `asset` field: a Money price (`"$0.01"`) resolves to the network's default asset (USDC); to charge in a specific ASA use `price: { asset: USDC_TESTNET_ASA_ID, amount: "10000" }` (atomic units)
8. **Type your routes** -- Declare `const routes: RoutesConfig = { ... }` (`import type { RoutesConfig } from "@x402/core/server"`) and use the `ALGORAND_TESTNET_CAIP2` / `ALGORAND_MAINNET_CAIP2` constants from `@x402/avm` (32-char form since @x402/avm 2.20.0; earlier releases and the Python `x402-avm` package use the full genesis hash) instead of hardcoding CAIP-2 strings

## Wallet Integration

The AVM paywall HTML page uses `@wallet-standard/app` to discover Algorand wallets:

| Wallet | Type | Feature |
|--------|------|---------|
| Pera Wallet | Mobile + WalletConnect | `algorand:signTransaction` |
| Defly Wallet | Mobile + WalletConnect | `algorand:signTransaction` |
| Lute Wallet | Browser Extension | `algorand:signTransaction` |

The paywall page automatically:
- Discovers available wallets via wallet-standard
- Shows a wallet selection UI
- Checks USDC balance for the connected account
- Handles transaction signing
- Retries the original request with the payment header
- Redirects to the paid content on success

## Multi-Network Paywalls

Accept payments on multiple chains by specifying an array in `accepts`:

```typescript
import type { RoutesConfig } from "@x402/core/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const routes: RoutesConfig = {
  "/api/premium": {
    accepts: [
      {
        scheme: "exact",
        network: ALGORAND_TESTNET_CAIP2,
        payTo: "ALGO_ADDRESS_HERE",
        price: "$0.01",
        maxTimeoutSeconds: 300,
      },
      {
        scheme: "exact",
        network: "eip155:84532",
        payTo: "0xEVM_ADDRESS_HERE",
        price: "$0.01",
        maxTimeoutSeconds: 30,
      },
    ],
    description: "Premium content - pay with USDC on Algorand or Base",
    mimeType: "application/json",
  },
};
```

## Custom Paywall Handler

If the built-in paywall does not meet your needs, implement a custom `PaywallNetworkHandler`:

```typescript
import type { PaywallNetworkHandler } from "@x402/paywall";

const customHandler: PaywallNetworkHandler = {
  supports(requirement) {
    return requirement.network.startsWith("algorand:");
  },
  generateHtml(requirement, paymentRequired, config) {
    return `<!DOCTYPE html>
      <html><body>
        <h1>Pay ${requirement.amount} to access</h1>
        <script>window.x402 = ${JSON.stringify({ paymentRequired, ...config })};</script>
      </body></html>`;
  },
};

const paywall = createPaywall()
  .withNetwork(customHandler)
  .build();
```

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| Paywall not shown in browser | Middleware not applied or route not matched | Check route patterns match request paths |
| JSON 402 returned to browser | Browser not sending `Accept: text/html` | Ensure direct browser navigation, not programmatic fetch |
| Wallet not detected | Wallet extension not installed | Install Pera, Defly, or Lute wallet |
| "Insufficient balance" | Account has no USDC | Fund the wallet with USDC on the correct network |
| Facilitator unreachable | Wrong URL or service down | Verify `FACILITATOR_URL` environment variable |
| Payment not settling | Facilitator signer not funded | Ensure the facilitator address has ALGO for fees |

## References / Further Reading

- [create-typescript-x402-paywall-reference.md](./create-typescript-x402-paywall-reference.md) - Detailed API reference
- [create-typescript-x402-paywall-examples.md](./create-typescript-x402-paywall-examples.md) - Complete code examples
- [x402-avm Examples Repository](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
