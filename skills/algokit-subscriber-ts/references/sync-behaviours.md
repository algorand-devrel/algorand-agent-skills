## Sync behaviours

These examples show all five `syncBehaviour` modes that control how the subscriber
handles gaps between its watermark and the current chain tip, plus how to tune
`maxRoundsToSync` for each mode.

### Skip and sync newest

Use `skip-sync-newest` to discard old blocks and jump to the chain tip. Best for
real-time notification scenarios where historical transactions are not important:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";

const algod = new AlgodClient({ baseUrl: "http://localhost:4001", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });

let watermark = 0n;

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "payments",
        filter: { type: "pay" },
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

**What just happened:** When the subscriber is more than `maxRoundsToSync` rounds
behind the tip, it skips ahead to `currentRound - maxRoundsToSync + 1` and only
processes the most recent rounds. Any transactions in skipped rounds are lost.
This is ideal for live dashboards or alerts where you only care about what is
happening now.

### Sync from oldest

Use `sync-oldest` to process every round from the watermark forward, catching up
incrementally. Best for archival or indexing scenarios where no transaction can be
missed:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "all-app-calls",
        filter: { appId: 1284326447n },
      },
    ],
    syncBehaviour: "sync-oldest",
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

**What just happened:** The subscriber processes rounds starting from the
watermark, moving forward `maxRoundsToSync` rounds per poll. If the watermark is
`0n` it starts from round 1, which will be very slow on mainnet and requires an
archival node. Each poll advances the watermark, so the subscriber gradually
catches up to the tip over multiple polls.

### Sync oldest, start now

Use `sync-oldest-start-now` when deploying a new subscriber that should not
replay history but must not miss anything once started:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "nft-transfers",
        filter: {
          type: "axfer",
          assetId: 987654n,
        },
      },
    ],
    syncBehaviour: "sync-oldest-start-now",
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

**What just happened:** This behaves like `sync-oldest` except when the watermark
is `0n` — in that case it jumps to the current round instead of starting from
round 1. Once subscribed, it processes every round forward without skipping. If
the subscriber falls behind later, it still requires an archival node to catch
up since it syncs from the oldest unprocessed round.

### Catch up with indexer

Use `catchup-with-indexer` to leverage the indexer for fast historical sync and
then switch to algod for real-time blocks. Requires an `IndexerClient`:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
import { IndexerClient } from "@algorandfoundation/algokit-utils/indexer-client";

const algod = new AlgodClient({ baseUrl: "https://mainnet-api.4160.nodely.dev", token: "" });
const indexer = new IndexerClient({ baseUrl: "https://mainnet-idx.4160.nodely.dev", token: "" });

let watermark = 0n;

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "app-calls",
        filter: { appId: 1284326447n },
      },
    ],
    syncBehaviour: "catchup-with-indexer",
    watermarkPersistence: {
      get: async () => watermark,
      set: async (newWatermark) => {
        watermark = newWatermark;
      },
    },
  },
  algod,
  indexer,
);
```

**What just happened:** When the subscriber is more than `maxRoundsToSync` rounds
behind, it uses the indexer to quickly sync from the watermark to
`currentRound - maxRoundsToSync`, then switches to algod from
`currentRound - maxRoundsToSync + 1` for the remaining
rounds. This is much faster than `sync-oldest` for long historical ranges. The
`IndexerClient` must be passed as the third constructor argument. Use
`maxIndexerRoundsToSync` to limit how many rounds the indexer processes per poll
if memory or execution time is a concern.

### Fail on gap

Use `fail` when strict consistency is required and any gap between the watermark
and tip should halt processing:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "critical-payments",
        filter: {
          type: "pay",
          receiver: "RECEIVERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARW4HHF",
        },
      },
    ],
    syncBehaviour: "fail",
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

**What just happened:** If the subscriber falls more than `maxRoundsToSync`
rounds behind the chain tip, it throws an error instead of silently skipping or
slowly catching up. This is appropriate for financial or compliance scenarios
where missing transactions is unacceptable and an operator should be alerted to
investigate. Pair with `onError` to handle the failure gracefully.

### Control max rounds per poll

Tune `maxRoundsToSync` to control how many rounds the subscriber processes in
each poll. This affects all sync behaviours:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "all-transactions",
        filter: {},
      },
    ],
    syncBehaviour: "sync-oldest",
    maxRoundsToSync: 100,
    maxIndexerRoundsToSync: 10000,
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

**What just happened:** `maxRoundsToSync` (default: 500) limits how many rounds
algod processes per poll. A lower value means smaller batches and less memory
usage but more polls to catch up. For `skip-sync-newest` and `fail`, it defines
the staleness tolerance — how far behind the tip the subscriber can be before
skipping or failing. `maxIndexerRoundsToSync` (no default limit) caps how many
rounds the indexer processes per poll when using `catchup-with-indexer`, allowing
large catchups to be split across multiple transactionally consistent polls.
