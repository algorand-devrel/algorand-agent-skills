## ARC-28 events

ARC-28 events let you define, filter, and parse structured events emitted from
application call logs. You define event schemas, group them for specific apps,
and the subscriber automatically decodes matching log entries.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Define ARC-28 event definitions

Use the `Arc28Event` interface to describe a single event with a name and
typed arguments:

```typescript
import type { Arc28Event } from "@algorandfoundation/algokit-subscriber/types/arc-28";

const transferEvent: Arc28Event = {
  name: "Transfer",
  args: [
    { type: "address", name: "from" },
    { type: "address", name: "to" },
    { type: "uint64", name: "amount" },
  ],
};

const approvalEvent: Arc28Event = {
  name: "Approval",
  args: [
    { type: "address", name: "owner" },
    { type: "address", name: "spender" },
    { type: "uint64", name: "amount" },
  ],
};
```

**What just happened:** Each `Arc28Event` has a `name` (the event identifier) and
an `args` array describing the event's parameters in order. Each argument has a
`type` (an ABI type string like `address`, `uint64`, `bool`, etc.) and an
optional `name` used to populate `argsByName` on parsed events. An optional
`desc` field is available on both the event and each argument for documentation.

### Configure event groups

Use `Arc28EventGroup` to bundle related events and specify which app IDs they
apply to:

```typescript
import type { Arc28EventGroup } from "@algorandfoundation/algokit-subscriber/types/arc-28";

const tokenEvents: Arc28EventGroup = {
  groupName: "token",
  processForAppIds: [1234n, 5678n],
  events: [transferEvent, approvalEvent],
};

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "token-calls",
        filter: { appId: 1234n },
      },
    ],
    arc28Events: [tokenEvents],
    // ... other config
  },
  algod,
);
```

**What just happened:** `Arc28EventGroup` groups events under a `groupName` and
optionally restricts processing to specific app IDs via `processForAppIds` (an
array of `bigint`). The `events` array contains the `Arc28Event` definitions.
Pass event groups to the top-level `arc28Events` array in the subscriber config.
When a matching app call is found, the subscriber checks its logs against each
event definition in applicable groups and decodes matching entries.

### Filter by emitted events

Use `arc28Events` on `TransactionFilter` to match only transactions that emit
specific events:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "transfers",
        filter: {
          arc28Events: [
            { groupName: "token", eventName: "Transfer" },
          ],
        },
      },
    ],
    arc28Events: [tokenEvents],
    // ... other config
  },
  algod,
);
```

**What just happened:** The `arc28Events` field on `TransactionFilter` accepts an
array of `{ groupName: string; eventName: string }` objects. A transaction
matches when at least one of its logs matches the named event from the named
group. The event group must be defined in the top-level `arc28Events` config
array, and the `eventName` must match the `name` field of one of the group's
`Arc28Event` definitions.

### Inspect parsed event data

When a transaction matches, its `arc28Events` property contains parsed
`EmittedArc28Event` objects with decoded arguments:

```typescript
subscriber.on("transfers", async (txn) => {
  if (txn.arc28Events) {
    for (const event of txn.arc28Events) {
      console.log(`Group: ${event.groupName}`);
      console.log(`Event: ${event.eventName}`);
      console.log(`Signature: ${event.eventSignature}`); // e.g. "Transfer(address,address,uint64)"
      console.log(`Prefix: ${event.eventPrefix}`);       // 4-byte hex prefix

      // Access arguments by position
      const from = event.args[0];  // ABIValue
      const to = event.args[1];
      const amount = event.args[2];

      // Access arguments by name (when name is defined in the event definition)
      const fromNamed = event.argsByName["from"];
      const toNamed = event.argsByName["to"];
      const amountNamed = event.argsByName["amount"];
    }
  }
});
```

**What just happened:** `EmittedArc28Event` extends `Arc28EventToProcess` and
adds two fields: `args` (an ordered `ABIValue[]` of decoded argument values) and
`argsByName` (a `Record<string, ABIValue>` keyed by argument name). The inherited
fields include `groupName`, `eventName`, `eventSignature` (e.g.
`Transfer(address,address,uint64)`), `eventPrefix` (the 4-byte hex selector),
and `eventDefinition` (the original `Arc28Event`). Arguments are only present in
`argsByName` when the corresponding `Arc28Event` argument has a `name` defined.

### Use processTransaction predicate

Use `processTransaction` for dynamic per-transaction control over which
transactions should have their logs parsed for ARC-28 events:

```typescript
const dynamicEvents: Arc28EventGroup = {
  groupName: "dynamic",
  processTransaction: (txn) => {
    // Only process events from transactions with a specific note prefix
    if (!txn.note) return false;
    const note = Buffer.from(txn.note).toString("utf-8");
    return note.startsWith("arc28:");
  },
  events: [transferEvent],
};
```

**What just happened:** `processTransaction` is a predicate function that
receives a `SubscribedTransaction` and returns `boolean`. When provided, it is
evaluated for each transaction instead of (or in addition to)
`processForAppIds`. This lets you apply event parsing conditionally based on any
transaction property — note prefix, sender address, inner transaction depth, etc.
If both `processForAppIds` and `processTransaction` are provided, the transaction
must match the app ID list and the predicate must return `true`.

### Handle parsing errors

Set `continueOnError: true` on an event group to prevent ARC-28 parsing
failures from stopping the subscriber:

```typescript
const resilientEvents: Arc28EventGroup = {
  groupName: "resilient",
  processForAppIds: [1234n],
  continueOnError: true,
  events: [transferEvent, approvalEvent],
};
```

**What just happened:** By default, `continueOnError` is `false` and any error
decoding an ARC-28 event log (e.g. a log that matches the 4-byte prefix but has
malformed data) will throw and stop the subscriber. Setting `continueOnError:
true` causes the subscriber to log a warning and skip the malformed entry,
allowing processing to continue. This is useful when monitoring apps that may
emit logs with the same prefix but different structures, or when you want to
prioritize liveness over completeness.
