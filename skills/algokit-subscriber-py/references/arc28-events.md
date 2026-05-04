## ARC-28 events

ARC-28 events let you define, filter, and parse structured events emitted from
application call logs. You define event schemas, group them for specific apps,
and the subscriber automatically decodes matching log entries.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Define ARC-28 event definitions

Use the `Arc28Event` dataclass to describe a single event with a name and
typed arguments:

```python
from algokit_subscriber import Arc28Event, Arc28EventArg

transfer_event = Arc28Event(
    name="Transfer",
    args=[
        Arc28EventArg(type="address", name="from"),
        Arc28EventArg(type="address", name="to"),
        Arc28EventArg(type="uint64", name="amount"),
    ],
)

approval_event = Arc28Event(
    name="Approval",
    args=[
        Arc28EventArg(type="address", name="owner"),
        Arc28EventArg(type="address", name="spender"),
        Arc28EventArg(type="uint64", name="amount"),
    ],
)
```

**What just happened:** Each `Arc28Event` has a `name` (the event identifier) and
an `args` list describing the event's parameters in order. Each argument has a
`type` (an ABI type string like `address`, `uint64`, `bool`, etc.) and an
optional `name` used to populate `args_by_name` on parsed events. An optional
`desc` field is available on both the event and each argument for documentation.
`Arc28Event` also provides cached properties: `signature` (e.g.
`"Transfer(address,address,uint64)"`), `prefix` (4-byte selector), and `abi_type`.

### Configure event groups

Use `Arc28EventGroup` to bundle related events and specify which app IDs they
apply to:

```python
from algokit_subscriber import Arc28EventGroup

token_events = Arc28EventGroup(
    group_name="token",
    process_for_app_ids=[1234, 5678],
    events=[transfer_event, approval_event],
)

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="token-calls",
                filter=TransactionFilter(app_id=1234),
            ),
        ],
        arc28_events=[token_events],
        # ... other config
    ),
    algod_client=algod,
)
```

**What just happened:** `Arc28EventGroup` groups events under a `group_name` and
optionally restricts processing to specific app IDs via `process_for_app_ids` (a
list of `int`). The `events` list contains the `Arc28Event` definitions.
Pass event groups to the top-level `arc28_events` list in the subscriber config.
When a matching app call is found, the subscriber checks its logs against each
event definition in applicable groups and decodes matching entries.

### Filter by emitted events

Use `arc28_events` on `TransactionFilter` to match only transactions that emit
specific events:

```python
from algokit_subscriber import Arc28EventFilter

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="transfers",
                filter=TransactionFilter(
                    arc28_events=[
                        Arc28EventFilter(group_name="token", event_name="Transfer"),
                    ],
                ),
            ),
        ],
        arc28_events=[token_events],
        # ... other config
    ),
    algod_client=algod,
)
```

**What just happened:** The `arc28_events` field on `TransactionFilter` accepts a
list of `Arc28EventFilter` objects. A transaction matches when at least one of
its logs matches the named event from the named group. The event group must be
defined in the top-level `arc28_events` config list, and the `event_name` must
match the `name` field of one of the group's `Arc28Event` definitions.

### Inspect parsed event data

When a transaction matches, its `arc28_events` property contains parsed
`EmittedArc28Event` objects with decoded arguments:

```python
from algokit_subscriber import SubscribedTransaction

def handle_transfer(txn: SubscribedTransaction, event_name: str) -> None:
    for event in txn.arc28_events:
        print(f"Group: {event.group_name}")
        print(f"Event: {event.event_name}")
        print(f"Signature: {event.event_signature}")  # e.g. "Transfer(address,address,uint64)"
        print(f"Prefix: {event.event_prefix}")         # 4-byte hex prefix

        # Access arguments by position
        from_addr = event.args[0]
        to_addr = event.args[1]
        amount = event.args[2]

        # Access arguments by name (when name is defined in the event definition)
        from_named = event.args_by_name["from"]
        to_named = event.args_by_name["to"]
        amount_named = event.args_by_name["amount"]

subscriber.on("transfers", handle_transfer)
```

**What just happened:** `EmittedArc28Event` has the following fields: `args` (an
ordered list of decoded argument values) and `args_by_name` (a `dict[str, Any]`
keyed by argument name). Additional fields include `group_name`, `event_name`,
`event_signature` (e.g. `"Transfer(address,address,uint64)"`), `event_prefix`
(the 4-byte hex selector), and `event_definition` (the original `Arc28Event`).
Arguments are only present in `args_by_name` when the corresponding
`Arc28EventArg` has a `name` defined.

### Use process_transaction predicate

Use `process_transaction` for dynamic per-transaction control over which
transactions should have their logs parsed for ARC-28 events:

```python
from algokit_indexer_client.models import Transaction

dynamic_events = Arc28EventGroup(
    group_name="dynamic",
    process_transaction=lambda txn: (
        txn.note is not None and txn.note.startswith(b"arc28:")
    ),
    events=[transfer_event],
)
```

**What just happened:** `process_transaction` is a predicate function that
receives a `Transaction` and returns `bool`. When provided, it is evaluated for
each transaction instead of (or in addition to) `process_for_app_ids`. This lets
you apply event parsing conditionally based on any transaction property — note
prefix, sender address, inner transaction depth, etc. If both
`process_for_app_ids` and `process_transaction` are provided, the transaction
must match the app ID list and the predicate must return `True`.

### Handle parsing errors

Set `continue_on_error=True` on an event group to prevent ARC-28 parsing
failures from stopping the subscriber:

```python
resilient_events = Arc28EventGroup(
    group_name="resilient",
    process_for_app_ids=[1234],
    continue_on_error=True,
    events=[transfer_event, approval_event],
)
```

**What just happened:** By default, `continue_on_error` is `False` and any error
decoding an ARC-28 event log (e.g. a log that matches the 4-byte prefix but has
malformed data) will raise and stop the subscriber. Setting `continue_on_error=True`
causes the subscriber to log a warning and skip the malformed entry, allowing
processing to continue. This is useful when monitoring apps that may emit logs
with the same prefix but different structures, or when you want to prioritize
liveness over completeness.
