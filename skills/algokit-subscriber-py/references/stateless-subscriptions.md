## Stateless subscriptions

These examples show how to use `get_subscribed_transactions` for stateless,
single-poll subscription patterns — ideal for serverless functions, cron jobs,
or any context where you manage the watermark externally.

### Single poll with get_subscribed_transactions

Call `get_subscribed_transactions` once to fetch matching transactions since a
given watermark:

```python
from algokit_utils import AlgorandClient
from algokit_subscriber import get_subscribed_transactions, NamedTransactionFilter, TransactionFilter, TransactionSubscriptionParams

algorand = AlgorandClient.default_localnet()
algod = algorand.client.algod

result = get_subscribed_transactions(
    subscription=TransactionSubscriptionParams(
        watermark=0,
        sync_behaviour="skip-sync-newest",
        filters=[
            NamedTransactionFilter(
                name="payments",
                filter=TransactionFilter(
                    type="pay",
                    receiver="RECEIVERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARW4HHF",
                ),
            ),
        ],
    ),
    algod=algod,
)

print(f"Synced rounds {result.synced_round_range[0]}–{result.synced_round_range[1]}")
print(f"Found {len(result.subscribed_transactions)} matching transactions")
print(f"New watermark: {result.new_watermark}")
```

**What just happened:** `get_subscribed_transactions` executed a single
subscription poll starting from watermark `0`. It accepts a
`TransactionSubscriptionParams` object (with `watermark`, `sync_behaviour`, and
`filters`), an `AlgodClient`, and an optional `IndexerClient`. It returns a
`TransactionSubscriptionResult` containing `subscribed_transactions`,
`new_watermark`, `synced_round_range`, `current_round`, and `starting_watermark`. No
class instantiation is needed — the function is fully stateless.

### Manage watermark between calls

Extract `new_watermark` from each result and pass it into the next invocation to
process transactions incrementally:

```python
from pathlib import Path
from algokit_utils import AlgorandClient
from algokit_subscriber import get_subscribed_transactions, NamedTransactionFilter, TransactionFilter, TransactionSubscriptionParams

algorand = AlgorandClient.default_localnet()
algod = algorand.client.algod
watermark_file = Path("./watermark.txt")


def load_watermark() -> int:
    try:
        return int(watermark_file.read_text().strip())
    except (FileNotFoundError, ValueError):
        return 0


def save_watermark(watermark: int) -> None:
    watermark_file.write_text(str(watermark))


watermark = load_watermark()

result = get_subscribed_transactions(
    subscription=TransactionSubscriptionParams(
        watermark=watermark,
        sync_behaviour="sync-oldest",
        max_rounds_to_sync=1000,
        filters=[
            NamedTransactionFilter(
                name="app-calls",
                filter=TransactionFilter(
                    app_id=1284326447,
                ),
            ),
        ],
    ),
    algod=algod,
)

# Process transactions before persisting watermark
for txn in result.subscribed_transactions:
    print(f"Matched txn {txn.id_} in round {txn.confirmed_round}")

# Only persist after successful processing
save_watermark(result.new_watermark)
```

**What just happened:** The watermark is loaded from a file before calling
`get_subscribed_transactions` and saved after all matched transactions are
processed. This ensures incremental syncing — each invocation resumes from where
the last one left off. `max_rounds_to_sync=1000` caps how many rounds are fetched
per call, and `sync_behaviour="sync-oldest"` processes from the oldest unsynced
round forward. Critically, the watermark is only persisted after processing
completes — if the process crashes mid-way, the next invocation will re-process
the same range.

### Use in a serverless function

Wrap `get_subscribed_transactions` in a Lambda/Cloud Function handler with an
external watermark store (e.g. a database):

```python
from algokit_utils import AlgorandClient
from algokit_utils.models.network import AlgoClientNetworkConfig
from algokit_subscriber import get_subscribed_transactions, NamedTransactionFilter, TransactionFilter, TransactionSubscriptionParams

algorand = AlgorandClient.from_config(
    algod_config=AlgoClientNetworkConfig(server="https://mainnet-api.4160.nodely.dev"),
)
algod = algorand.client.algod


def handler(event, context):
    # Load watermark from external store
    row = db.execute("SELECT watermark FROM subscriber_state WHERE id = 'main'").fetchone()
    watermark = int(row[0]) if row else 0

    result = get_subscribed_transactions(
        subscription=TransactionSubscriptionParams(
            watermark=watermark,
            sync_behaviour="sync-oldest",
            max_rounds_to_sync=500,
            filters=[
                NamedTransactionFilter(
                    name="asset-transfers",
                    filter=TransactionFilter(
                        type="axfer",
                        asset_id=123456,
                        min_amount=1_000_000,
                    ),
                ),
            ],
        ),
        algod=algod,
    )

    # Process matched transactions
    for txn in result.subscribed_transactions:
        db.execute(
            "INSERT INTO tracked_transfers (tx_id, round, sender, amount) VALUES (?, ?, ?, ?)",
            (
                txn.id_,
                txn.confirmed_round,
                txn.sender,
                txn.asset_transfer_transaction.amount if txn.asset_transfer_transaction else 0,
            ),
        )

    # Persist watermark atomically after processing
    db.execute(
        "INSERT INTO subscriber_state (id, watermark) VALUES ('main', ?) "
        "ON CONFLICT (id) DO UPDATE SET watermark = ?",
        (result.new_watermark, result.new_watermark),
    )
    db.commit()

    return {
        "statusCode": 200,
        "body": {
            "processed": len(result.subscribed_transactions),
            "newWatermark": result.new_watermark,
            "roundRange": result.synced_round_range,
        },
    }
```

**What just happened:** The serverless handler loads the watermark from a
database, calls `get_subscribed_transactions` to fetch matching transactions,
writes them to the database, then persists the new watermark. This pattern works
with AWS Lambda, Google Cloud Functions, or any stateless runtime — trigger it
on a schedule (e.g. every minute via CloudWatch/Cloud Scheduler) and it will
incrementally process new transactions each invocation. The watermark is stored
externally so state survives across cold starts. `max_rounds_to_sync=500` keeps
each invocation's work bounded so it completes within typical serverless timeout
limits.
