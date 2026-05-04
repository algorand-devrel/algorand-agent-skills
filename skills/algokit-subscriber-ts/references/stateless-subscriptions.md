## Stateless subscriptions

These examples show how to use `getSubscribedTransactions` for stateless,
single-poll subscription patterns — ideal for serverless functions, cron jobs,
or any context where you manage the watermark externally.

### Single poll with getSubscribedTransactions

Call `getSubscribedTransactions` once to fetch matching transactions since a
given watermark:

```typescript
import { getSubscribedTransactions } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";

const algod = new AlgodClient({ baseUrl: "http://localhost:4001", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });

const result = await getSubscribedTransactions(
  {
    watermark: 0n,
    syncBehaviour: "skip-sync-newest",
    filters: [
      {
        name: "payments",
        filter: {
          type: "pay",
          receiver: "RECEIVERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARW4HHF",
        },
      },
    ],
  },
  algod,
);

console.log(`Synced rounds ${result.syncedRoundRange[0]}–${result.syncedRoundRange[1]}`);
console.log(`Found ${result.subscribedTransactions.length} matching transactions`);
console.log(`New watermark: ${result.newWatermark}`);
```

**What just happened:** `getSubscribedTransactions` executed a single
subscription poll starting from watermark `0n`. It accepts a
`TransactionSubscriptionParams` object (with `watermark`, `syncBehaviour`, and
`filters`), an `AlgodClient`, and an optional `IndexerClient`. It returns a
`TransactionSubscriptionResult` containing `subscribedTransactions`,
`newWatermark`, `syncedRoundRange`, `currentRound`, and `startingWatermark`. No
class instantiation is needed — the function is fully stateless.

### Manage watermark between calls

Extract `newWatermark` from each result and pass it into the next invocation to
process transactions incrementally:

```typescript
import { getSubscribedTransactions } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
import fs from "fs/promises";

const algod = new AlgodClient({ baseUrl: "http://localhost:4001", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });
const watermarkFile = "./watermark.txt";

async function loadWatermark(): Promise<bigint> {
  try {
    const content = await fs.readFile(watermarkFile, "utf-8");
    return BigInt(content.trim());
  } catch {
    return 0n;
  }
}

async function saveWatermark(watermark: bigint): Promise<void> {
  await fs.writeFile(watermarkFile, watermark.toString(), "utf-8");
}

const watermark = await loadWatermark();

const result = await getSubscribedTransactions(
  {
    watermark,
    syncBehaviour: "sync-oldest",
    maxRoundsToSync: 1000,
    filters: [
      {
        name: "app-calls",
        filter: {
          appId: 1284326447n,
        },
      },
    ],
  },
  algod,
);

// Process transactions before persisting watermark
for (const txn of result.subscribedTransactions) {
  console.log(`Matched txn ${txn.id} in round ${txn.confirmedRound}`);
}

// Only persist after successful processing
await saveWatermark(result.newWatermark);
```

**What just happened:** The watermark is loaded from a file before calling
`getSubscribedTransactions` and saved after all matched transactions are
processed. This ensures incremental syncing — each invocation resumes from where
the last one left off. `maxRoundsToSync: 1000` caps how many rounds are fetched
per call, and `syncBehaviour: "sync-oldest"` processes from the oldest unsynced
round forward. Critically, the watermark is only persisted after processing
completes — if the process crashes mid-way, the next invocation will re-process
the same range.

### Use in a serverless function

Wrap `getSubscribedTransactions` in a Lambda/Cloud Function handler with an
external watermark store (e.g. a database):

```typescript
import { getSubscribedTransactions } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
import { db } from "./db"; // your database client

const algod = new AlgodClient({ baseUrl: "https://mainnet-api.4160.nodely.dev", token: "" });

export async function handler() {
  // Load watermark from external store
  const row = await db.query("SELECT watermark FROM subscriber_state WHERE id = 'main'");
  const watermark = row ? BigInt(row.watermark) : 0n;

  const result = await getSubscribedTransactions(
    {
      watermark,
      syncBehaviour: "sync-oldest",
      maxRoundsToSync: 500,
      filters: [
        {
          name: "asset-transfers",
          filter: {
            type: "axfer",
            assetId: 123456n,
            minAmount: 1_000_000n,
          },
        },
      ],
    },
    algod,
  );

  // Process matched transactions
  for (const txn of result.subscribedTransactions) {
    await db.query(
      "INSERT INTO tracked_transfers (tx_id, round, sender, amount) VALUES ($1, $2, $3, $4)",
      [txn.id, txn.confirmedRound?.toString(), txn.sender, txn.assetTransferTransaction?.amount?.toString()],
    );
  }

  // Persist watermark atomically after processing
  await db.query(
    "INSERT INTO subscriber_state (id, watermark) VALUES ('main', $1) ON CONFLICT (id) DO UPDATE SET watermark = $1",
    [result.newWatermark.toString()],
  );

  return {
    statusCode: 200,
    body: JSON.stringify({
      processed: result.subscribedTransactions.length,
      newWatermark: result.newWatermark.toString(),
      roundRange: result.syncedRoundRange.map(String),
    }),
  };
}
```

**What just happened:** The serverless handler loads the watermark from a
database, calls `getSubscribedTransactions` to fetch matching transactions,
writes them to the database, then persists the new watermark. This pattern works
with AWS Lambda, Google Cloud Functions, or any stateless runtime — trigger it
on a schedule (e.g. every minute via CloudWatch/Cloud Scheduler) and it will
incrementally process new transactions each invocation. The watermark is stored
externally so state survives across cold starts. `maxRoundsToSync: 500` keeps
each invocation's work bounded so it completes within typical serverless timeout
limits.
