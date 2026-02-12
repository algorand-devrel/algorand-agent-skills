# x402 Algorand Examples

## Payment Flow Diagram

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
  |                      |<---------------------|                  |
  |                      | 7. settle()          |                  |
  |                      |--------------------->| 8. sign + send   |
  |                      |                      |----------------->|
  |                      |                      |<-----------------|
  |                      |<---------------------| txId             |
  | 9. 200 + data        |                      |                  |
  |<---------------------|                      |                  |
```

## PaymentRequirements (TypeScript)

```typescript
import type { PaymentRequirements } from "@x402-avm/core/types";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402-avm/avm";

const requirements: PaymentRequirements = {
  scheme: "exact",
  network: ALGORAND_TESTNET_CAIP2,
  maxAmountRequired: "1000000",
  resource: "https://api.example.com/premium/data",
  description: "Access to premium API endpoint",
  mimeType: "application/json",
  payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
  maxTimeoutSeconds: 60,
  asset: USDC_TESTNET_ASA_ID,
  outputSchema: undefined,
  extra: {
    name: "USDC",
    decimals: 6,
  },
};
```

## PaymentRequirements (Python)

```python
from x402_avm.types import PaymentRequirements

requirements = PaymentRequirements(
    scheme="exact",
    network="algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
    max_amount_required="1000000",
    resource="https://api.example.com/premium/data",
    description="Access to premium API endpoint",
    pay_to="RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
    max_timeout_seconds=60,
    asset="10458941",
    extra={
        "name": "USDC",
        "decimals": 6,
    },
)
```

## X-PAYMENT Header Payload

```json
{
  "x402Version": 2,
  "scheme": "exact",
  "network": "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
  "payload": {
    "paymentGroup": [
      "<base64-fee-payer-txn>",
      "<base64-signed-asa-transfer>"
    ],
    "paymentIndex": 1
  }
}
```

## 402 Response Body

```typescript
import type { PaymentRequired } from "@x402-avm/core/types";

const paymentRequired: PaymentRequired = {
  x402Version: 2,
  resource: {
    url: "https://api.example.com/premium/data",
    description: "Premium data endpoint",
    mimeType: "application/json",
  },
  accepts: [
    {
      scheme: "exact",
      network: "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
      maxAmountRequired: "1000000",
      resource: "https://api.example.com/premium/data",
      description: "Premium data endpoint",
      mimeType: "application/json",
      payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
      maxTimeoutSeconds: 60,
      asset: "10458941",
      outputSchema: undefined,
      extra: { name: "USDC", decimals: 6 },
    },
  ],
  error: "Payment required to access this resource",
};
```

## TypeScript Client Setup

```typescript
import { x402Client } from "@x402-avm/core/client";
import { registerExactAvmScheme } from "@x402-avm/avm/exact/client";
import type { ClientAvmSigner } from "@x402-avm/avm";
import algosdk from "algosdk";

const secretKey = Buffer.from(process.env.AVM_PRIVATE_KEY!, "base64");
const address = algosdk.encodeAddress(secretKey.slice(32));

const signer: ClientAvmSigner = {
  address,
  signTransactions: async (txns, indexesToSign) => {
    return txns.map((txn, i) => {
      if (indexesToSign && !indexesToSign.includes(i)) return null;
      const decoded = algosdk.decodeUnsignedTransaction(txn);
      return algosdk.signTransaction(decoded, secretKey).blob;
    });
  },
};

const client = new x402Client({ schemes: [] });
registerExactAvmScheme(client, { signer });

const response = await client.fetch("https://api.example.com/premium/data");
if (response.ok) {
  const data = await response.json();
  console.log("Received:", data);
}
```

## TypeScript Resource Server Setup

```typescript
import express from "express";
import { paymentMiddleware, x402ResourceServer } from "@x402-avm/express";
import { registerExactAvmScheme } from "@x402-avm/avm/exact/server";
import { HTTPFacilitatorClient } from "@x402-avm/core/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402-avm/avm";

const app = express();

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.goplausible.xyz",
});
const server = new x402ResourceServer(facilitatorClient);
registerExactAvmScheme(server);

const routes = {
  "GET /api/weather": {
    accepts: {
      scheme: "exact",
      network: ALGORAND_TESTNET_CAIP2,
      payTo: "YOUR_ALGORAND_ADDRESS",
      price: "$0.01",
    },
    description: "Weather data",
  },
};

app.use(paymentMiddleware(routes, server));

app.get("/api/weather", (req, res) => {
  res.json({ temperature: 72, condition: "sunny" });
});

app.listen(4021);
```

## TypeScript Facilitator Setup

```typescript
import express from "express";
import { x402Facilitator } from "@x402-avm/core/facilitator";
import { registerExactAvmScheme } from "@x402-avm/avm/exact/facilitator";
import type { FacilitatorAvmSigner } from "@x402-avm/avm";
import { ALGORAND_TESTNET_CAIP2 } from "@x402-avm/avm";
import algosdk from "algosdk";

const secretKey = Buffer.from(process.env.AVM_PRIVATE_KEY!, "base64");
const address = algosdk.encodeAddress(secretKey.slice(32));
const algodClient = new algosdk.Algodv2("", "https://testnet-api.algonode.cloud", "");

const signer: FacilitatorAvmSigner = {
  getAddresses: () => [address],
  signTransaction: async (txn, _addr) => {
    const decoded = algosdk.decodeUnsignedTransaction(txn);
    return algosdk.signTransaction(decoded, secretKey).blob;
  },
  getAlgodClient: () => algodClient,
  simulateTransactions: async (txns) => {
    const stxns = txns.map((t) => {
      try { return algosdk.decodeSignedTransaction(t); }
      catch { return new algosdk.SignedTransaction({ txn: algosdk.decodeUnsignedTransaction(t) }); }
    });
    const req = new algosdk.modelsv2.SimulateRequest({
      txnGroups: [new algosdk.modelsv2.SimulateRequestTransactionGroup({ txns: stxns })],
      allowEmptySignatures: true,
    });
    return algodClient.simulateTransactions(req).do();
  },
  sendTransactions: async (signedTxns) => {
    const combined = Buffer.concat(signedTxns.map((t) => Buffer.from(t)));
    const { txId } = await algodClient.sendRawTransaction(combined).do();
    return txId;
  },
  waitForConfirmation: async (txId, _net, rounds = 4) => {
    return algosdk.waitForConfirmation(algodClient, txId, rounds);
  },
};

const facilitator = new x402Facilitator();
registerExactAvmScheme(facilitator, { signer, networks: ALGORAND_TESTNET_CAIP2 });

const app = express();
app.use(express.json());

app.post("/verify", async (req, res) => {
  const { paymentPayload, paymentRequirements } = req.body;
  const result = await facilitator.verify(paymentPayload, paymentRequirements);
  res.json(result);
});

app.post("/settle", async (req, res) => {
  const { paymentPayload, paymentRequirements } = req.body;
  const result = await facilitator.settle(paymentPayload, paymentRequirements);
  res.json(result);
});

app.get("/supported", (req, res) => {
  res.json(facilitator.getSupported());
});

app.listen(4020);
```

## Python Client Setup

```python
import asyncio
from x402_avm.client import x402Client
from x402_avm.mechanisms.avm.exact.client import register_exact_avm_scheme

client = x402Client(schemes=[])
register_exact_avm_scheme(client, signer=my_signer)

response = await client.fetch("https://api.example.com/premium/data")
if response.ok:
    data = response.json()
    print("Received:", data)
```

## Python Resource Server Setup (FastAPI)

```python
from fastapi import FastAPI
from x402_avm.fastapi import payment_middleware
from x402_avm.server import HTTPFacilitatorClient

app = FastAPI()

facilitator_client = HTTPFacilitatorClient(
    url="https://facilitator.goplausible.xyz"
)

routes = {
    "GET /api/weather": {
        "accepts": {
            "scheme": "exact",
            "network": "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=",
            "pay_to": "YOUR_ALGORAND_ADDRESS",
            "price": "$0.01",
        },
        "description": "Weather data",
    },
}

app.middleware("http")(payment_middleware(routes, facilitator_client))

@app.get("/api/weather")
async def weather():
    return {"temperature": 72, "condition": "sunny"}
```

## Network Identifier Conversion

```typescript
import {
  ALGORAND_TESTNET_CAIP2,
  V1_TO_CAIP2,
  CAIP2_TO_V1,
} from "@x402-avm/avm";

// V1 to V2
const caip2 = V1_TO_CAIP2["algorand-testnet"];
// => "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="

// V2 to V1
const v1Name = CAIP2_TO_V1[ALGORAND_TESTNET_CAIP2];
// => "algorand-testnet"
```

## Fee Abstraction Transaction Group

```typescript
import algosdk from "algosdk";
import { USDC_TESTNET_ASA_ID, MIN_TXN_FEE, createAlgodClient, ALGORAND_TESTNET_CAIP2 } from "@x402-avm/avm";

const algod = createAlgodClient(ALGORAND_TESTNET_CAIP2);
const params = await algod.getTransactionParams().do();

// Transaction 0: Fee payer (unsigned, for facilitator)
const feePayerTxn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
  from: feePayerAddress,
  to: feePayerAddress,
  amount: 0,
  suggestedParams: { ...params, fee: MIN_TXN_FEE * 2, flatFee: true },
});

// Transaction 1: USDC transfer (signed by client)
const paymentTxn = algosdk.makeAssetTransferTxnWithSuggestedParamsFromObject({
  from: clientAddress,
  to: receiverAddress,
  amount: 10000,
  assetIndex: parseInt(USDC_TESTNET_ASA_ID, 10),
  suggestedParams: { ...params, fee: 0, flatFee: true },
});

const grouped = algosdk.assignGroupID([feePayerTxn, paymentTxn]);
```

## Installation Quick Reference (TypeScript)

```bash
# Core packages
npm install @x402-avm/core @x402-avm/avm algosdk

# Server middleware (choose one)
npm install @x402-avm/express
npm install @x402-avm/hono
npm install @x402-avm/next

# Client packages (choose one)
npm install @x402-avm/fetch
npm install @x402-avm/axios
```

## Installation Quick Reference (Python)

```bash
# Minimal AVM support
pip install x402-avm[avm]

# Server frameworks (choose one)
pip install x402-avm[avm,fastapi]
pip install x402-avm[avm,flask]

# HTTP clients (choose one)
pip install x402-avm[avm,httpx]
pip install x402-avm[avm,requests]

# Everything
pip install x402-avm[all]
```

## Environment Variables

```bash
# Resource Server
AVM_ADDRESS=YOUR_ALGORAND_ADDRESS_HERE
FACILITATOR_URL=https://facilitator.goplausible.xyz

# Facilitator
AVM_PRIVATE_KEY=<base64-encoded-64-byte-key>
ALGOD_SERVER=https://testnet-api.algonode.cloud
ALGOD_TOKEN=

# Client
AVM_PRIVATE_KEY=<base64-encoded-64-byte-key>
RESOURCE_SERVER_URL=http://localhost:4021
```
