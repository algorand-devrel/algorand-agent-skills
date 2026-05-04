## Event handlers

These examples show how to register transaction event handlers and data
mappers on an `AlgorandSubscriber`. All examples assume a `subscriber`
variable created per `references/subscriber-setup.md`.

### Handle individual transactions

Use `on(filterName, listener)` to receive each matching transaction one at
a time. The listener receives a `SubscribedTransaction` (or the mapper's
return type) and can be async:

```typescript
subscriber.on("payments", async (transaction) => {
  console.log(
    `Payment ${transaction.id} from ${transaction["sender"]}`,
    `— ${transaction.filtersMatched} filter(s) matched`,
  );
});
```

**What just happened:** `on(filterName, listener)` registers a handler that
fires once per matching transaction within each poll. The `filterName` must
match the `name` you gave in the `filters` array of your
`AlgorandSubscriberConfig`. The listener receives a `SubscribedTransaction`
by default — an extended indexer `TransactionResult` with `id`,
`filtersMatched`, `arc28Events`, `balanceChanges`, and `innerTxns`. The
handler has the `TypedAsyncEventListener<T>` type:
`(event: T, eventName: string | symbol) => Promise<void> | void` — it can
be sync or async and will be awaited if async. Returns the subscriber for
chaining.

### Handle transaction batches

Use `onBatch(filterName, listener)` to receive all matching transactions
from a single poll as one array — useful for bulk database inserts or
aggregation:

```typescript
subscriber.onBatch("payments", async (transactions) => {
  console.log(`Received batch of ${transactions.length} payments`);

  // Bulk insert into database
  if (transactions.length > 0) {
    await db.payments.insertMany(
      transactions.map((txn) => ({
        id: txn.id,
        sender: txn["sender"],
        round: txn["confirmed-round"],
      })),
    );
  }
});
```

**What just happened:** `onBatch(filterName, listener)` registers a handler
that fires once per poll with an array of all transactions matching the
named filter. The batch handler fires before the per-transaction `on`
handlers for the same filter — `onBatch` fires first, then each
transaction is emitted individually to `on` handlers. If
no transactions matched the filter in a given poll, the listener still
fires with an empty array. The listener can be async and will be awaited.
Returns the subscriber for chaining.

### Use data mappers

Add a `mapper` function to a `SubscriberConfigFilter` to transform
transactions before they reach `on` and `onBatch` handlers. The mapper
receives the full batch array and must return a transformed array:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";
import type { SubscribedTransaction } from "@algorandfoundation/algokit-subscriber/types/subscription";

interface PaymentSummary {
  id: string;
  sender: string;
  amount: bigint;
}

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "payments",
        filter: { type: "pay" },
        mapper: async (transactions: SubscribedTransaction[]): Promise<PaymentSummary[]> => {
          return transactions.map((txn) => ({
            id: txn.id,
            sender: txn["sender"],
            amount: BigInt(txn["payment-transaction"]?.["amount"] ?? 0),
          }));
        },
      },
    ],
    frequencyInSeconds: 5,
    syncBehaviour: "skip-sync-newest",
    watermarkPersistence: {
      get: async () => 0n,
      set: async () => {},
    },
  },
  algod,
);

// TypeScript knows `payment` is PaymentSummary, not SubscribedTransaction
subscriber.on<PaymentSummary>("payments", async (payment) => {
  console.log(`Payment ${payment.id}: ${payment.sender} sent ${payment.amount}`);
});
```

**What just happened:** The `mapper` property on `SubscriberConfigFilter<T>`
is an async function with signature
`(transactions: SubscribedTransaction[]) => Promise<T[]>`. It runs once per
poll before events are dispatched — both `onBatch` and `on` handlers
receive the mapped type `T` instead of raw `SubscribedTransaction`. Use the
generic parameter on `on<T>` or `onBatch<T>` to get type-safe access to the
mapped shape. If multiple filters share the same name, only the mapper from
the first matching filter is used.

### Chain event registrations

All `on*` methods return the subscriber instance, so you can chain
registrations fluently:

```typescript
subscriber
  .on("payments", async (txn) => {
    console.log(`Payment: ${txn.id}`);
  })
  .on("app-calls", async (txn) => {
    console.log(`App call: ${txn.id} to app ${txn["application-transaction"]?.["application-id"]}`);
  })
  .onBatch("payments", async (txns) => {
    await db.payments.insertMany(txns);
  })
  .onError(async (error) => {
    console.error("Subscription error:", error);
  })
  .start();
```

**What just happened:** Every `on()`, `onBatch()`, `onError()`,
`onBeforePoll()`, and `onPoll()` method returns `this`, enabling a fluent
builder pattern. You can register multiple handlers for the same filter
name — they all fire in registration order. The chain typically ends with
`start()` (which returns `void`) or you can store the subscriber reference
and call `start()` separately.
