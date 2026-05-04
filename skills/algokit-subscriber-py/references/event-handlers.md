## Event handlers

These examples show how to register transaction event handlers and data
mappers on an `AlgorandSubscriber`. All examples assume a `subscriber`
variable created per `references/subscriber-setup.md`.

### Handle individual transactions

Use `on(filter_name, listener)` to receive each matching transaction one at
a time. The listener receives a `SubscribedTransaction` (or the mapper's
return type) and the event name string:

```python
def handle_payment(transaction: SubscribedTransaction, event_name: str) -> None:
    print(
        f"Payment {transaction.id_} from {transaction.sender} "
        f"— {transaction.filters_matched} filter(s) matched"
    )

subscriber.on("payments", handle_payment)
```

**What just happened:** `on(filter_name, listener)` registers a handler that
fires once per matching transaction within each poll. The `filter_name` must
match the `name` you gave in the `filters` list of your
`AlgorandSubscriberConfig`. The listener receives a `SubscribedTransaction`
by default — an extended indexer `Transaction` with `id_`,
`filters_matched`, `arc28_events`, `balance_changes`, and `inner_txns`. The
handler has the `EventListener` type:
`Callable[[TEventType, str], None]` — it receives the event and the event name
string. Returns the subscriber for chaining.

### Handle transaction batches

Use `on_batch(filter_name, listener)` to receive all matching transactions
from a single poll as one list — useful for bulk database inserts or
aggregation:

```python
def handle_payment_batch(transactions: list[SubscribedTransaction], event_name: str) -> None:
    print(f"Received batch of {len(transactions)} payments")

    if transactions:
        db.payments.insert_many(
            [
                {
                    "id": txn.id_,
                    "sender": txn.sender,
                    "round": txn.confirmed_round,
                }
                for txn in transactions
            ]
        )

subscriber.on_batch("payments", handle_payment_batch)
```

**What just happened:** `on_batch(filter_name, listener)` registers a handler
that fires once per poll with a list of all transactions matching the
named filter. The batch handler fires before the per-transaction `on`
handlers for the same filter — `on_batch` fires first, then each
transaction is emitted individually to `on` handlers. If
no transactions matched the filter in a given poll, the listener still
fires with an empty list. Returns the subscriber for chaining.

### Use data mappers

Add a `mapper` function to a `SubscriberConfigFilter` to transform
transactions before they reach `on` and `on_batch` handlers. The mapper
receives the full batch list and must return a transformed list:

```python
from dataclasses import dataclass
from algokit_subscriber import (
    AlgorandSubscriber,
    AlgorandSubscriberConfig,
    SubscriberConfigFilter,
    SubscribedTransaction,
    TransactionFilter,
    in_memory_watermark,
)


@dataclass
class PaymentSummary:
    id: str
    sender: str
    amount: int


def map_payments(transactions: list[SubscribedTransaction]) -> list[PaymentSummary]:
    return [
        PaymentSummary(
            id=txn.id_,
            sender=txn.sender,
            amount=txn.payment_transaction.amount if txn.payment_transaction else 0,
        )
        for txn in transactions
    ]


subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="payments",
                filter=TransactionFilter(type="pay"),
                mapper=map_payments,
            ),
        ],
        frequency_in_seconds=5,
        sync_behaviour="skip-sync-newest",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)

# listener receives PaymentSummary, not SubscribedTransaction
def handle_payment(payment: PaymentSummary, event_name: str) -> None:
    print(f"Payment {payment.id}: {payment.sender} sent {payment.amount}")

subscriber.on("payments", handle_payment)
```

**What just happened:** The `mapper` property on `SubscriberConfigFilter`
is a callable with signature
`Callable[[list[SubscribedTransaction]], list[Any]]`. It runs once per
poll before events are dispatched — both `on_batch` and `on` handlers
receive the mapped type instead of raw `SubscribedTransaction`. If multiple
filters share the same name, only the mapper from the first matching filter
is used.

### Chain event registrations

All `on*` methods return the subscriber instance, so you can chain
registrations fluently:

```python
(
    subscriber
    .on("payments", lambda txn, _: print(f"Payment: {txn.id_}"))
    .on("app-calls", lambda txn, _: print(f"App call: {txn.id_} to app {txn.application_transaction.application_id if txn.application_transaction else None}"))
    .on_batch("payments", lambda txns, _: db.payments.insert_many(txns))
    .on_error(lambda error, _: print(f"Subscription error: {error}"))
    .start()
)
```

**What just happened:** Every `on()`, `on_batch()`, `on_error()`,
`on_before_poll()`, and `on_poll()` method returns `self`, enabling a fluent
builder pattern. You can register multiple handlers for the same filter
name — they all fire in registration order. The chain typically ends with
`start()` (which returns `None`) or you can store the subscriber reference
and call `start()` separately.
