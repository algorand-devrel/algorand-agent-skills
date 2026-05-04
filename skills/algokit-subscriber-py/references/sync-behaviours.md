## Sync behaviours

These examples show all five `sync_behaviour` modes that control how the subscriber
handles gaps between its watermark and the current chain tip, plus how to tune
`max_rounds_to_sync` for each mode.

### Skip and sync newest

Use `skip-sync-newest` to discard old blocks and jump to the chain tip. Best for
real-time notification scenarios where historical transactions are not important:

```python
from algokit_utils import AlgorandClient
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, in_memory_watermark

algorand = AlgorandClient.default_localnet()
algod = algorand.client.algod

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="payments",
                filter=TransactionFilter(type="pay"),
            ),
        ],
        sync_behaviour="skip-sync-newest",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** When the subscriber is more than `max_rounds_to_sync` rounds
behind the tip, it skips ahead to `current_round - max_rounds_to_sync + 1` and only
processes the most recent rounds. Any transactions in skipped rounds are lost.
This is ideal for live dashboards or alerts where you only care about what is
happening now.

### Sync from oldest

Use `sync-oldest` to process every round from the watermark forward, catching up
incrementally. Best for archival or indexing scenarios where no transaction can be
missed:

```python
subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="all-app-calls",
                filter=TransactionFilter(app_id=1284326447),
            ),
        ],
        sync_behaviour="sync-oldest",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** The subscriber processes rounds starting from the
watermark, moving forward `max_rounds_to_sync` rounds per poll. If the watermark is
`0` it starts from round 1, which will be very slow on mainnet and requires an
archival node. Each poll advances the watermark, so the subscriber gradually
catches up to the tip over multiple polls.

### Sync oldest, start now

Use `sync-oldest-start-now` when deploying a new subscriber that should not
replay history but must not miss anything once started:

```python
subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="nft-transfers",
                filter=TransactionFilter(
                    type="axfer",
                    asset_id=987654,
                ),
            ),
        ],
        sync_behaviour="sync-oldest-start-now",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** This behaves like `sync-oldest` except when the watermark
is `0` — in that case it jumps to the current round instead of starting from
round 1. Once subscribed, it processes every round forward without skipping. If
the subscriber falls behind later, it still requires an archival node to catch
up since it syncs from the oldest unprocessed round.

### Catch up with indexer

Use `catchup-with-indexer` to leverage the indexer for fast historical sync and
then switch to algod for real-time blocks. Requires an `IndexerClient`:

```python
from algokit_utils import AlgorandClient
from algokit_utils.models.network import AlgoClientNetworkConfig
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, in_memory_watermark

algorand = AlgorandClient.from_config(
    algod_config=AlgoClientNetworkConfig(server="https://mainnet-api.4160.nodely.dev"),
    indexer_config=AlgoClientNetworkConfig(server="https://mainnet-idx.4160.nodely.dev"),
)
algod = algorand.client.algod
indexer = algorand.client.indexer

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="app-calls",
                filter=TransactionFilter(app_id=1284326447),
            ),
        ],
        sync_behaviour="catchup-with-indexer",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
    indexer_client=indexer,
)
```

**What just happened:** When the subscriber is more than `max_rounds_to_sync` rounds
behind, it uses the indexer to quickly sync from the watermark to
`current_round - max_rounds_to_sync`, then switches to algod from
`current_round - max_rounds_to_sync + 1` for the remaining
rounds. This is much faster than `sync-oldest` for long historical ranges. The
`IndexerClient` must be passed via `indexer_client`. Use
`max_indexer_rounds_to_sync` to limit how many rounds the indexer processes per poll
if memory or execution time is a concern.

### Fail on gap

Use `fail` when strict consistency is required and any gap between the watermark
and tip should halt processing:

```python
subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="critical-payments",
                filter=TransactionFilter(
                    type="pay",
                    receiver="RECEIVERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARW4HHF",
                ),
            ),
        ],
        sync_behaviour="fail",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** If the subscriber falls more than `max_rounds_to_sync`
rounds behind the chain tip, it raises a `ValueError` instead of silently
skipping or slowly catching up. This is appropriate for financial or compliance
scenarios where missing transactions is unacceptable and an operator should be
alerted to investigate. Pair with `on_error` to handle the failure gracefully.

### Control max rounds per poll

Tune `max_rounds_to_sync` to control how many rounds the subscriber processes in
each poll. This affects all sync behaviours:

```python
subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="all-transactions",
                filter=TransactionFilter(),
            ),
        ],
        sync_behaviour="sync-oldest",
        max_rounds_to_sync=100,
        max_indexer_rounds_to_sync=10000,
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** `max_rounds_to_sync` (default: 500) limits how many rounds
algod processes per poll. A lower value means smaller batches and less memory
usage but more polls to catch up. For `skip-sync-newest` and `fail`, it defines
the staleness tolerance — how far behind the tip the subscriber can be before
skipping or failing. `max_indexer_rounds_to_sync` (no default limit) caps how many
rounds the indexer processes per poll when using `catchup-with-indexer`, allowing
large catchups to be split across multiple transactionally consistent polls.
