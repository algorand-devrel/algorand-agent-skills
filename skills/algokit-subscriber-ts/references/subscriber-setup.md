## Subscriber setup

These examples show how to create and configure an `AlgorandSubscriber` instance
with different watermark persistence strategies and polling options.

### Create with in-memory watermark

The simplest setup stores the watermark in a variable. Suitable for short-lived
processes or development:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";

const algod = new AlgodClient({ baseUrl: "http://localhost:4001", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });

let watermark = 0n;

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "my-app-calls",
        filter: {
          sender: "SENDERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHB4E",
        },
      },
    ],
    syncBehaviour: "skip-sync-newest",
    watermarkPersistence: {
      get: async () => watermark,
      set: async (newWatermark) => {
        watermark = newWatermark;
      },
    },
  },
  algod,
);
```

**What just happened:** An `AlgorandSubscriber` was created with a single named
filter that matches transactions from a specific sender. The watermark is stored
in a local `bigint` variable — `get` returns it and `set` updates it after each
poll. `syncBehaviour: "skip-sync-newest"` means if the subscriber is behind it
will skip to the current tip and only process new blocks going forward.

### Create with file-based watermark

Persist the watermark to a file so it survives process restarts:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
import fs from "fs/promises";

const algod = new AlgodClient({ baseUrl: "http://localhost:4001", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });
const watermarkFile = "./watermark.txt";

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "asset-transfers",
        filter: {
          type: "axfer",
          assetId: 123456n,
        },
      },
    ],
    syncBehaviour: "sync-oldest",
    watermarkPersistence: {
      get: async () => {
        try {
          const content = await fs.readFile(watermarkFile, "utf-8");
          return BigInt(content.trim());
        } catch {
          return 0n;
        }
      },
      set: async (newWatermark) => {
        await fs.writeFile(watermarkFile, newWatermark.toString(), "utf-8");
      },
    },
  },
  algod,
);
```

**What just happened:** The watermark is read from and written to a local file.
On first run (or if the file is missing) `get` returns `0n` so the subscriber
starts from the beginning. `set` writes the new watermark after each poll so the
subscriber resumes where it left off on restart. The filter matches asset
transfer transactions (`axfer`) for a specific asset ID.

### Create with database watermark

For production deployments, persist the watermark with an async database call:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
import { IndexerClient } from "@algorandfoundation/algokit-utils/indexer-client";
import { db } from "./db"; // your database client

const algod = new AlgodClient({ baseUrl: "https://mainnet-api.4160.nodely.dev", token: "" });
const indexer = new IndexerClient({ baseUrl: "https://mainnet-idx.4160.nodely.dev", token: "" });

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "app-calls",
        filter: {
          appId: 1284326447n,
        },
      },
    ],
    syncBehaviour: "catchup-with-indexer",
    watermarkPersistence: {
      get: async () => {
        const row = await db.query("SELECT watermark FROM subscriber_state WHERE id = 'main'");
        return row ? BigInt(row.watermark) : 0n;
      },
      set: async (newWatermark) => {
        await db.query(
          "INSERT INTO subscriber_state (id, watermark) VALUES ('main', $1) ON CONFLICT (id) DO UPDATE SET watermark = $1",
          [newWatermark.toString()],
        );
      },
    },
  },
  algod,
  indexer,
);
```

**What just happened:** The watermark is stored in a database table using upsert
semantics. `get` queries for the current value (defaulting to `0n` if no row
exists) and `set` inserts or updates the row after each poll. Since
`syncBehaviour` is `"catchup-with-indexer"`, the subscriber uses the indexer for
fast historical sync and then switches to algod for real-time blocks — this
requires passing an `IndexerClient` as the third constructor argument.

### Configure polling and block wait

Tune how often the subscriber polls and how it behaves when caught up to the tip:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "payments",
        filter: {
          type: "pay",
          receiver: "RECEIVERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARW4HHF",
        },
      },
    ],
    syncBehaviour: "skip-sync-newest",
    frequencyInSeconds: 5,
    waitForBlockWhenAtTip: true,
    watermarkPersistence: {
      get: async () => watermark,
      set: async (newWatermark) => {
        watermark = newWatermark;
      },
    },
  },
  algod,
);
```

**What just happened:** `frequencyInSeconds: 5` sets the polling interval to 5
seconds (default is 1). `waitForBlockWhenAtTip: true` makes the subscriber call
algod's `/status/wait-for-block-after` endpoint instead of sleeping when it has
caught up to the chain tip — this reduces latency because the subscriber wakes
up as soon as a new block is available rather than waiting for the next poll
cycle.
