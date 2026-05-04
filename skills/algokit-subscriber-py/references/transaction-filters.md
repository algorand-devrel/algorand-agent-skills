## Transaction filters

A `TransactionFilter` specifies which transactions to match during a
subscription poll. All fields within a single filter are AND-ed together;
use multiple `NamedTransactionFilter` entries to OR across different criteria.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Filter by transaction type

Use the `type` field with one or more transaction type strings to match
only specific transaction kinds:

```python
from algokit_subscriber import TransactionFilter

filter_ = TransactionFilter(
    type="pay",
)

# Match multiple types at once
multi_type_filter = TransactionFilter(
    type=["pay", "axfer"],
)
```

**What just happened:** The `type` field accepts a single string or a list of
strings. Available values are `"pay"` (payment), `"keyreg"` (key registration),
`"acfg"` (asset config), `"axfer"` (asset transfer), `"afrz"` (asset freeze),
`"appl"` (app call), `"stpf"` (state proof), and `"hb"` (heartbeat). When a
list is provided, a transaction matching any of the listed types satisfies this
field.

### Filter by sender or receiver

Use `sender` and/or `receiver` to match transactions involving specific
addresses:

```python
filter_ = TransactionFilter(
    sender="SENDERADDRESS...",
)

# Match any of several senders
multi_sender_filter = TransactionFilter(
    sender=["ALICE_ADDRESS...", "BOB_ADDRESS..."],
)

# Match by receiver
receiver_filter = TransactionFilter(
    receiver="RECEIVERADDRESS...",
)

# Combine sender and receiver (AND semantics)
both_filter = TransactionFilter(
    sender="ALICE_ADDRESS...",
    receiver="BOB_ADDRESS...",
)
```

**What just happened:** `sender` and `receiver` each accept a single address
string or a list of addresses. When a list is given, a transaction matching
any address in the list satisfies that field. When both `sender` and `receiver`
are specified, both conditions must be true (AND semantics).

### Filter by note prefix

Use `note_prefix` to match transactions whose note field starts with the given
string or bytes:

```python
filter_ = TransactionFilter(
    note_prefix="arc200/transfer",
)

# Or use bytes directly
bytes_filter = TransactionFilter(
    note_prefix=b"arc200/transfer",
)
```

**What just happened:** The `note_prefix` field accepts a `str` or `bytes`. If a
string is given, it is encoded to UTF-8. The subscriber checks whether the
transaction's note starts with this value. This is useful for matching ARC or
application-specific note conventions.

### Filter by app ID

Use `app_id` to match transactions that call a specific application, and
`app_create` to match application creation transactions:

```python
filter_ = TransactionFilter(
    app_id=123456789,
)

# Match calls to any of several apps
multi_app_filter = TransactionFilter(
    app_id=[123456789, 987654321],
)

# Match only app creation transactions
app_create_filter = TransactionFilter(
    app_create=True,
)
```

**What just happened:** `app_id` accepts a single `int` or a list of `int`
values. A transaction calling any of the listed app IDs satisfies this field.
`app_create` is a boolean — when `True`, only transactions that create a new
application are matched. These can be combined: `app_id` with `app_create` would
not typically be used together since a creation transaction does not yet have an
app ID at the point of submission.

### Filter by asset ID

Use `asset_id` to match transactions involving a specific asset, and
`asset_create` to match asset creation transactions:

```python
filter_ = TransactionFilter(
    asset_id=31566704,  # USDC on MainNet
)

# Match transfers of multiple assets
multi_asset_filter = TransactionFilter(
    type="axfer",
    asset_id=[31566704, 312769],
)

# Match only asset creation transactions
asset_create_filter = TransactionFilter(
    asset_create=True,
)
```

**What just happened:** `asset_id` accepts a single `int` or a list of `int`
values. A transaction involving any of the listed asset IDs satisfies this field.
`asset_create` is a boolean — when `True`, only transactions that create a new
asset are matched. Combining `asset_id` with `type="axfer"` narrows results to
transfers of those specific assets.

### Filter by amount range

Use `min_amount` and/or `max_amount` to match transactions within a specific
value range:

```python
# Match payments of at least 1 Algo (1_000_000 microAlgos)
large_payments = TransactionFilter(
    type="pay",
    min_amount=1_000_000,
)

# Match small asset transfers (0–100 decimal units)
small_transfers = TransactionFilter(
    type="axfer",
    asset_id=31566704,
    max_amount=100,
)

# Match payments in a specific range
range_filter = TransactionFilter(
    type="pay",
    min_amount=1_000_000,
    max_amount=10_000_000,
)
```

**What just happened:** `min_amount` and `max_amount` accept `int`. For payment
transactions the unit is microAlgos; for asset transfers it is the asset's
decimal units. When both are specified, the transaction amount must fall within
the inclusive range [min_amount, max_amount].

### Filter by ABI method signature

Use `method_signature` to match application calls that invoke specific ARC-4
methods:

```python
filter_ = TransactionFilter(
    type="appl",
    method_signature="transfer(address,address,uint64)void",
)

# Match any of several methods
multi_method_filter = TransactionFilter(
    type="appl",
    app_id=123456789,
    method_signature=[
        "transfer(address,address,uint64)void",
        "approve(address,uint64)void",
    ],
)
```

**What just happened:** `method_signature` accepts a single ARC-4 method
signature string or a list. The subscriber computes the 4-byte method selector
from each signature and checks whether the first app argument matches. When a
list is given, matching any selector satisfies this field.

### Filter by app call on-complete

Use `app_on_complete` to match application calls with a specific on-completion
action:

```python
filter_ = TransactionFilter(
    type="appl",
    app_on_complete="optin",
)

# Match opt-in or close-out
multi_on_complete_filter = TransactionFilter(
    type="appl",
    app_on_complete=["optin", "closeout"],
)
```

**What just happened:** `app_on_complete` accepts a single string value or a
list. Available values are `"noop"`, `"optin"`, `"closeout"`, `"clear"`,
`"update"`, and `"delete"`. When a list is given, a transaction with any of the
listed on-complete values satisfies this field.

### Filter by ARC-28 events

Use `arc28_events` to match application calls that emit specific ARC-28 events.
The event definitions must also be provided via the top-level `arc28_events`
subscription config:

```python
from algokit_subscriber import Arc28EventFilter

filter_ = TransactionFilter(
    type="appl",
    arc28_events=[Arc28EventFilter(group_name="my-app", event_name="Transfer")],
)
```

**What just happened:** `arc28_events` accepts a list of `Arc28EventFilter`
objects. Each object identifies an ARC-28 event by group and name. A transaction
matches if it emits at least one of the listed events. Note: the corresponding
event definitions must be passed in to the subscription config via the top-level
`arc28_events` parameter so the subscriber knows how to decode logs.

### Filter by balance changes

Use `balance_changes` to match transactions that produce specific balance change
effects:

```python
from algokit_subscriber import BalanceChangeFilter, BalanceChangeRole

filter_ = TransactionFilter(
    balance_changes=[
        BalanceChangeFilter(
            asset_id=31566704,
            role=BalanceChangeRole.Receiver,
            address="RECEIVERADDRESS...",
            min_absolute_amount=1000,
        ),
    ],
)
```

**What just happened:** `balance_changes` accepts a list of balance change
criteria. Each entry can specify `asset_id` (`int | list[int]`), `role`
(`BalanceChangeRole | list[BalanceChangeRole]`), `address` (`str | list[str]`),
`min_absolute_amount` / `max_absolute_amount` (`int | float`), and `min_amount`
/ `max_amount` (`int | float`). A transaction matches if any of its balance
changes satisfies at least one entry in the list (OR across entries, AND within
an entry). The `min_absolute_amount` / `max_absolute_amount` fields compare against
the absolute value of the balance change amount, while `min_amount` / `max_amount`
compare against the signed value.

### Filter with custom predicates

Use `app_call_arguments_match` to filter by arbitrary app call argument inspection,
or `custom_filter` as a catch-all predicate:

```python
# Match app calls where the second argument is a specific address
arg_filter = TransactionFilter(
    type="appl",
    app_call_arguments_match=lambda args: (
        args is not None and len(args) > 1 and args[1].decode() == "TARGETADDRESS..."
    ),
)

# Catch-all custom filter
custom_filter = TransactionFilter(
    custom_filter=lambda txn: txn.fee > 10_000,
)
```

**What just happened:** `app_call_arguments_match` accepts a predicate function
`Callable[[list[bytes] | None], bool]` that receives the raw app call arguments.
`custom_filter` accepts a predicate `Callable[[Transaction], bool]` that receives
the full transaction. Both are AND-ed with other fields in the same filter.

### Combine multiple filter fields

All fields within a single `TransactionFilter` are AND-ed — a transaction must
satisfy every specified field to match:

```python
# Match USDC transfers of at least 1000 units sent by a specific address
combined_filter = TransactionFilter(
    type="axfer",
    sender="ALICE_ADDRESS...",
    asset_id=31566704,
    min_amount=1000,
)
```

**What just happened:** This filter requires all four conditions to be true
simultaneously: the transaction must be an asset transfer, sent by the
specified address, involving asset 31566704, and transferring at least 1000
decimal units. If any single condition fails, the transaction is not matched.

### Use multiple named filters

Wrap filters in `NamedTransactionFilter` entries to OR across different
criteria. Each matched transaction reports which filter(s) it matched via the
`filters_matched` field:

```python
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, in_memory_watermark

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="large-payments",
                filter=TransactionFilter(
                    type="pay",
                    min_amount=10_000_000,
                ),
            ),
            SubscriberConfigFilter(
                name="usdc-transfers",
                filter=TransactionFilter(
                    type="axfer",
                    asset_id=31566704,
                ),
            ),
        ],
        sync_behaviour="skip-sync-newest",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)

# Each filter triggers its own event stream
subscriber.on("large-payments", lambda txn, _: print(f"Large payment: {txn.id_}"))
subscriber.on("usdc-transfers", lambda txn, _: print(f"USDC transfer: {txn.id_}, matched: {txn.filters_matched}"))
```

**What just happened:** The `filters` list contains multiple
`SubscriberConfigFilter` entries. A transaction is included in results if it
matches any filter (OR semantics across filters). Each matching transaction
carries a `filters_matched` string list containing the names of all filters it
satisfied — a single transaction can match multiple named filters. Use
`subscriber.on(filter_name, handler)` to handle each filter's matches
independently.
