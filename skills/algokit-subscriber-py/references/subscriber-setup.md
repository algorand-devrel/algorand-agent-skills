## Subscriber setup

These examples show how to create and configure an `AlgorandSubscriber` instance
with different watermark persistence strategies and polling options.

### Create with in-memory watermark

The simplest setup uses the built-in `in_memory_watermark()` helper. Suitable for
short-lived processes or development:

```python
from algokit_utils import AlgorandClient
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, in_memory_watermark

algorand = AlgorandClient.default_localnet()
algod = algorand.client.algod

subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="my-app-calls",
                filter=TransactionFilter(
                    sender="SENDERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHB4E",
                ),
            ),
        ],
        sync_behaviour="skip-sync-newest",
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** An `AlgorandSubscriber` was created with a single named
filter that matches transactions from a specific sender. The watermark is stored
in memory via the `in_memory_watermark()` helper — it returns a
`WatermarkPersistence` with `get` and `set` callables backed by a simple variable.
`sync_behaviour="skip-sync-newest"` means if the subscriber is behind it
will skip to the current tip and only process new blocks going forward.

### Create with file-based watermark

Persist the watermark to a file so it survives process restarts:

```python
from pathlib import Path
from algokit_utils import AlgorandClient
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, WatermarkPersistence

algorand = AlgorandClient.default_localnet()
algod = algorand.client.algod
watermark_file = Path("./watermark.txt")


def get_watermark() -> int:
    try:
        return int(watermark_file.read_text().strip())
    except (FileNotFoundError, ValueError):
        return 0


def set_watermark(new_watermark: int) -> None:
    watermark_file.write_text(str(new_watermark))


subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="asset-transfers",
                filter=TransactionFilter(
                    type="axfer",
                    asset_id=123456,
                ),
            ),
        ],
        sync_behaviour="sync-oldest",
        watermark_persistence=WatermarkPersistence(
            get=get_watermark,
            set=set_watermark,
        ),
    ),
    algod_client=algod,
)
```

**What just happened:** The watermark is read from and written to a local file.
On first run (or if the file is missing) `get` returns `0` so the subscriber
starts from the beginning. `set` writes the new watermark after each poll so the
subscriber resumes where it left off on restart. The filter matches asset
transfer transactions (`axfer`) for a specific asset ID.

### Create with database watermark

For production deployments, persist the watermark with a database call:

```python
from algokit_utils import AlgorandClient
from algokit_utils.models.network import AlgoClientNetworkConfig
from algokit_subscriber import AlgorandSubscriber, AlgorandSubscriberConfig, SubscriberConfigFilter, TransactionFilter, WatermarkPersistence

algorand = AlgorandClient.from_config(
    algod_config=AlgoClientNetworkConfig(server="https://mainnet-api.4160.nodely.dev"),
    indexer_config=AlgoClientNetworkConfig(server="https://mainnet-idx.4160.nodely.dev"),
)
algod = algorand.client.algod
indexer = algorand.client.indexer


def get_watermark() -> int:
    row = db.execute("SELECT watermark FROM subscriber_state WHERE id = 'main'").fetchone()
    return int(row[0]) if row else 0


def set_watermark(new_watermark: int) -> None:
    db.execute(
        "INSERT INTO subscriber_state (id, watermark) VALUES ('main', ?) "
        "ON CONFLICT (id) DO UPDATE SET watermark = ?",
        (new_watermark, new_watermark),
    )
    db.commit()


subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="app-calls",
                filter=TransactionFilter(
                    app_id=1284326447,
                ),
            ),
        ],
        sync_behaviour="catchup-with-indexer",
        watermark_persistence=WatermarkPersistence(
            get=get_watermark,
            set=set_watermark,
        ),
    ),
    algod_client=algod,
    indexer_client=indexer,
)
```

**What just happened:** The watermark is stored in a database table using upsert
semantics. `get` queries for the current value (defaulting to `0` if no row
exists) and `set` inserts or updates the row after each poll. Since
`sync_behaviour` is `"catchup-with-indexer"`, the subscriber uses the indexer for
fast historical sync and then switches to algod for real-time blocks — this
requires passing an `IndexerClient` via `indexer_client`.

### Configure polling and block wait

Tune how often the subscriber polls and how it behaves when caught up to the tip:

```python
subscriber = AlgorandSubscriber(
    config=AlgorandSubscriberConfig(
        filters=[
            SubscriberConfigFilter(
                name="payments",
                filter=TransactionFilter(
                    type="pay",
                    receiver="RECEIVERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARW4HHF",
                ),
            ),
        ],
        sync_behaviour="skip-sync-newest",
        frequency_in_seconds=5,
        wait_for_block_when_at_tip=True,
        watermark_persistence=in_memory_watermark(),
    ),
    algod_client=algod,
)
```

**What just happened:** `frequency_in_seconds=5` sets the polling interval to 5
seconds (default is 1). `wait_for_block_when_at_tip=True` makes the subscriber call
algod's `/status/wait-for-block-after` endpoint instead of sleeping when it has
caught up to the chain tip — this reduces latency because the subscriber wakes
up as soon as a new block is available rather than waiting for the next poll
cycle.
