## Inner transactions

Application calls on Algorand can produce inner transactions — payments, asset
transfers, or further app calls spawned during execution. The subscriber
flattens these into individually filterable transactions while preserving the
parent-child relationship.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Subscribe to inner transactions

Use a filter that targets the transaction type or app ID of the inner
transactions you care about. The subscriber automatically flattens inner
transactions so each one is evaluated against your filters independently:

```typescript
const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "app-inner-pays",
        filter: {
          type: TransactionType.Payment,
          sender: ["APP_ACCOUNT_ADDRESS..."],
        },
      },
    ],
    watermarkPersistence: { get: async () => 0n, set: async () => {} },
    syncBehaviour: "skip-sync-newest",
  },
  algod,
);

subscriber.on("app-inner-pays", async (txn) => {
  console.log(`Inner payment: ${txn.id}`);
  console.log(`Amount: ${txn.paymentTransaction?.amount}`);
});
```

**What just happened:** The filter matches payment transactions sent by a
specific application account. When an app call produces inner payment
transactions, the subscriber flattens them out and evaluates each one against
the filter individually. Matched inner transactions are delivered to the
handler just like top-level transactions, but with additional parent metadata
(see below). This works with both algod block processing and indexer catchup —
when the indexer returns a parent transaction, the subscriber re-runs filters
in-memory against the flattened inner transactions.

### Identify inner transactions

Inner transactions carry `parentTransactionId` and `parentIntraRoundOffset`
fields that link them back to their root transaction. Their `id` follows the
format `{parentTxId}/inner/{offset}`:

```typescript
subscriber.on("app-inner-pays", async (txn) => {
  if (txn.parentTransactionId) {
    console.log(`This is an inner transaction`);
    console.log(`ID: ${txn.id}`);
    // e.g. "TXID.../inner/1"
    console.log(`Parent TX ID: ${txn.parentTransactionId}`);
    console.log(`Parent intra-round offset: ${txn.parentIntraRoundOffset}`);
  } else {
    console.log(`This is a top-level transaction`);
  }
});
```

**What just happened:** Every inner transaction has three identifying fields:
- `id` — follows the format `{parentTxId}/inner/{offset}` where `offset` is the
  position within the flattened inner transaction tree (1-based).
- `parentTransactionId` — the transaction ID of the root (top-level) parent
  transaction. This is always the outermost transaction, even for deeply nested
  inner transactions.
- `parentIntraRoundOffset` — the intra-round offset of the root parent
  transaction. Useful for ordering transactions within a block.

Top-level transactions have `parentTransactionId` and `parentIntraRoundOffset`
set to `undefined`.

### Navigate inner transaction tree

The `innerTxns` property on `SubscribedTransaction` contains the immediate
child inner transactions, each of which can recursively contain their own
`innerTxns`. Use recursion to walk the full tree:

```typescript
function walkInnerTransactions(
  txn: SubscribedTransaction,
  depth: number = 0,
): void {
  const indent = "  ".repeat(depth);
  console.log(`${indent}${txn.id} (type: ${txn.txType})`);

  if (txn.innerTxns) {
    for (const inner of txn.innerTxns) {
      walkInnerTransactions(inner, depth + 1);
    }
  }
}

subscriber.on("my-filter", async (txn) => {
  walkInnerTransactions(txn);
});
```

**What just happened:** `innerTxns` is typed as `SubscribedTransaction[]` —
the same type as the parent, so each child has its own `id`,
`parentTransactionId`, `balanceChanges`, `arc28Events`, and potentially its own
`innerTxns` for further nesting. The tree structure mirrors the actual execution
order of the application call. To process all inner transactions as a flat list
instead, use a recursive flatten:

```typescript
function flattenInners(txn: SubscribedTransaction): SubscribedTransaction[] {
  return [txn, ...(txn.innerTxns ?? []).flatMap(flattenInners)];
}
```
