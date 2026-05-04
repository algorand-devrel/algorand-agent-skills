## Subscriber lifecycle

These examples show how to run, stop, and hook into the `AlgorandSubscriber`
polling lifecycle. All examples assume a `subscriber` variable created per
`references/subscriber-setup.md`.

### Poll once

Execute a single subscription poll — ideal for cron jobs or serverless
invocations where a long-running process is not desired:

```python
result = subscriber.poll_once()

print(
    f"Synced rounds {result.synced_round_range[0]}–{result.synced_round_range[1]}, "
    f"{len(result.subscribed_transactions)} matched transactions"
)
```

**What just happened:** `poll_once()` reads the current watermark, fetches new
blocks from algod (or indexer, depending on sync behaviour), runs all registered
filters and event handlers, persists the new watermark, and returns a
`TransactionSubscriptionResult`. The watermark is updated automatically — you do
not need to call `set` yourself.

### Start continuous polling

Begin an indefinite polling loop that runs until `stop()` is called — suitable
for long-running processes or containers:

```python
def inspect(poll_result: TransactionSubscriptionResult) -> None:
    print(
        f"Poll: rounds {poll_result.synced_round_range[0]}–{poll_result.synced_round_range[1]}, "
        f"{len(poll_result.subscribed_transactions)} transactions"
    )

subscriber.start(inspect)
```

**What just happened:** `start()` enters a loop that calls `poll_once()`
repeatedly. Between polls it either sleeps for `frequency_in_seconds` (default 1s)
or waits for the next block via algod when `wait_for_block_when_at_tip` is `True`.
The optional `inspect` callback fires after each poll with the
`TransactionSubscriptionResult`, useful for logging or metrics. Calling `start()`
again while already running is a no-op.

### Stop gracefully

Stop a running subscriber, typically in response to a process signal:

```python
import signal

def handle_shutdown(signum: int, frame) -> None:
    sig_name = signal.Signals(signum).name
    print(f"Received {sig_name}, stopping subscriber...")
    subscriber.stop(sig_name)

signal.signal(signal.SIGINT, handle_shutdown)
signal.signal(signal.SIGTERM, handle_shutdown)

subscriber.start()
```

**What just happened:** `stop(reason)` sets an internal flag that causes the
polling loop to exit after the current poll (if any) finishes. The `reason`
argument is logged. After stopping, the subscriber can be restarted by calling
`start()` again.

### Handle errors

Register an error handler that fires when polling or event processing throws:

```python
import time

max_retries = 3
retry_count = 0

def handle_error(error: Exception, event_name: str) -> None:
    global retry_count
    retry_count += 1
    if retry_count > max_retries:
        print(f"Max retries exceeded, giving up: {error}")
        subscriber.stop("max retries exceeded")
        return
    print(f"Error occurred, retrying in 2s ({retry_count}/{max_retries})")
    time.sleep(2)

subscriber.on_error(handle_error)
subscriber.start()
```

**What just happened:** `on_error(listener)` registers a handler that receives
the thrown exception and the event name string. If no `on_error` handler is
registered, the default behaviour re-raises the error, which exits the polling
loop. Once a custom handler is registered, each polling iteration's exception
is routed to the listener and the loop continues to the next poll
automatically — your handler can sleep, log, or call `subscriber.stop(...)` to
break out. `on_error` returns the subscriber for chaining.

### Before-poll hook

Run logic before each subscription poll — useful for logging, starting a
database transaction, or recording timing:

```python
from algokit_subscriber import BeforePollMetadata

def before_poll(metadata: BeforePollMetadata, event_name: str) -> None:
    print(
        f"Starting poll — watermark: {metadata.watermark}, chain tip: {metadata.current_round}"
    )

subscriber.on_before_poll(before_poll)
```

**What just happened:** `on_before_poll(listener)` registers a handler that
receives a `BeforePollMetadata` object with `watermark` (the current persisted
watermark as `int`) and `current_round` (the latest round from algod as
`int`). The listener fires at the start of every `poll_once()` call, before
any transactions are fetched. Returns the subscriber for chaining.

### After-poll hook

Run logic after each subscription poll — useful for committing a database
transaction, flushing a batch, or cross-filter aggregation:

```python
from algokit_subscriber import TransactionSubscriptionResult

def after_poll(poll_result: TransactionSubscriptionResult, event_name: str) -> None:
    print(
        f"Poll complete — synced {poll_result.synced_round_range[0]}–{poll_result.synced_round_range[1]}, "
        f"{len(poll_result.subscribed_transactions)} transactions, "
        f"new watermark: {poll_result.new_watermark}"
    )

subscriber.on_poll(after_poll)
```

**What just happened:** `on_poll(listener)` registers a handler that receives the
full `TransactionSubscriptionResult` after all per-filter `on`/`on_batch`
handlers have run but before the watermark is persisted. The result includes
`synced_round_range`, `current_round`, `starting_watermark`, `new_watermark`, and
`subscribed_transactions`. Returns the subscriber for chaining.
