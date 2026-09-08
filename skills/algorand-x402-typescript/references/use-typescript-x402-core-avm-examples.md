# @x402/core and @x402/avm Examples

## Installation

```bash
npm install @x402/core @x402/avm algosdk
```

For browser wallet integration:

```bash
npm install @x402/avm algosdk @txnlab/use-wallet-react @txnlab/use-wallet-pera @txnlab/use-wallet-defly
```

---

## Network Identifiers

```typescript
import type { Network } from "@x402/core/types";
import {
  ALGORAND_TESTNET_CAIP2,
  ALGORAND_MAINNET_CAIP2,
  normalizeAlgorandNetwork,
} from "@x402/avm";

// Values below are the 32-char CAIP-2 reference form (since @x402/avm 2.20.0;
// earlier releases and the Python `x402-avm` package use the full genesis hash).
// Always use the constants — never hardcode the string.
const testnet: Network = ALGORAND_TESTNET_CAIP2;
// => "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe"

const mainnet: Network = ALGORAND_MAINNET_CAIP2;
// => "algorand:wGHE2Pwdvd7S12BL5FaOP20EGYesN73k"

// Only CAIP-2 identifiers are supported. Legacy v1 names ("algorand-testnet",
// "algorand-mainnet") are NOT exported and are rejected:
normalizeAlgorandNetwork(ALGORAND_TESTNET_CAIP2); // => ALGORAND_TESTNET_CAIP2
// normalizeAlgorandNetwork("algorand-testnet");  // throws
```

---

## PaymentRequirements (V2)

```typescript
import type { PaymentRequirements } from "@x402/core/types";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

// V2 PaymentRequirements has no `resource` / `description` / `mimeType` fields —
// that metadata lives on the 402 body (`PaymentRequired.resource`).
const requirements: PaymentRequirements = {
  scheme: "exact",
  network: ALGORAND_TESTNET_CAIP2,
  asset: USDC_TESTNET_ASA_ID,
  amount: "1000000",
  payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
  maxTimeoutSeconds: 60,
  extra: {
    name: "USDC",
    decimals: 6,
  },
};

const algoRequirements: PaymentRequirements = {
  scheme: "exact",
  network: ALGORAND_TESTNET_CAIP2,
  asset: "0",
  amount: "1000000",
  payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
  maxTimeoutSeconds: 60,
  extra: {
    name: "ALGO",
    decimals: 6,
  },
};
```

---

## PaymentRequirements (V1 Legacy)

```typescript
import type { PaymentRequirementsV1 } from "@x402/core/types";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

// Even the V1 shape requires a CAIP-2 `network` — v1 names like "algorand-testnet" do not type-check
const requirementsV1: PaymentRequirementsV1 = {
  scheme: "exact",
  network: ALGORAND_TESTNET_CAIP2,
  maxAmountRequired: "1000000",
  resource: "https://api.example.com/premium/data",
  description: "Premium data access",
  mimeType: "application/json",
  payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
  maxTimeoutSeconds: 60,
  asset: USDC_TESTNET_ASA_ID,
  outputSchema: {},
  extra: {
    name: "USDC",
    decimals: 6,
  },
};
```

---

## PaymentPayload

```typescript
import type { PaymentPayload } from "@x402/core/types";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

// V2 PaymentPayload has no top-level scheme/network — they live in `accepted`
// (the PaymentRequirements the client chose from the 402 response).
const payload: PaymentPayload = {
  x402Version: 2,
  resource: { url: "https://api.example.com/premium/data" },
  accepted: {
    scheme: "exact",
    network: ALGORAND_TESTNET_CAIP2,
    asset: USDC_TESTNET_ASA_ID,
    amount: "1000000",
    payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
    maxTimeoutSeconds: 60,
    extra: { name: "USDC", decimals: 6 },
  },
  payload: {
    paymentGroup: [
      "iaNhbXTOAAGGoKNmZWXNA...",
      "iaNhbXTOAAGGoKNmZWXNA...",
    ],
    paymentIndex: 0,
  },
};
```

---

## PaymentRequired Response

```typescript
import type { PaymentRequired } from "@x402/core/types";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

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
      network: ALGORAND_TESTNET_CAIP2,
      asset: USDC_TESTNET_ASA_ID,
      amount: "1000000",
      payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
      maxTimeoutSeconds: 60,
      extra: { name: "USDC", decimals: 6 },
    },
  ],
  error: "Payment required to access this resource",
};
```

---

## Client with Private Key (Server-Side)

```typescript
import { x402Client } from "@x402/core/client";
import { wrapFetchWithPayment } from "@x402/fetch";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";
import algosdk from "algosdk";

const secretKey = Buffer.from(process.env.AVM_PRIVATE_KEY!, "base64");
const address = algosdk.encodeAddress(secretKey.slice(32));

const signer: ClientAvmSigner = {
  address,
  signTransactions: async (txns, indexesToSign) => {
    return txns.map((txn, i) => {
      if (indexesToSign && !indexesToSign.includes(i)) return null;
      const decoded = algosdk.decodeUnsignedTransaction(txn);
      const signed = algosdk.signTransaction(decoded, secretKey);
      return signed.blob;
    });
  },
};

// x402Client takes an optional selector FUNCTION (x402Version, requirements) => requirements[0]
const client = new x402Client();

client.register("algorand:*", new ExactAvmScheme(signer));

// x402Client has no fetch() — wrap fetch with @x402/fetch
const fetchWithPayment = wrapFetchWithPayment(fetch, client);

async function accessPaidResource() {
  const response = await fetchWithPayment(
    "https://api.example.com/premium/data"
  );

  if (response.ok) {
    const data = await response.json();
    console.log("Received:", data);
  }
}
```

---

## Client with @txnlab/use-wallet (Browser)

```typescript
import type { ClientAvmSigner } from "@x402/avm";
import { useWallet } from "@txnlab/use-wallet-react";

function PaymentComponent() {
  const { activeAccount, signTransactions } = useWallet();

  const signer: ClientAvmSigner | null = activeAccount
    ? {
        address: activeAccount.address,
        signTransactions: async (txns, indexesToSign) => {
          return signTransactions(txns, indexesToSign);
        },
      }
    : null;

  return signer ? <PaidContent signer={signer} /> : <ConnectWallet />;
}
```

---

## Full React Browser Client

```typescript
import React, { useState, useCallback } from "react";
import { x402Client } from "@x402/core/client";
import { wrapFetchWithPayment } from "@x402/fetch";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";
import {
  WalletProvider,
  WalletManager,
  useWallet,
  NetworkId,
} from "@txnlab/use-wallet-react";
import { pera } from "@txnlab/use-wallet-pera";
import { defly } from "@txnlab/use-wallet-defly";

// WalletProvider takes a WalletManager instance via `manager`.
// use-wallet 5.x: wallets are adapter factories from @txnlab/use-wallet-<wallet> packages.
const walletManager = new WalletManager({
  wallets: [pera(), defly()],
  defaultNetwork: NetworkId.TESTNET,
});

function PayForWeather() {
  // connect/disconnect live on wallets[i] / activeWallet, not on useWallet() itself
  const { wallets, activeWallet, activeAccount, signTransactions } = useWallet();
  const [weather, setWeather] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchWeather = useCallback(async () => {
    if (!activeAccount) return;
    setLoading(true);

    try {
      const signer: ClientAvmSigner = {
        address: activeAccount.address,
        signTransactions: async (txns, indexes) =>
          signTransactions(txns, indexes),
      };

      const client = new x402Client();
      client.register("algorand:*", new ExactAvmScheme(signer));
      const fetchWithPayment = wrapFetchWithPayment(fetch, client);

      const response = await fetchWithPayment(
        "https://api.example.com/weather"
      );

      if (response.ok) {
        const data = await response.json();
        setWeather(JSON.stringify(data, null, 2));
      } else {
        setWeather(`Error: ${response.status} ${response.statusText}`);
      }
    } catch (err) {
      setWeather(`Error: ${(err as Error).message}`);
    } finally {
      setLoading(false);
    }
  }, [activeAccount, signTransactions]);

  return (
    <div>
      <h1>Weather API (Paid with USDC on Algorand)</h1>

      {!activeAccount ? (
        <button
          onClick={() => wallets.find((w) => w.id === "pera")?.connect()}
        >
          Connect Pera Wallet
        </button>
      ) : (
        <div>
          <p>Connected: {activeAccount.address.slice(0, 8)}...</p>
          <button onClick={fetchWeather} disabled={loading}>
            {loading ? "Paying..." : "Get Weather (0.10 USDC)"}
          </button>
          <button onClick={() => activeWallet?.disconnect()}>Disconnect</button>
        </div>
      )}

      {weather && (
        <pre>{weather}</pre>
      )}
    </div>
  );
}

export default function App() {
  return (
    <WalletProvider manager={walletManager}>
      <PayForWeather />
    </WalletProvider>
  );
}
```

---

## Payment Policies

```typescript
import { x402Client, PaymentPolicy } from "@x402/core/client";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const preferTestnet: PaymentPolicy = (version, requirements) => {
  return requirements.filter(r => r.network === ALGORAND_TESTNET_CAIP2);
};

const maxAmount: PaymentPolicy = (version, requirements) => {
  const MAX_USDC = 5_000_000;
  return requirements.filter(r => {
    const amount = parseInt(r.amount, 10);
    return amount <= MAX_USDC;
  });
};

const preferAlgorand: PaymentPolicy = (version, requirements) => {
  const algorandOptions = requirements.filter(r =>
    r.network.startsWith("algorand:")
  );
  return algorandOptions.length > 0 ? algorandOptions : requirements;
};

const client = new x402Client();
client.register("algorand:*", new ExactAvmScheme(signer));

client.registerPolicy(preferAlgorand);
```

---

## Resource Server (Transport-Agnostic)

```typescript
import { x402ResourceServer, ResourceConfig } from "@x402/core/server";
import { HTTPFacilitatorClient } from "@x402/core/server";
import type { PaymentPayload } from "@x402/core/types";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
});

const server = new x402ResourceServer(facilitatorClient);
server.register("algorand:*", new ExactAvmScheme());

const resourceConfig: ResourceConfig = {
  scheme: "exact",
  payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
  price: {
    asset: USDC_TESTNET_ASA_ID,
    amount: "100000",
    extra: { name: "USDC", decimals: 6 },
  },
  network: ALGORAND_TESTNET_CAIP2,
  maxTimeoutSeconds: 60,
};

async function handleRequest(url: string, paymentHeader?: string) {
  const requirements = await server.buildPaymentRequirements(resourceConfig);
  const resourceInfo = { url, description: "Premium API", mimeType: "application/json" };

  if (!paymentHeader) {
    const paymentRequired = await server.createPaymentRequiredResponse(requirements, resourceInfo);
    return { status: 402, body: paymentRequired };
  }

  // PAYMENT-SIGNATURE header is base64-encoded JSON of a PaymentPayload
  const paymentPayload: PaymentPayload = JSON.parse(
    Buffer.from(paymentHeader, "base64").toString("utf8"),
  );
  const verify = await server.verifyPayment(paymentPayload, requirements[0]);
  if (!verify.isValid) {
    const paymentRequired = await server.createPaymentRequiredResponse(
      requirements,
      resourceInfo,
      verify.invalidReason,
    );
    return { status: 402, body: paymentRequired };
  }

  const settle = await server.settlePayment(paymentPayload, requirements[0]);
  if (!settle.success) {
    return { status: 402, body: { error: settle.errorReason } };
  }
  return { status: 200, body: { data: "premium content" }, transaction: settle.transaction };
}
```

---

## HTTP Resource Server with Routes

```typescript
import {
  x402ResourceServer,
  x402HTTPResourceServer,
  HTTPFacilitatorClient,
} from "@x402/core/server";
import type { RoutesConfig } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
});

// RoutesConfig is keyed by route pattern ("METHOD /path"); RouteConfig has no `path`
const routes: RoutesConfig = {
  "GET /api/premium/*": {
    accepts: {
      scheme: "exact",
      payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
      price: {
        asset: USDC_TESTNET_ASA_ID,
        amount: "100000",
        extra: { name: "USDC", decimals: 6 },
      },
      network: ALGORAND_TESTNET_CAIP2,
      maxTimeoutSeconds: 60,
    },
    description: "Premium API endpoints",
    mimeType: "application/json",
  },
  "POST /api/expensive-analysis": {
    accepts: {
      scheme: "exact",
      payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
      price: {
        asset: USDC_TESTNET_ASA_ID,
        amount: "5000000",
        extra: { name: "USDC", decimals: 6 },
      },
      network: ALGORAND_TESTNET_CAIP2,
      maxTimeoutSeconds: 120,
    },
    description: "Expensive analysis endpoint",
    mimeType: "application/json",
  },
};

// x402HTTPResourceServer wraps a configured x402ResourceServer (no `.resourceServer` property)
const resourceServer = new x402ResourceServer(facilitatorClient);
resourceServer.register("algorand:*", new ExactAvmScheme());

const httpServer = new x402HTTPResourceServer(resourceServer, routes);
```

---

## Facilitator

```typescript
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { toFacilitatorAvmSigner, ALGORAND_TESTNET_CAIP2 } from "@x402/avm";
import type { PaymentPayload, PaymentRequirements } from "@x402/core/types";

// AVM_PRIVATE_KEY is the base64 of the 64-byte algosdk secret key (seed||pubkey), not a mnemonic
const facilitatorSigner = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!);

const facilitator = new x402Facilitator();

facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(facilitatorSigner));

async function handlePaymentVerification(
  paymentPayload: PaymentPayload,
  requirements: PaymentRequirements,
) {
  const verifyResult = await facilitator.verify(paymentPayload, requirements);

  if (verifyResult.isValid) {
    const settleResult = await facilitator.settle(paymentPayload, requirements);
    console.log("Settled in transaction:", settleResult.transaction);
    return settleResult;
  }

  return { success: false, errorReason: verifyResult.invalidReason, errorMessage: verifyResult.invalidMessage };
}
```

---

## HTTPFacilitatorClient

```typescript
import { HTTPFacilitatorClient } from "@x402/core/server";

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
});

const authenticatedClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
  headers: {
    Authorization: `Bearer ${process.env.FACILITATOR_API_KEY}`,
  },
});

const supported = await facilitatorClient.supported();
console.log("Supported networks:", supported.networks);

const verifyResult = await facilitatorClient.verify({
  paymentPayload,
  paymentRequirements,
});

const settleResult = await facilitatorClient.settle({
  paymentPayload,
  paymentRequirements,
});
```

---

## ClientAvmSigner Interface

```typescript
import type { ClientAvmSigner } from "@x402/avm";

interface ClientAvmSigner {
  address: string;
  signTransactions(
    txns: Uint8Array[],
    indexesToSign?: number[],
  ): Promise<(Uint8Array | null)[]>;
}

import { isAvmSignerWallet } from "@x402/avm";

function checkWallet(wallet: unknown) {
  if (isAvmSignerWallet(wallet)) {
    console.log("Address:", wallet.address);
  }
}
```

---

## ClientAvmSigner from Private Key

```typescript
import type { ClientAvmSigner } from "@x402/avm";
import algosdk from "algosdk";

function createPrivateKeySigner(privateKeyBase64: string): ClientAvmSigner {
  const secretKey = Buffer.from(privateKeyBase64, "base64");

  if (secretKey.length !== 64) {
    throw new Error(`Invalid key length: expected 64, got ${secretKey.length}`);
  }

  const address = algosdk.encodeAddress(secretKey.slice(32));

  return {
    address,
    signTransactions: async (
      txns: Uint8Array[],
      indexesToSign?: number[],
    ): Promise<(Uint8Array | null)[]> => {
      return txns.map((txnBytes, i) => {
        if (indexesToSign && !indexesToSign.includes(i)) {
          return null;
        }
        const decoded = algosdk.decodeUnsignedTransaction(txnBytes);
        const signed = algosdk.signTransaction(decoded, secretKey);
        return signed.blob;
      });
    },
  };
}

const signer = createPrivateKeySigner(process.env.AVM_PRIVATE_KEY!);
console.log("Signer address:", signer.address);
```

---

## FacilitatorAvmSigner Interface

```typescript
import type { FacilitatorAvmSigner } from "@x402/avm";
import type { Network } from "@x402/core/types"; // `${string}:${string}`
import type { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
// SimulateResponse / PendingTransactionResponse are the algokit-utils algod models

interface FacilitatorAvmSigner {
  getAddresses(): readonly string[];
  signTransaction(txn: Uint8Array, senderAddress: string): Promise<Uint8Array>;
  getAlgodClient(network: Network): AlgodClient; // algokit-utils AlgodClient, NOT algosdk.Algodv2
  simulateTransactions(txns: Uint8Array[], network: Network): Promise<SimulateResponse>;
  sendTransactions(signedTxns: Uint8Array[], network: Network): Promise<string>;
  waitForConfirmation(
    txId: string,
    network: Network,
    waitRounds?: number,
  ): Promise<PendingTransactionResponse>;
}
```

---

## Production FacilitatorAvmSigner

Use `toFacilitatorAvmSigner` from `@x402/avm`. It accepts the base64-encoded 64-byte algosdk secret key (seed‖pubkey) — a mnemonic is not accepted — and manages algokit-utils algod clients for TestNet and MainNet:

```typescript
import { toFacilitatorAvmSigner } from "@x402/avm";

const facilitatorSigner = toFacilitatorAvmSigner(
  process.env.AVM_PRIVATE_KEY!,
  {
    testnetUrl: "https://testnet-api.algonode.cloud",
    mainnetUrl: "https://mainnet-api.algonode.cloud",
    // algodToken: "...",
  },
);

console.log("Fee payer addresses:", facilitatorSigner.getAddresses());
```

If you must hand-roll a `FacilitatorAvmSigner`, `getAlgodClient` has to return an algokit-utils `AlgodClient` — for example `AlgorandClient.testNet().client.algod` from `@algorandfoundation/algokit-utils`. A signer built on `algosdk.Algodv2` does not type-check against the interface.

---

## Constants: Network Identifiers

```typescript
import {
  ALGORAND_MAINNET_CAIP2,
  ALGORAND_TESTNET_CAIP2,
  CAIP2_NETWORKS,
  ALGORAND_MAINNET_GENESIS_HASH,
  ALGORAND_TESTNET_GENESIS_HASH,
} from "@x402/avm";

// Only CAIP-2 identifiers are supported; there are no V1 ("algorand-testnet") constants
// or mapping tables, and normalizeAlgorandNetwork("algorand-testnet") throws.
```

---

## Constants: USDC Configuration

```typescript
import {
  ALGORAND_TESTNET_CAIP2,
  USDC_MAINNET_ASA_ID,
  USDC_TESTNET_ASA_ID,
  USDC_DECIMALS,
  DEFAULT_ASSETS,
  getDefaultAsset,
} from "@x402/avm";

// USDC_TESTNET_ASA_ID => "10458941", USDC_MAINNET_ASA_ID => "31566704", USDC_DECIMALS => 6
const testnetUsdc = getDefaultAsset(ALGORAND_TESTNET_CAIP2, "USDC");
console.log(testnetUsdc);
// { asset: "10458941", decimals: 6, symbol: "USDC" }

console.log(DEFAULT_ASSETS[ALGORAND_TESTNET_CAIP2]); // default USD assets per CAIP-2 network
```

---

## Algod Endpoints

`@x402/avm` exports no algod URL constants. Configure the node via `ClientAvmConfig.algodUrl` / `algodToken` (or pass an algokit `AlgorandClient`) on the client, and via `toFacilitatorAvmSigner(key, { testnetUrl, mainnetUrl, algodToken })` on the facilitator:

```typescript
import { AlgorandClient } from "@algorandfoundation/algokit-utils";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";

declare const signer: ClientAvmSigner;

// Option 1: explicit algod URL
const schemeWithUrl = new ExactAvmScheme(signer, {
  algodUrl: "https://testnet-api.algonode.cloud",
});

// Option 2: pre-configured algokit AlgorandClient
const schemeWithClient = new ExactAvmScheme(signer, {
  algorandClient: AlgorandClient.testNet(),
});
```

---

## Constants: Transaction Limits and Address Validation

```typescript
import {
  ALGORAND_MIN_TX_FEE,
  MAX_REASONABLE_FEE_PER_TXN,
  maxReasonableGroupFee,
  ALGORAND_ADDRESS_LENGTH,
  isValidAlgorandAddress,
} from "@x402/avm";

// Algorand protocol limit — not exported by @x402/avm
const MAX_ATOMIC_GROUP_SIZE = 16;

ALGORAND_MIN_TX_FEE;          // 1000 microAlgos (re-exported from algokit-utils)
MAX_REASONABLE_FEE_PER_TXN;   // 5000 microAlgos per transaction
maxReasonableGroupFee(2);     // 10000 — per-txn cap × group size
ALGORAND_ADDRESS_LENGTH;      // 58

const isValid = isValidAlgorandAddress(someAddress);
```

---

## Utility: Address Validation

```typescript
import { isValidAlgorandAddress } from "@x402/avm";

isValidAlgorandAddress("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
// => true

isValidAlgorandAddress("invalid");
// => false
```

---

## Utility: Amount Conversion

```typescript
import { convertToTokenAmount, convertFromTokenAmount } from "@x402/avm";

convertToTokenAmount("1.50", 6);     // => "1500000"
convertToTokenAmount("0.10", 6);     // => "100000"
convertToTokenAmount("100", 6);      // => "100000000"
convertToTokenAmount("0.000001", 6); // => "1"

convertFromTokenAmount("1500000", 6);   // => "1.5"
convertFromTokenAmount("100000", 6);    // => "0.1"
convertFromTokenAmount("1", 6);         // => "0.000001"
convertFromTokenAmount("100000000", 6); // => "100"
```

---

## Utility: Transaction Encoding/Decoding

```typescript
import {
  encodeTransaction,
  decodeTransaction,
  decodeSignedTransaction,
  decodeUnsignedTransaction,
} from "@x402/avm";

const base64Str = encodeTransaction(txnBytes);
// => "iaNhbXTOAAGGoKNm..."

const bytes = decodeTransaction(base64Str);
// => Uint8Array [...]

const signedTxn = decodeSignedTransaction(base64Str);
// => algosdk.SignedTransaction

const unsignedTxn = decodeUnsignedTransaction(base64Str);
// => algosdk.Transaction
```

---

## Utility: Network Functions

```typescript
import {
  ALGORAND_TESTNET_CAIP2,
  ALGORAND_MAINNET_CAIP2,
  getNetworkFromCaip2,
  isAlgorandNetwork,
  isTestnetNetwork,
  normalizeAlgorandNetwork,
} from "@x402/avm";

getNetworkFromCaip2(ALGORAND_TESTNET_CAIP2);
// => "testnet"

getNetworkFromCaip2(ALGORAND_MAINNET_CAIP2);
// => "mainnet"

getNetworkFromCaip2("eip155:8453");
// => null

isAlgorandNetwork(ALGORAND_TESTNET_CAIP2);
// => true

isAlgorandNetwork("algorand-testnet");
// => false (only "algorand:<caip2-ref>" identifiers are recognized)

isAlgorandNetwork("eip155:8453");
// => false

isTestnetNetwork(ALGORAND_TESTNET_CAIP2);
// => true

// Accepts both the 32-char CAIP-2 form and the legacy full-genesis-hash form,
// and returns the canonical constant. Throws on v1 names like "algorand-testnet".
normalizeAlgorandNetwork("algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=");
// => ALGORAND_TESTNET_CAIP2

// There are no v1ToCaip2 / caip2ToV1 / createAlgodClient helpers. For an algod client use algokit-utils:
// import { AlgorandClient } from "@algorandfoundation/algokit-utils";
// const algod = AlgorandClient.testNet().client.algod;
```

---

## Utility: Transaction Inspection

```typescript
import {
  getSenderFromTransaction,
  getTransactionId,
  hasSignature,
  getGenesisHashFromTransaction,
  validateGroupId,
} from "@x402/avm";
import { groupTransactions } from "@algorandfoundation/algokit-utils/transact";

const sender = getSenderFromTransaction(signedTxnBytes, true);
const senderUnsigned = getSenderFromTransaction(unsignedTxnBytes, false);

const txId = getTransactionId(signedTxnBytes);

const signed = hasSignature(txnBytes);

const allMatch = validateGroupId([txn1Bytes, txn2Bytes, txn3Bytes]);

// @x402/avm has no assignGroupId — group with algokit-utils (or algosdk.assignGroupID)
const groupedTxns = groupTransactions([txn1, txn2, txn3]);
```

---

## Simple Payment Group

```typescript
import { AlgorandClient } from "@algorandfoundation/algokit-utils";
import { encodeTransaction } from "@algorandfoundation/algokit-utils/transact";
import { USDC_TESTNET_ASA_ID } from "@x402/avm";

async function createSimplePayment(
  senderAddress: string,
  receiverAddress: string,
  amount: bigint,
) {
  // @x402/avm has no createAlgodClient — build raw transactions with algokit-utils
  const algorand = AlgorandClient.testNet();

  const txn = await algorand.createTransaction.assetTransfer({
    sender: senderAddress,
    receiver: receiverAddress,
    assetId: BigInt(USDC_TESTNET_ASA_ID),
    amount,
  });

  return [encodeTransaction(txn)];
}
```

---

## Fee-Abstracted Payment Group

```typescript
import { AlgorandClient, microAlgo } from "@algorandfoundation/algokit-utils";
import {
  encodeTransaction as encodeTxnBytes,
  groupTransactions,
} from "@algorandfoundation/algokit-utils/transact";
import {
  USDC_TESTNET_ASA_ID,
  ALGORAND_MIN_TX_FEE,
  encodeTransaction, // Uint8Array -> base64 (x402 wire format)
} from "@x402/avm";

async function createFeeAbstractedPayment(
  senderAddress: string,
  receiverAddress: string,
  feePayerAddress: string,
  amount: bigint,
) {
  const algorand = AlgorandClient.testNet();

  // Payer's asset transfer with fee 0 — the fee payer covers it
  const paymentTxn = await algorand.createTransaction.assetTransfer({
    sender: senderAddress,
    receiver: receiverAddress,
    assetId: BigInt(USDC_TESTNET_ASA_ID),
    amount,
    staticFee: microAlgo(0),
  });

  // Fee payer's 0-ALGO self-payment carrying the fee for both transactions
  const feePayerTxn = await algorand.createTransaction.payment({
    sender: feePayerAddress,
    receiver: feePayerAddress,
    amount: microAlgo(0),
    staticFee: microAlgo(ALGORAND_MIN_TX_FEE.microAlgo * 2n),
  });

  const grouped = groupTransactions([paymentTxn, feePayerTxn]);

  const paymentBytes = encodeTxnBytes(grouped[0]);
  const feePayerBytes = encodeTxnBytes(grouped[1]);

  return {
    paymentGroup: [
      encodeTransaction(paymentBytes),
      encodeTransaction(feePayerBytes),
    ],
    paymentIndex: 0,
    rawBytes: [paymentBytes, feePayerBytes],
  };
}
```

---

## Fee Abstraction with x402Client

```typescript
import { x402Client } from "@x402/core/client";
import { wrapFetchWithPayment } from "@x402/fetch";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";
import algosdk from "algosdk";

const signer: ClientAvmSigner = {
  address: myAddress,
  signTransactions: async (txns, indexesToSign) => {
    return txns.map((txn, i) => {
      if (indexesToSign && !indexesToSign.includes(i)) return null;
      const decoded = algosdk.decodeUnsignedTransaction(txn);
      return algosdk.signTransaction(decoded, secretKey).blob;
    });
  },
};

const client = new x402Client();
client.register("algorand:*", new ExactAvmScheme(signer));
const fetchWithPayment = wrapFetchWithPayment(fetch, client);

// Fee abstraction is automatic when PaymentRequirements include a feePayer
const response = await fetchWithPayment("https://api.example.com/paid-resource");
```

---

## ExactAvmScheme Registration: Client

```typescript
import { x402Client } from "@x402/core/client";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const client = new x402Client();

client.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(myClientSigner));
```

---

## ExactAvmScheme Registration: Server

```typescript
import { x402ResourceServer } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const server = new x402ResourceServer(facilitatorClient);

server.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme());

// Or with wildcard (default)
server.register("algorand:*", new ExactAvmScheme());
```

---

## ExactAvmScheme Registration: Facilitator

```typescript
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2 } from "@x402/avm";

const facilitator = new x402Facilitator();

facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(myFacilitatorSigner));

facilitator.register([ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2], new ExactAvmScheme(myFacilitatorSigner));
```

---

## Complete End-to-End: Full Stack

```typescript
// ============================================================
// shared/config.ts
// ============================================================
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

export const NETWORK = ALGORAND_TESTNET_CAIP2;
export const USDC_ASA = USDC_TESTNET_ASA_ID;
export const RESOURCE_WALLET = "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA";
export const FACILITATOR_URL = "http://localhost:4000";
export const RESOURCE_SERVER_URL = "http://localhost:3000";

// ============================================================
// facilitator/index.ts
// ============================================================
import express from "express";
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { toFacilitatorAvmSigner } from "@x402/avm";
import { NETWORK } from "../shared/config";

// AVM_PRIVATE_KEY: base64 of the 64-byte algosdk secret key (seed||pubkey), not a mnemonic
const signer = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!);

const facilitator = new x402Facilitator();
facilitator.register(NETWORK, new ExactAvmScheme(signer));

const app = express();
app.use(express.json());

app.get("/supported", async (_req, res) => {
  const supported = facilitator.getSupported();
  res.json(supported);
});

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

app.listen(4000, () => console.log("Facilitator running on :4000"));

// ============================================================
// server/index.ts
// ============================================================
import express from "express";
import {
  x402ResourceServer,
  x402HTTPResourceServer,
  HTTPFacilitatorClient,
} from "@x402/core/server";
import type { RoutesConfig } from "@x402/core/server";
import { ExpressAdapter } from "@x402/express";
import { ExactAvmScheme as ServerExactAvmScheme } from "@x402/avm/exact/server";
import {
  NETWORK,
  USDC_ASA,
  RESOURCE_WALLET,
  FACILITATOR_URL,
} from "../shared/config";

const facilitatorClient = new HTTPFacilitatorClient({ url: FACILITATOR_URL });

const resourceServer = new x402ResourceServer(facilitatorClient);
resourceServer.register("algorand:*", new ServerExactAvmScheme());

// Route pattern is the RoutesConfig key; RouteConfig has no `path`
const routes: RoutesConfig = {
  "GET /api/weather": {
    accepts: {
      scheme: "exact",
      payTo: RESOURCE_WALLET,
      price: { asset: USDC_ASA, amount: "10000", extra: { name: "USDC", decimals: 6 } },
      network: NETWORK,
      maxTimeoutSeconds: 60,
    },
    description: "Weather data API",
    mimeType: "application/json",
  },
};

const httpServer = new x402HTTPResourceServer(resourceServer, routes);

const app = express();

// Manual integration (prefer `paymentMiddleware(routes, resourceServer)` from @x402/express)
app.get("/api/weather", async (req, res) => {
  const result = await httpServer.processHTTPRequest({
    adapter: new ExpressAdapter(req),
    path: req.path,
    method: req.method,
    paymentHeader: req.header("payment-signature"),
  });

  if (result.type === "payment-error") {
    return res.status(result.response.status).set(result.response.headers).json(result.response.body ?? {});
  }

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

  res.json({
    temperature: 72,
    condition: "Sunny",
    location: "San Francisco",
  });
});

app.listen(3000, () => console.log("Resource server running on :3000"));

// ============================================================
// client/index.ts
// ============================================================
import { x402Client } from "@x402/core/client";
import { wrapFetchWithPayment } from "@x402/fetch";
import { ExactAvmScheme as ClientExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";
import algosdk from "algosdk";
import { RESOURCE_SERVER_URL } from "../shared/config";

const clientSecretKey = Buffer.from(process.env.CLIENT_AVM_PRIVATE_KEY!, "base64");
const clientAddress = algosdk.encodeAddress(clientSecretKey.slice(32));

const clientSigner: ClientAvmSigner = {
  address: clientAddress,
  signTransactions: async (txns, indexesToSign) => {
    return txns.map((txn, i) => {
      if (indexesToSign && !indexesToSign.includes(i)) return null;
      const decoded = algosdk.decodeUnsignedTransaction(txn);
      return algosdk.signTransaction(decoded, clientSecretKey).blob;
    });
  },
};

const client = new x402Client();
client.register("algorand:*", new ClientExactAvmScheme(clientSigner));
const fetchWithPayment = wrapFetchWithPayment(fetch, client);

async function getWeather() {
  const response = await fetchWithPayment(`${RESOURCE_SERVER_URL}/api/weather`);

  if (response.ok) {
    const weather = await response.json();
    console.log("Weather:", weather);
  } else {
    console.error("Failed:", response.status, response.statusText);
  }
}

getWeather();
```

---

## Node.js Facilitator Service

```typescript
import express from "express";
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2 } from "@x402/avm";
import { toFacilitatorAvmSigner } from "@x402/avm";

// AVM_PRIVATE_KEY: base64 of the 64-byte algosdk secret key (seed||pubkey), not a mnemonic
const signer = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!, {
  testnetUrl: process.env.ALGOD_TESTNET_URL,
  mainnetUrl: process.env.ALGOD_MAINNET_URL,
});
const [address] = signer.getAddresses();

const facilitator = new x402Facilitator();
facilitator.register([ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2], new ExactAvmScheme(signer));

const app = express();
app.use(express.json({ limit: "1mb" }));

app.get("/supported", async (_req, res) => {
  try {
    res.json(facilitator.getSupported());
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

app.post("/verify", async (req, res) => {
  try {
    const { paymentPayload, paymentRequirements } = req.body;
    const result = await facilitator.verify(paymentPayload, paymentRequirements);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

app.post("/settle", async (req, res) => {
  try {
    const { paymentPayload, paymentRequirements } = req.body;
    const result = await facilitator.settle(paymentPayload, paymentRequirements);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

const PORT = parseInt(process.env.PORT || "4000", 10);
app.listen(PORT, () => {
  console.log(`Facilitator service running on port ${PORT}`);
  console.log(`Fee payer address: ${address}`);
  console.log(`Networks: Testnet + Mainnet`);
});
```
