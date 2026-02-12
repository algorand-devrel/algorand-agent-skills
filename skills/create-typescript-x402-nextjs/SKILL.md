---
name: create-typescript-x402-nextjs
description: Create fullstack Next.js apps with x402 payment protection using paymentProxy and withX402. Use when building Next.js applications with payment-gated routes, setting up x402 middleware for API protection, creating paywalls with Algorand payments, or integrating x402 with App Router. Strong triggers include "Next.js x402 paywall", "payment proxy middleware", "withX402 route handler", "paymentProxyFromConfig", "protect Next.js routes with payments", "x402 middleware.ts", "payment-gated API", "Next.js Algorand payments", "@x402-avm/next".
---

# Creating Next.js Apps with x402 Payment Protection

Build fullstack Next.js applications with HTTP 402 payment-gated routes using Algorand blockchain payments. Two patterns are available: the Proxy Pattern for middleware-level protection and the Route Handler Wrapper for per-endpoint control.

## Prerequisites

Before using this skill, ensure:

1. **Next.js 14+ App Router** project is set up
2. **Node.js 18+** is installed
3. **Algorand address** to receive payments (`PAY_TO`)
4. **Facilitator URL** is available (default: `https://x402.org/facilitator`)

## Core Workflow: Two Integration Patterns

```
Pattern 1: Proxy (middleware.ts)           Pattern 2: withX402 (route.ts)

  Request                                    Request
    |                                          |
    v                                          v
  middleware.ts                              route.ts
    |                                          |
  paymentProxy / paymentProxyFromConfig      withX402(handler, config, server)
    |                                          |
  Has X-PAYMENT? ----No----> 402             Has X-PAYMENT? ----No----> 402
    |                                          |
   Yes                                        Yes
    |                                          |
  Verify via facilitator                     Verify via facilitator
    |                                          |
  Forward to route handler                   Execute handler
    |                                          |
  Return response                            If status < 400: settle payment
                                              |
                                             Return response
```

## How to Proceed

### Step 1: Install Dependencies

```bash
npm install @x402-avm/next @x402-avm/avm @x402-avm/core
```

For paywall UI support:

```bash
npm install @x402-avm/next @x402-avm/avm @x402-avm/core @x402-avm/paywall
```

### Step 2: Set Up Environment Variables

Create `.env.local`:

```bash
PAY_TO=ALGORAND_ADDRESS_HERE_58_CHARS
FACILITATOR_URL=https://x402.org/facilitator
```

### Step 3: Choose Your Pattern

#### Option A: Proxy Pattern (Recommended for Multi-Route APIs)

Create `middleware.ts` at your project root:

```typescript
import { NextRequest } from "next/server";
import { paymentProxyFromConfig } from "@x402-avm/next";
import { HTTPFacilitatorClient } from "@x402-avm/core/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402-avm/avm";

const PAY_TO = process.env.PAY_TO!;

const routes = {
  "GET /api/weather": {
    accepts: {
      scheme: "exact",
      network: ALGORAND_TESTNET_CAIP2,
      payTo: PAY_TO,
      price: "$0.01",
    },
    description: "Weather data",
  },
  "GET /api/premium/*": {
    accepts: {
      scheme: "exact",
      network: ALGORAND_TESTNET_CAIP2,
      payTo: PAY_TO,
      price: "$0.10",
    },
    description: "Premium API endpoints",
  },
};

const facilitatorClient = new HTTPFacilitatorClient();
const proxy = paymentProxyFromConfig(routes, facilitatorClient);

export async function middleware(request: NextRequest) {
  return proxy(request);
}

export const config = {
  matcher: "/api/:path*",
};
```

Route handlers remain unchanged -- no wrapping needed:

```typescript
// app/api/weather/route.ts
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({ temperature: 72, condition: "sunny" });
}
```

#### Option B: Route Handler Wrapper (Recommended for Per-Endpoint Control)

Create a shared config module:

```typescript
// lib/x402.ts
import { x402ResourceServer } from "@x402-avm/next";
import { registerExactAvmScheme } from "@x402-avm/avm/exact/server";
import { HTTPFacilitatorClient } from "@x402-avm/core/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402-avm/avm";

export const PAY_TO = process.env.PAY_TO!;
export const NETWORK = ALGORAND_TESTNET_CAIP2;

const facilitatorClient = new HTTPFacilitatorClient({
  url: process.env.FACILITATOR_URL || "https://x402.org/facilitator",
});

export const x402Server = new x402ResourceServer(facilitatorClient);
registerExactAvmScheme(x402Server);
```

Wrap individual route handlers:

```typescript
// app/api/weather/route.ts
import { NextRequest, NextResponse } from "next/server";
import { withX402 } from "@x402-avm/next";
import { x402Server, PAY_TO, NETWORK } from "@/lib/x402";

const handler = async (request: NextRequest) => {
  return NextResponse.json({ temperature: 72, condition: "sunny" });
};

export const GET = withX402(handler, {
  accepts: {
    scheme: "exact",
    network: NETWORK,
    payTo: PAY_TO,
    price: "$0.01",
  },
  description: "Weather data",
}, x402Server);
```

### Step 4: Add Free Routes (Optional)

Routes not matched by the middleware matcher or not wrapped with `withX402` are free:

```typescript
// app/api/health/route.ts -- not wrapped, always free
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({ status: "healthy" });
}
```

### Step 5: Add Multi-Network Support (Optional)

Accept payments on both testnet and mainnet:

```typescript
import {
  ALGORAND_TESTNET_CAIP2,
  ALGORAND_MAINNET_CAIP2,
} from "@x402-avm/avm";

const routes = {
  "GET /api/data": {
    accepts: [
      {
        scheme: "exact",
        network: ALGORAND_TESTNET_CAIP2,
        payTo: "YOUR_TESTNET_ADDRESS",
        price: "$0.01",
      },
      {
        scheme: "exact",
        network: ALGORAND_MAINNET_CAIP2,
        payTo: "YOUR_MAINNET_ADDRESS",
        price: "$0.01",
      },
    ],
    description: "Data endpoint (testnet or mainnet)",
  },
};
```

## Important Rules / Guidelines

1. **Proxy settles on forward, withX402 settles after success** -- The proxy pattern settles payment when forwarding the request. The `withX402` pattern only settles when the handler returns status < 400, protecting against paying for failed requests.
2. **middleware.ts must be at the project root** -- Next.js only loads middleware from the root `middleware.ts` file
3. **Use the `matcher` config** -- Always specify which routes the middleware should intercept to avoid processing static files and other non-API routes
4. **Route patterns use `*` wildcard** -- `"GET /api/premium/*"` matches all sub-paths under `/api/premium/`
5. **Share server instances** -- Create `lib/x402.ts` with shared `x402Server` and `PAY_TO` to avoid duplicating setup across route files
6. **Register the AVM scheme** -- Call `registerExactAvmScheme()` on the server before use
7. **Price uses dollar notation** -- Use `"$0.01"` format for human-readable pricing; the SDK converts to atomic units
8. **Free routes** -- Either exclude them from the middleware matcher or do not wrap them with `withX402`

## Pattern Comparison

| Criteria | Proxy (middleware.ts) | withX402 (route.ts) |
|----------|----------------------|---------------------|
| Setup complexity | Single file | Per-route setup |
| Route configuration | Centralized | Distributed |
| Settlement guarantee | Settles on proxy forward | Settles after handler success |
| Error handling | Proxy-level | Handler-level |
| Handler changes | None required | Wrap each export |
| Multiple methods | Via route patterns | Per-method wrapping |
| Best for | Multi-route APIs | Individual endpoints |

## Common Errors / Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| Middleware not running | `middleware.ts` not at project root | Move to project root directory |
| Static files returning 402 | Matcher too broad | Restrict `matcher` to `/api/:path*` or specific paths |
| `PAY_TO` undefined | Missing env variable | Add `PAY_TO` to `.env.local` |
| `No scheme registered` | Missing AVM scheme registration | Call `registerExactAvmScheme(server)` |
| Payment settled on 500 error | Using proxy pattern | Switch to `withX402` for endpoints that can fail |
| Route not matched | Wrong route pattern | Verify pattern matches Next.js route structure |
| Cross-origin issues | CORS not configured | Add CORS headers in middleware or `next.config.js` |
| `FACILITATOR_URL` not set | Missing facilitator config | Set `FACILITATOR_URL` env variable or use default |

## References / Further Reading

- [REFERENCE.md](./references/REFERENCE.md) - Full API reference for @x402-avm/next
- [EXAMPLES.md](./references/EXAMPLES.md) - Complete code examples
- [x402-avm Next.js Examples](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/)
- [x402-avm Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [Next.js Middleware Documentation](https://nextjs.org/docs/app/building-your-application/routing/middleware)
