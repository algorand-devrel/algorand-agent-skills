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

```python
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, SubscribedTransaction, in_memory_watermark

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="app-inner-pays",
                filter=TransactionFilter(
                    type="pay",
                    sender=["APP_ACCOUNT_ADDRESS..."],
                ),
            ),
        ],
        watermark_persistence=in_memory_watermark(),
        sync_behaviour="skip-sync-newest",
    ),
    algod_client=algod,
)

def handle_inner_pay(txn: SubscribedTransaction, event_name: str) -> None:
    print(f"Inner payment: {txn.id_}")
    print(f"Amount: {txn.payment_transaction.amount if txn.payment_transaction else 0}")

subscriber.on("app-inner-pays", handle_inner_pay)
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

Inner transactions carry `parent_transaction_id` and `parent_intra_round_offset`
fields that link them back to their root transaction. Their `id_` follows the
format `{parentTxId}/inner/{offset}`:

```python
def handle_inner_pay(txn: SubscribedTransaction, event_name: str) -> None:
    if txn.parent_transaction_id:
        print("This is an inner transaction")
        print(f"ID: {txn.id_}")
        # e.g. "TXID.../inner/1"
        print(f"Parent TX ID: {txn.parent_transaction_id}")
        print(f"Parent intra-round offset: {txn.parent_intra_round_offset}")
    else:
        print("This is a top-level transaction")

subscriber.on("app-inner-pays", handle_inner_pay)
```

**What just happened:** Every inner transaction has three identifying fields:
- `id_` — follows the format `{parentTxId}/inner/{offset}` where `offset` is the
  position within the flattened inner transaction tree (1-based).
- `parent_transaction_id` — the transaction ID of the root (top-level) parent
  transaction. This is always the outermost transaction, even for deeply nested
  inner transactions.
- `parent_intra_round_offset` — the intra-round offset of the root parent
  transaction. Useful for ordering transactions within a block.

Top-level transactions have `parent_transaction_id` set to `None` (they have no
parent). Their `parent_intra_round_offset` mirrors their own
`intra_round_offset`, since the transaction *is* its own root.

### Navigate inner transaction tree

The `inner_txns` property on `SubscribedTransaction` contains the immediate
child inner transactions, each of which can recursively contain their own
`inner_txns`. Use recursion to walk the full tree:

```python
def walk_inner_transactions(txn: SubscribedTransaction, depth: int = 0) -> None:
    indent = "  " * depth
    print(f"{indent}{txn.id_} (type: {txn.tx_type})")

    for inner in txn.inner_txns:
        walk_inner_transactions(inner, depth + 1)

subscriber.on("my-filter", lambda txn, _: walk_inner_transactions(txn))
```

**What just happened:** `inner_txns` is typed as `list[SubscribedTransaction]` —
the same type as the parent, so each child has its own `id_`,
`parent_transaction_id`, `balance_changes`, `arc28_events`, and potentially its own
`inner_txns` for further nesting. The tree structure mirrors the actual execution
order of the application call. To process all inner transactions as a flat list
instead, use a recursive flatten:

```python
def flatten_inners(txn: SubscribedTransaction) -> list[SubscribedTransaction]:
    result = [txn]
    for inner in txn.inner_txns:
        result.extend(flatten_inners(inner))
    return result
```
