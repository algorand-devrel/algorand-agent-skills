## Subscribed transaction

`SubscribedTransaction` extends the indexer `Transaction` type with subscriber-specific
fields like `filters_matched`, `arc28_events`, and `balance_changes`. All transaction
fields use the indexer format (snake_case property names, `int` for amounts/rounds).

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Access transaction fields

Read standard transaction fields directly from the `SubscribedTransaction`
object. Fields follow the indexer `Transaction` model — type-specific data lives
in nested objects like `payment_transaction`, `asset_transfer_transaction`, and
`application_transaction`:

```python
from algokit_subscriber import SubscribedTransaction

def handle_transaction(txn: SubscribedTransaction, event_name: str) -> None:
    # Common fields (present on all transactions)
    print(f"ID: {txn.id_}")
    print(f"Sender: {txn.sender}")
    print(f"Type: {txn.tx_type}")
    # tx_type is "pay" | "keyreg" | "acfg" | "axfer" | "afrz" | "appl" | "stpf" | "hb"
    print(f"Confirmed round: {txn.confirmed_round}")
    print(f"Round time: {txn.round_time}")
    print(f"Fee: {txn.fee}")
    print(f"Note: {txn.note}")

    # Payment-specific fields
    if txn.payment_transaction:
        print(f"Receiver: {txn.payment_transaction.receiver}")
        print(f"Amount: {txn.payment_transaction.amount} microAlgos")
        print(f"Close to: {txn.payment_transaction.close_remainder_to}")

    # Asset transfer-specific fields
    if txn.asset_transfer_transaction:
        print(f"Asset ID: {txn.asset_transfer_transaction.asset_id}")
        print(f"Amount: {txn.asset_transfer_transaction.amount}")
        print(f"Receiver: {txn.asset_transfer_transaction.receiver}")

    # App call-specific fields
    if txn.application_transaction:
        print(f"App ID: {txn.application_transaction.application_id}")
        print(f"On completion: {txn.application_transaction.on_completion}")
        print(f"App args: {txn.application_transaction.application_args}")

    # Other common fields
    print(f"Group: {txn.group}")
    print(f"Intra-round offset: {txn.intra_round_offset}")
    print(f"Created app ID: {txn.created_app_id}")
    print(f"Created asset ID: {txn.created_asset_id}")

subscriber.on("my-filter", handle_transaction)
```

**What just happened:** `SubscribedTransaction` extends the indexer `Transaction`
type, so all standard indexer fields are available directly. The `id_` field is
always present. Type-specific data is in nested objects:
`payment_transaction` for payments, `asset_transfer_transaction` for asset transfers,
`application_transaction` for app calls, `asset_config_transaction` for asset config,
`asset_freeze_transaction` for freezes, `keyreg_transaction` for key registrations.
Amounts and round numbers are `int`. The `note` field is `bytes` — decode
it with `txn.note.decode("utf-8")` if it contains text.

### Read filters_matched

When a transaction matches one or more named filters, the `filters_matched`
list contains the names of all filters that matched. Use this to route
transactions to different processing logic:

```python
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, in_memory_watermark

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="payments",
                filter=TransactionFilter(type="pay"),
            ),
            SubscriberConfigFilter(
                name="large-transfers",
                filter=TransactionFilter(
                    type="pay",
                    min_amount=1_000_000,  # 1 Algo
                ),
            ),
        ],
        watermark_persistence=in_memory_watermark(),
        sync_behaviour="skip-sync-newest",
    ),
    algod_client=algod,
)

# Handler fires for each filter that matched
def handle_payment(txn: SubscribedTransaction, event_name: str) -> None:
    print(f"Payment from {txn.sender}")
    print(f"Matched filters: {', '.join(txn.filters_matched)}")
    # A 2 Algo payment prints: "Matched filters: payments, large-transfers"

subscriber.on("payments", handle_payment)

def handle_large(txn: SubscribedTransaction, event_name: str) -> None:
    # Only fires for payments >= 1 Algo
    # txn.filters_matched will include both "payments" and "large-transfers"
    print(f"Large payment detected: {txn.id_}")

subscriber.on("large-transfers", handle_large)
```

**What just happened:** `filters_matched` is a `list[str]` containing the `name`
of every `NamedTransactionFilter` that the transaction satisfied. A single
transaction can match multiple filters — when it does, the transaction is
delivered to each matching filter's handler, and `filters_matched` always contains
all matched filter names (not just the current handler's filter). This is useful
for conditional logic when a single handler needs to know the full match context.

### Access block metadata

`TransactionSubscriptionResult.block_metadata` contains metadata for each block
retrieved during a subscription poll. Access it from `poll_once()` or
`get_subscribed_transactions()` results:

```python
from algokit_subscriber import get_subscribed_transactions, NamedTransactionFilter, TransactionFilter, TransactionSubscriptionParams

result = get_subscribed_transactions(
    subscription=TransactionSubscriptionParams(
        filters=[NamedTransactionFilter(name="all", filter=TransactionFilter())],
        watermark=0,
        sync_behaviour="sync-oldest",
        max_rounds_to_sync=10,
    ),
    algod=algod,
)

if result.block_metadata:
    for block in result.block_metadata:
        print(f"Round: {block.round}")
        print(f"Timestamp: {block.timestamp}")
        print(f"Genesis ID: {block.genesis_id}")
        print(f"Hash: {block.hash}")
        print(f"Previous block hash: {block.previous_block_hash}")
        print(f"Seed: {block.seed}")
        print(f"Proposer: {block.proposer}")
        print(f"Parent txn count: {block.parent_transaction_count}")
        print(f"Full txn count: {block.full_transaction_count}")
        print(f"Txn counter: {block.txn_counter}")
        print(f"Transactions root: {block.transactions_root}")
        print(f"Protocol: {block.upgrade_state.current_protocol if block.upgrade_state else None}")
```

**What just happened:** `block_metadata` is an optional `list[BlockMetadata]` on
`TransactionSubscriptionResult`. It contains one entry per block retrieved from
algod during the poll. Key fields include `round` (int), `timestamp` (seconds
since epoch), `genesis_id`, `hash`, `proposer`, and transaction counts
(`parent_transaction_count` for top-level, `full_transaction_count` including inners).
The `rewards` field contains fee sink and reward pool data. `upgrade_state` tracks
the current protocol version and any pending upgrades. Block metadata is only
populated when blocks are fetched from algod — it is not available during indexer
catchup phases.

### Custom filter function

Use `custom_filter` on `TransactionFilter` to apply arbitrary predicate logic
that goes beyond the built-in filter fields. The predicate receives a
`Transaction` and returns `True` to include it:

```python
import json
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, in_memory_watermark

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="high-fee-payments",
                filter=TransactionFilter(
                    type="pay",
                    custom_filter=lambda txn: txn.fee > 10_000,
                ),
            ),
            SubscriberConfigFilter(
                name="note-contains-json",
                filter=TransactionFilter(
                    custom_filter=lambda txn: _is_json_note(txn.note),
                ),
            ),
            SubscriberConfigFilter(
                name="grouped-app-calls",
                filter=TransactionFilter(
                    type="appl",
                    custom_filter=lambda txn: txn.group is not None,
                ),
            ),
        ],
        watermark_persistence=in_memory_watermark(),
        sync_behaviour="skip-sync-newest",
    ),
    algod_client=algod,
)


def _is_json_note(note: bytes | None) -> bool:
    if not note:
        return False
    try:
        json.loads(note.decode("utf-8"))
        return True
    except (UnicodeDecodeError, json.JSONDecodeError):
        return False


subscriber.on(
    "high-fee-payments",
    lambda txn, _: print(f"High fee payment: {txn.fee} microAlgos fee"),
)
```

**What just happened:** `custom_filter` is a synchronous predicate with signature
`Callable[[Transaction], bool]`. It runs after all other filter fields have been
evaluated — a transaction must satisfy both the built-in fields (AND-ed together)
and the `custom_filter` to match. This makes it efficient to combine: use built-in
fields to narrow the candidate set, then use `custom_filter` for logic that the
declarative fields cannot express (fee thresholds, note content parsing, group
membership, cross-field conditions, etc.). The predicate has access to the full
transaction including all nested type-specific objects.
