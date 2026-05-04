## Subscribed transaction

`SubscribedTransaction` extends the indexer `Transaction` type with subscriber-specific
fields like `filtersMatched`, `arc28Events`, and `balanceChanges`. All transaction
fields use the indexer format (camelCase property names, `bigint` for amounts/rounds).

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Access transaction fields

Read standard transaction fields directly from the `SubscribedTransaction`
object. Fields follow the indexer `Transaction` model — type-specific data lives
in nested objects like `paymentTransaction`, `assetTransferTransaction`, and
`applicationTransaction`:

```typescript
subscriber.on("my-filter", async (txn) => {
  // Common fields (present on all transactions)
  console.log(`ID: ${txn.id}`);
  console.log(`Sender: ${txn.sender}`);
  console.log(`Type: ${txn.txType}`);
  // txType is 'pay' | 'keyreg' | 'acfg' | 'axfer' | 'afrz' | 'appl' | 'stpf' | 'hb'
  console.log(`Confirmed round: ${txn.confirmedRound}`);
  console.log(`Round time: ${txn.roundTime}`);
  console.log(`Fee: ${txn.fee}`);
  console.log(`Note: ${txn.note}`);

  // Payment-specific fields
  if (txn.paymentTransaction) {
    console.log(`Receiver: ${txn.paymentTransaction.receiver}`);
    console.log(`Amount: ${txn.paymentTransaction.amount} microAlgos`);
    console.log(`Close to: ${txn.paymentTransaction.closeRemainderTo}`);
  }

  // Asset transfer-specific fields
  if (txn.assetTransferTransaction) {
    console.log(`Asset ID: ${txn.assetTransferTransaction.assetId}`);
    console.log(`Amount: ${txn.assetTransferTransaction.amount}`);
    console.log(`Receiver: ${txn.assetTransferTransaction.receiver}`);
  }

  // App call-specific fields
  if (txn.applicationTransaction) {
    console.log(`App ID: ${txn.applicationTransaction.applicationId}`);
    console.log(`On completion: ${txn.applicationTransaction.onCompletion}`);
    console.log(`App args: ${txn.applicationTransaction.applicationArgs}`);
  }

  // Other common fields
  console.log(`Group: ${txn.group}`);
  console.log(`Intra-round offset: ${txn.intraRoundOffset}`);
  console.log(`Created app ID: ${txn.createdAppId}`);
  console.log(`Created asset ID: ${txn.createdAssetId}`);
});
```

**What just happened:** `SubscribedTransaction` extends the indexer `Transaction`
type, so all standard indexer fields are available directly. The `id` field is
always present (the base `Transaction` type has it as optional, but the subscriber
always populates it). Type-specific data is in nested objects:
`paymentTransaction` for payments, `assetTransferTransaction` for asset transfers,
`applicationTransaction` for app calls, `assetConfigTransaction` for asset config,
`assetFreezeTransaction` for freezes, `keyregTransaction` for key registrations.
Amounts and round numbers are `bigint`. The `note` field is a `Uint8Array` — decode
it with `new TextDecoder().decode(txn.note)` if it contains text.

### Read filtersMatched

When a transaction matches one or more named filters, the `filtersMatched`
array contains the names of all filters that matched. Use this to route
transactions to different processing logic:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "payments",
        filter: { type: TransactionType.Payment },
      },
      {
        name: "large-transfers",
        filter: {
          type: TransactionType.Payment,
          minAmount: 1_000_000n, // 1 Algo
        },
      },
    ],
    watermarkPersistence: { get: async () => 0n, set: async () => {} },
    syncBehaviour: "skip-sync-newest",
  },
  algod,
);

// Handler fires for each filter that matched
subscriber.on("payments", async (txn) => {
  console.log(`Payment from ${txn.sender}`);
  console.log(`Matched filters: ${txn.filtersMatched?.join(", ")}`);
  // A 2 Algo payment logs: "Matched filters: payments, large-transfers"
});

subscriber.on("large-transfers", async (txn) => {
  // Only fires for payments >= 1 Algo
  // txn.filtersMatched will include both "payments" and "large-transfers"
  console.log(`Large payment detected: ${txn.id}`);
});
```

**What just happened:** `filtersMatched` is a `string[]` containing the `name`
of every `NamedTransactionFilter` that the transaction satisfied. A single
transaction can match multiple filters — when it does, the transaction is
delivered to each matching filter's handler, and `filtersMatched` always contains
all matched filter names (not just the current handler's filter). This is useful
for conditional logic when a single handler needs to know the full match context.

### Access block metadata

`TransactionSubscriptionResult.blockMetadata` contains metadata for each block
retrieved during a subscription poll. Access it from `pollOnce()` or
`getSubscribedTransactions()` results:

```typescript
import { getSubscribedTransactions } from "@algorandfoundation/algokit-subscriber";

const result = await getSubscribedTransactions(
  {
    filters: [{ name: "all", filter: {} }],
    watermark: 0n,
    syncBehaviour: "sync-oldest",
    maxRoundsToSync: 10,
  },
  algod,
);

if (result.blockMetadata) {
  for (const block of result.blockMetadata) {
    console.log(`Round: ${block.round}`);
    console.log(`Timestamp: ${new Date(block.timestamp * 1000)}`);
    console.log(`Genesis ID: ${block.genesisId}`);
    console.log(`Hash: ${block.hash}`);
    console.log(`Previous block hash: ${block.previousBlockHash}`);
    console.log(`Seed: ${block.seed}`);
    console.log(`Proposer: ${block.proposer}`);
    console.log(`Parent txn count: ${block.parentTransactionCount}`);
    console.log(`Full txn count: ${block.fullTransactionCount}`);
    console.log(`Txn counter: ${block.txnCounter}`);
    console.log(`Transactions root: ${block.transactionsRoot}`);
    console.log(`Protocol: ${block.upgradeState?.currentProtocol}`);
  }
}
```

**What just happened:** `blockMetadata` is an optional `BlockMetadata[]` on
`TransactionSubscriptionResult`. It contains one entry per block retrieved from
algod during the poll. Key fields include `round` (bigint), `timestamp` (seconds
since epoch), `genesisId`, `hash`, `proposer`, and transaction counts
(`parentTransactionCount` for top-level, `fullTransactionCount` including inners).
The `rewards` field contains fee sink and reward pool data. `upgradeState` tracks
the current protocol version and any pending upgrades. Block metadata is only
populated when blocks are fetched from algod — it is not available during indexer
catchup phases.

### Custom filter function

Use `customFilter` on `TransactionFilter` to apply arbitrary predicate logic
that goes beyond the built-in filter fields. The predicate receives a fully
populated `SubscribedTransaction` and returns `true` to include it:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "high-fee-payments",
        filter: {
          type: TransactionType.Payment,
          customFilter: (txn) => txn.fee > 10_000n,
        },
      },
      {
        name: "note-contains-json",
        filter: {
          customFilter: (txn) => {
            if (!txn.note) return false;
            const noteText = new TextDecoder().decode(txn.note);
            try {
              JSON.parse(noteText);
              return true;
            } catch {
              return false;
            }
          },
        },
      },
      {
        name: "grouped-app-calls",
        filter: {
          type: TransactionType.AppCall,
          customFilter: (txn) => txn.group !== undefined,
        },
      },
    ],
    watermarkPersistence: { get: async () => 0n, set: async () => {} },
    syncBehaviour: "skip-sync-newest",
  },
  algod,
);

subscriber.on("high-fee-payments", async (txn) => {
  console.log(`High fee payment: ${txn.fee} microAlgos fee`);
});
```

**What just happened:** `customFilter` is a synchronous predicate with signature
`(transaction: SubscribedTransaction) => boolean`. It runs after all other filter
fields have been evaluated — a transaction must satisfy both the built-in fields
(AND-ed together) and the `customFilter` to match. This makes it efficient to
combine: use built-in fields to narrow the candidate set, then use `customFilter`
for logic that the declarative fields cannot express (fee thresholds, note content
parsing, group membership, cross-field conditions, etc.). The predicate has access
to the full `SubscribedTransaction` including `balanceChanges` and `arc28Events`
if those have been populated.
