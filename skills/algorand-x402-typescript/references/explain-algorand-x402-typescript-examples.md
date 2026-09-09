# x402-avm TypeScript Examples

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

// Only CAIP-2 identifiers are supported. Legacy v1 names ("algorand-testnet")
// are not exported and normalizeAlgorandNetwork() throws on them.
const normalized: Network = normalizeAlgorandNetwork(ALGORAND_TESTNET_CAIP2);
```

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
```

## PaymentPayload

```typescript
import type { PaymentPayload, PaymentRequirements } from "@x402/core/types";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

// V2 PaymentPayload has no top-level `scheme` / `network` — they live in `accepted`
// (the PaymentRequirements the client chose from the 402 response).
const accepted: PaymentRequirements = {
  scheme: "exact",
  network: ALGORAND_TESTNET_CAIP2,
  asset: USDC_TESTNET_ASA_ID,
  amount: "1000000",
  payTo: "RECEIVER_ALGORAND_ADDRESS_58_CHARS_AAAAAAAAAAAAAAAAAAA",
  maxTimeoutSeconds: 60,
  extra: {},
};

const payload: PaymentPayload = {
  x402Version: 2,
  accepted,
  payload: {
    paymentGroup: [
      "iaNhbXTOAAGGoKNm...",
      "iaNhbXTOAAGGoKNm...",
    ],
    paymentIndex: 0,
  },
};
```

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
```

## ClientAvmSigner with @txnlab/use-wallet (Browser)

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

## Full React Example with Wallet

```typescript
import React, { useCallback } from "react";
import { x402Client } from "@x402/core/client";
import { wrapFetchWithPayment } from "@x402/fetch";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";
import { WalletProvider, useWallet, WalletManager, NetworkId } from "@txnlab/use-wallet-react";
import { pera } from "@txnlab/use-wallet-pera";
import { defly } from "@txnlab/use-wallet-defly";

// use-wallet 5.x: wallets are adapter packages (@txnlab/use-wallet-pera, -defly, ...)
const walletManager = new WalletManager({
  wallets: [pera(), defly()],
  defaultNetwork: NetworkId.TESTNET,
});

function PaidContent() {
  const { activeAccount, signTransactions } = useWallet();

  const fetchPaidResource = useCallback(async () => {
    if (!activeAccount) return;

    const signer: ClientAvmSigner = {
      address: activeAccount.address,
      signTransactions: async (txns, indexes) => signTransactions(txns, indexes),
    };

    const client = new x402Client();
    client.register("algorand:*", new ExactAvmScheme(signer));
    const fetchWithPayment = wrapFetchWithPayment(fetch, client);

    const response = await fetchWithPayment("https://api.example.com/premium");
    if (response.ok) {
      const data = await response.json();
      console.log("Data:", data);
    }
  }, [activeAccount, signTransactions]);

  return (
    <button onClick={fetchPaidResource} disabled={!activeAccount}>
      Fetch Paid Resource
    </button>
  );
}

export default function App() {
  return (
    <WalletProvider manager={walletManager}>
      <PaidContent />
    </WalletProvider>
  );
}
```

## ClientAvmSigner with algosdk Private Key (Server-Side)

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
```

## FacilitatorAvmSigner Interface

```typescript
import type { FacilitatorAvmSigner } from "@x402/avm";
import type { Network } from "@x402/core/types";

import type { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
// SimulateResponse / PendingTransactionResponse are the algokit-utils algod models

interface FacilitatorAvmSigner {
  getAddresses(): readonly string[];
  signTransaction(txn: Uint8Array, senderAddress: string): Promise<Uint8Array>;
  getAlgodClient(network: Network): AlgodClient; // algokit-utils AlgodClient, NOT algosdk.Algodv2
  simulateTransactions(txns: Uint8Array[], network: Network): Promise<SimulateResponse>;
  sendTransactions(signedTxns: Uint8Array[], network: Network): Promise<string>;
  waitForConfirmation(txId: string, network: Network, waitRounds?: number): Promise<PendingTransactionResponse>;
}
```

## FacilitatorAvmSigner Implementation

Use the built-in helper rather than hand-rolling the interface. It takes the base64-encoded 64-byte algosdk secret key (seed‖pubkey) — not a mnemonic — and manages algokit-utils algod clients for TestNet and MainNet:

```typescript
import { toFacilitatorAvmSigner } from "@x402/avm";

const facilitatorSigner = toFacilitatorAvmSigner(process.env.AVM_PRIVATE_KEY!, {
  // optional overrides
  testnetUrl: process.env.ALGOD_TESTNET_URL,
  mainnetUrl: process.env.ALGOD_MAINNET_URL,
  algodToken: process.env.ALGOD_TOKEN,
});
```

If you must implement `FacilitatorAvmSigner` manually, `getAlgodClient` must return an algokit-utils `AlgodClient` (e.g. `AlgorandClient.testNet().client.algod` from `@algorandfoundation/algokit-utils`); an `algosdk.Algodv2` instance does not satisfy the type.

## Client Registration

```typescript
import { x402Client } from "@x402/core/client";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

// Optional ctor arg is a selector function: (x402Version, requirements) => PaymentRequirements
const client = new x402Client();

client.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(myClientSigner));
```

## Server Registration

```typescript
import { x402ResourceServer } from "@x402/core/server";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { ALGORAND_TESTNET_CAIP2 } from "@x402/avm";

const server = new x402ResourceServer(facilitatorClient);

// Wildcard (default -- all Algorand networks)
server.register("algorand:*", new ExactAvmScheme());

// Or a specific network
server.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme());
```

## Facilitator Registration

```typescript
import { x402Facilitator } from "@x402/core/facilitator";
import { ExactAvmScheme } from "@x402/avm/exact/facilitator";
import { ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2 } from "@x402/avm";

const facilitator = new x402Facilitator();

// Single network
facilitator.register(ALGORAND_TESTNET_CAIP2, new ExactAvmScheme(myFacilitatorSigner));

// Multiple networks
facilitator.register([ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2], new ExactAvmScheme(myFacilitatorSigner));
```

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
  return requirements.filter(r => parseInt(r.amount, 10) <= MAX_USDC);
};

const preferAlgorand: PaymentPolicy = (version, requirements) => {
  const algorandOptions = requirements.filter(r => r.network.startsWith("algorand:"));
  return algorandOptions.length > 0 ? algorandOptions : requirements;
};

const client = new x402Client();
client.register("algorand:*", new ExactAvmScheme(signer));

client.registerPolicy(preferAlgorand);
```

## Constants

```typescript
import {
  ALGORAND_MAINNET_CAIP2,
  ALGORAND_TESTNET_CAIP2,
  CAIP2_NETWORKS,
  ALGORAND_MAINNET_GENESIS_HASH,
  ALGORAND_TESTNET_GENESIS_HASH,
  USDC_MAINNET_ASA_ID,
  USDC_TESTNET_ASA_ID,
  USDC_DECIMALS,
  DEFAULT_ASSETS,
  ALGORAND_MIN_TX_FEE,
  MAX_REASONABLE_FEE_PER_TXN,
  maxReasonableGroupFee,
  ALGORAND_ADDRESS_LENGTH,
} from "@x402/avm";

// Algorand protocol limit on atomic group size (not exported by @x402/avm)
const MAX_ATOMIC_GROUP_SIZE = 16;
```

There are no exported algod URL constants — pass `algodUrl` via `ClientAvmConfig` or use algokit-utils `AlgorandClient.testNet()`.

## Utility Functions

```typescript
import {
  ALGORAND_TESTNET_CAIP2,
  isValidAlgorandAddress,
  convertToTokenAmount,
  convertFromTokenAmount,
  encodeTransaction,
  decodeTransaction,
  decodeSignedTransaction,
  decodeUnsignedTransaction,
  getNetworkFromCaip2,
  isAlgorandNetwork,
  isTestnetNetwork,
  normalizeAlgorandNetwork,
  getSenderFromTransaction,
  getTransactionId,
  hasSignature,
  validateGroupId,
} from "@x402/avm";
import { AlgorandClient } from "@algorandfoundation/algokit-utils";

// Address validation
isValidAlgorandAddress("AAAA...AAAA"); // => true/false

// Amount conversion
convertToTokenAmount("1.50", 6);     // => "1500000"
convertFromTokenAmount("1500000", 6); // => "1.5"

// Network checks
isAlgorandNetwork(ALGORAND_TESTNET_CAIP2); // => true
isTestnetNetwork(ALGORAND_TESTNET_CAIP2);  // => true
getNetworkFromCaip2(ALGORAND_TESTNET_CAIP2); // => "testnet"
normalizeAlgorandNetwork(ALGORAND_TESTNET_CAIP2); // CAIP-2 only; throws on v1 names like "algorand-testnet"

// Algod client (no helper in @x402/avm — use algokit-utils)
const algorand = AlgorandClient.testNet();
const algod = algorand.client.algod;
```

Only CAIP-2 network identifiers are supported; there is no v1 ↔ CAIP-2 mapping API (`v1ToCaip2` / `caip2ToV1` do not exist). Group IDs are assigned with algokit-utils `TransactionComposer` or algosdk `assignGroupID`.

## HTTPFacilitatorClient

```typescript
import { HTTPFacilitatorClient } from "@x402/core/server";

const facilitatorClient = new HTTPFacilitatorClient({
  url: "https://facilitator.goplausible.xyz",
});

const authenticatedClient = new HTTPFacilitatorClient({
  url: "https://facilitator.example.com",
  headers: {
    Authorization: `Bearer ${process.env.FACILITATOR_API_KEY}`,
  },
});

const supported = await facilitatorClient.supported();
const verifyResult = await facilitatorClient.verify({ paymentPayload, paymentRequirements });
const settleResult = await facilitatorClient.settle({ paymentPayload, paymentRequirements });
```

## Type Guard

```typescript
import { isAvmSignerWallet } from "@x402/avm";

function checkWallet(wallet: unknown) {
  if (isAvmSignerWallet(wallet)) {
    console.log("Address:", wallet.address);
  }
}
```

## Transaction Group Creation (Simple Payment)

```typescript
import { AlgorandClient } from "@algorandfoundation/algokit-utils";
import { encodeTransaction } from "@algorandfoundation/algokit-utils/transact";
import { USDC_TESTNET_ASA_ID } from "@x402/avm";

async function createSimplePayment(senderAddress: string, receiverAddress: string, amount: number) {
  const algorand = AlgorandClient.testNet();

  // algokit-utils param is `sender` (not `from`)
  const txn = await algorand.createTransaction.assetTransfer({
    sender: senderAddress,
    receiver: receiverAddress,
    assetId: BigInt(USDC_TESTNET_ASA_ID),
    amount: BigInt(amount),
  });

  return [encodeTransaction(txn)]; // raw msgpack bytes
}
```

## Fee-Abstracted Payment Group

```typescript
import algosdk from "algosdk";
import {
  USDC_TESTNET_ASA_ID,
  ALGORAND_MIN_TX_FEE,
  encodeTransaction,
} from "@x402/avm";

async function createFeeAbstractedPayment(
  senderAddress: string,
  receiverAddress: string,
  feePayerAddress: string,
  amount: number,
) {
  // @x402/avm exports no algod URL constants / client factory — construct one directly
  const algod = new algosdk.Algodv2("", "https://testnet-api.algonode.cloud", "");
  const params = await algod.getTransactionParams().do();

  // algosdk 3.x uses `sender` / `receiver` (not `from` / `to`)
  const paymentTxn = algosdk.makeAssetTransferTxnWithSuggestedParamsFromObject({
    sender: senderAddress,
    receiver: receiverAddress,
    amount,
    assetIndex: parseInt(USDC_TESTNET_ASA_ID, 10),
    suggestedParams: { ...params, fee: 0, flatFee: true },
  });

  const feePayerTxn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
    sender: feePayerAddress,
    receiver: feePayerAddress,
    amount: 0,
    // ALGORAND_MIN_TX_FEE is an algokit-utils AlgoAmount (re-exported by @x402/avm)
    suggestedParams: { ...params, fee: ALGORAND_MIN_TX_FEE.microAlgo * 2n, flatFee: true },
  });

  const grouped = algosdk.assignGroupID([paymentTxn, feePayerTxn]);

  return {
    paymentGroup: [
      encodeTransaction(grouped[0].toByte()),
      encodeTransaction(grouped[1].toByte()),
    ],
    paymentIndex: 0,
  };
}
```

## Complete End-to-End (Client + Server + Facilitator)

```typescript
// ---- shared/config.ts ----
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";

export const NETWORK = ALGORAND_TESTNET_CAIP2;
export const USDC_ASA = USDC_TESTNET_ASA_ID;
export const RESOURCE_WALLET = "RECEIVER_ALGORAND_ADDRESS_58_CHARS";
export const FACILITATOR_URL = "http://localhost:4020";
export const RESOURCE_SERVER_URL = "http://localhost:4021";

// ---- server/index.ts ----
import express from "express";
import { paymentMiddleware, x402ResourceServer } from "@x402/express";
import { ExactAvmScheme } from "@x402/avm/exact/server";
import { HTTPFacilitatorClient } from "@x402/core/server";
import type { RoutesConfig } from "@x402/core/server";
import { NETWORK, USDC_ASA, RESOURCE_WALLET, FACILITATOR_URL } from "../shared/config";

const facilitatorClient = new HTTPFacilitatorClient({ url: FACILITATOR_URL });
const server = new x402ResourceServer(facilitatorClient);
server.register("algorand:*", new ExactAvmScheme());

const routes: RoutesConfig = {
  "GET /api/weather": {
    accepts: {
      scheme: "exact",
      network: NETWORK,
      payTo: RESOURCE_WALLET,
      price: "$0.01",
    },
    description: "Weather data",
  },
};

const app = express();
app.use(paymentMiddleware(routes, server));
app.get("/api/weather", (req, res) => res.json({ temperature: 72, condition: "Sunny" }));
app.listen(4021);

// ---- client/index.ts ----
import { x402Client } from "@x402/core/client";
import { wrapFetchWithPayment } from "@x402/fetch";
import { ExactAvmScheme } from "@x402/avm/exact/client";
import type { ClientAvmSigner } from "@x402/avm";
import algosdk from "algosdk";
import { RESOURCE_SERVER_URL } from "../shared/config";

const secretKey = Buffer.from(process.env.AVM_PRIVATE_KEY!, "base64");
const clientSigner: ClientAvmSigner = {
  address: algosdk.encodeAddress(secretKey.slice(32)),
  signTransactions: async (txns, indexesToSign) => {
    return txns.map((txn, i) => {
      if (indexesToSign && !indexesToSign.includes(i)) return null;
      return algosdk.signTransaction(algosdk.decodeUnsignedTransaction(txn), secretKey).blob;
    });
  },
};

const client = new x402Client();
client.register("algorand:*", new ExactAvmScheme(clientSigner));
const fetchWithPayment = wrapFetchWithPayment(fetch, client);

const response = await fetchWithPayment(`${RESOURCE_SERVER_URL}/api/weather`);
if (response.ok) {
  console.log("Weather:", await response.json());
}
```

## Component Import Summary

```typescript
// Core
import { x402Client } from "@x402/core/client";
import { x402ResourceServer, x402HTTPResourceServer, HTTPFacilitatorClient } from "@x402/core/server";
import { x402Facilitator } from "@x402/core/facilitator";
import type { PaymentRequirements, PaymentPayload, PaymentRequired, Network } from "@x402/core/types";

// AVM Registration (same class name on three subpaths — alias if one file needs more than one role)
import { ExactAvmScheme as ExactAvmClientScheme } from "@x402/avm/exact/client";
import { ExactAvmScheme as ExactAvmServerScheme } from "@x402/avm/exact/server";
import { ExactAvmScheme as ExactAvmFacilitatorScheme } from "@x402/avm/exact/facilitator";

// AVM Types and Constants
import type { ClientAvmSigner, FacilitatorAvmSigner } from "@x402/avm";
import { ALGORAND_TESTNET_CAIP2, USDC_TESTNET_ASA_ID } from "@x402/avm";
```
