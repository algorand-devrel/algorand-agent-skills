## Subscriber lifecycle

These examples show how to run, stop, and hook into the `AlgorandSubscriber`
polling lifecycle. All examples assume a `subscriber` variable created per
`references/subscriber-setup.md`.

### Poll once

Execute a single subscription poll — ideal for cron jobs or serverless
invocations where a long-running process is not desired:

```typescript
const result = await subscriber.pollOnce();

console.log(
  `Synced rounds ${result.syncedRoundRange[0]}–${result.syncedRoundRange[1]},`,
  `${result.subscribedTransactions.length} matched transactions`,
);
```

**What just happened:** `pollOnce()` reads the current watermark, fetches new
blocks from algod (or indexer, depending on sync behaviour), runs all registered
filters and event handlers, persists the new watermark, and returns a
`TransactionSubscriptionResult`. The watermark is updated automatically — you do
not need to call `set` yourself.

### Start continuous polling

Begin an indefinite polling loop that runs until `stop()` is called — suitable
for long-running processes or containers:

```typescript
subscriber.start((pollResult) => {
  console.log(
    `Poll: rounds ${pollResult.syncedRoundRange[0]}–${pollResult.syncedRoundRange[1]},`,
    `${pollResult.subscribedTransactions.length} transactions`,
  );
});
```

**What just happened:** `start()` enters an async loop that calls `pollOnce()`
repeatedly. Between polls it either sleeps for `frequencyInSeconds` (default 1s)
or waits for the next block via algod when `waitForBlockWhenAtTip` is `true`.
The optional `inspect` callback fires after each poll with the
`TransactionSubscriptionResult`, useful for logging or metrics. Calling `start()`
again while already running is a no-op.

### Stop gracefully

Stop a running subscriber, typically in response to a process signal:

```typescript
const handleShutdown = async (signal: string) => {
  console.log(`Received ${signal}, stopping subscriber...`);
  await subscriber.stop(signal);
  console.log("Subscriber stopped");
  process.exit(0);
};

process.on("SIGINT", () => handleShutdown("SIGINT"));
process.on("SIGTERM", () => handleShutdown("SIGTERM"));

subscriber.start();
```

**What just happened:** `stop(reason)` aborts the internal polling loop via an
`AbortController` and returns a promise that resolves once the current poll (if
any) finishes. The `reason` argument is passed to the abort signal. After
stopping, the subscriber can be restarted by calling `start()` again.

### Handle errors

Register an error handler that fires when polling or event processing throws:

```typescript
const maxRetries = 3;
let retryCount = 0;

subscriber.onError(async (error) => {
  retryCount++;
  if (retryCount > maxRetries) {
    console.error("Max retries exceeded, giving up", error);
    return;
  }
  console.log(`Error occurred, retrying in 2s (${retryCount}/${maxRetries})`);
  await new Promise((r) => setTimeout(r, 2_000));
  subscriber.start();
});

subscriber.start();
```

**What just happened:** `onError(listener)` registers a handler that receives
the thrown error. If no `onError` handler is registered, the default behaviour
re-throws the error. Inside the handler you can implement retry logic — calling
`start()` again re-enters the polling loop. The listener can be sync or async.
`onError` returns the subscriber for chaining.

### Before-poll hook

Run logic before each subscription poll — useful for logging, starting a
database transaction, or recording timing:

```typescript
subscriber.onBeforePoll(async (metadata) => {
  console.log(
    `Starting poll — watermark: ${metadata.watermark}, chain tip: ${metadata.currentRound}`,
  );
});
```

**What just happened:** `onBeforePoll(listener)` registers a handler that
receives a `BeforePollMetadata` object with `watermark` (the current persisted
watermark as `bigint`) and `currentRound` (the latest round from algod as
`bigint`). The listener fires at the start of every `pollOnce()` call, before
any transactions are fetched. It can be async and will be awaited. Returns the
subscriber for chaining.

### After-poll hook

Run logic after each subscription poll — useful for committing a database
transaction, flushing a batch, or cross-filter aggregation:

```typescript
subscriber.onPoll(async (pollResult) => {
  console.log(
    `Poll complete — synced ${pollResult.syncedRoundRange[0]}–${pollResult.syncedRoundRange[1]},`,
    `${pollResult.subscribedTransactions.length} transactions,`,
    `new watermark: ${pollResult.newWatermark}`,
  );
});
```

**What just happened:** `onPoll(listener)` registers a handler that receives the
full `TransactionSubscriptionResult` after all per-filter `on`/`onBatch`
handlers have run but before the watermark is persisted. The result includes
`syncedRoundRange`, `currentRound`, `startingWatermark`, `newWatermark`, and
`subscribedTransactions`. The listener can be async and will be awaited. Returns
the subscriber for chaining.
