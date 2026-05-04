---
name: algokit-subscriber-ts
description: >
  Guide for subscribing to Algorand transactions with AlgoKit Subscriber
  (`@algorandfoundation/algokit-subscriber`). Use this skill whenever the user needs real-time or
  historical transaction subscription, filtering, or event processing on Algorand — including
  AlgorandSubscriber setup, getSubscribedTransactions for stateless polling, TransactionFilter
  configuration, NamedTransactionFilter, SubscribedTransaction inspection, BalanceChangeRole-based
  filtering, ARC-28 event decoding, sync behaviours (catchup-with-indexer, skip-sync-newest,
  sync-oldest), watermark persistence, inner transaction navigation, and transaction subscription
  patterns. Trigger on imports from `@algorandfoundation/algokit-subscriber`, references to
  `AlgorandSubscriber`, `getSubscribedTransactions`, `TransactionFilter`, `SubscribedTransaction`,
  `BalanceChangeRole`, or any Algorand transaction subscription context.
---

# AlgoKit Subscriber TypeScript — Quick Reference (v4)

This skill targets **version 4.x** of `@algorandfoundation/algokit-subscriber`.

This skill provides idiomatic patterns for `@algorandfoundation/algokit-subscriber` (TypeScript).
The library subscribes to and filters Algorand transactions in real-time or historically, with
support for ARC-28 event decoding, balance change tracking, and inner transaction navigation.

## How to use this skill

Reference docs are split into individual files under `references/`. Only read the file(s) relevant
to the user's question — this keeps context lean. The table below maps topics to filenames.

## Key concepts

- **AlgorandSubscriber** is the main class for continuous or one-shot transaction polling. Create
  one with an `AlgorandSubscriberConfig`, an `AlgodClient`, and an optional `IndexerClient`.
- **getSubscribedTransactions** is a stateless function that executes a single subscription poll.
  Ideal for serverless/cron-style invocations where you manage the watermark externally.
- **TransactionFilter** specifies which transactions to match — by type, sender, receiver, app ID,
  asset ID, amount range, ABI method signature, ARC-28 events, balance changes, or custom predicate.
- **NamedTransactionFilter** wraps a `TransactionFilter` with a `name` string, so matched
  transactions report which filter(s) they matched via `filtersMatched`.
- **watermarkPersistence** is the `{ get, set }` interface on `AlgorandSubscriberConfig` that
  tracks the last processed round. Implement it with a file, database, or in-memory variable.
- **syncBehaviour** determines what happens when the subscriber is behind: `skip-sync-newest`,
  `sync-oldest`, `sync-oldest-start-now`, `catchup-with-indexer`, or `fail`.
- **SubscribedTransaction** extends the indexer `TransactionResult` with `id`, `filtersMatched`,
  `arc28Events`, `balanceChanges`, `parentTransactionId`, and recursive `innerTxns`.
- **ARC-28 events** are decoded from application call logs. Define event schemas in
  `Arc28EventGroup`, attach to filters, and read parsed args from `EmittedArc28Event`.
- **BalanceChangeRole** enumerates how an account participates in a transaction's balance effects:
  `Sender`, `Receiver`, `CloseTo`, `AssetCreator`, or `AssetDestroyer`.

## Reference file index

Read only the file(s) relevant to the user's current question.

| File | What it covers |
|------|---------------|
| `references/getting-started.md` | Installation, imports, prerequisites (algod, optional indexer) |
| `references/subscriber-setup.md` | Creating AlgorandSubscriber with watermark persistence (in-memory, file, database), polling config |
| `references/subscriber-lifecycle.md` | `pollOnce()`, `start()`, `stop()`, error handling, before/after-poll hooks |
| `references/event-handlers.md` | `on()` per-transaction handlers, `onBatch()` batch handlers, data mappers, fluent chaining |
| `references/transaction-filters.md` | All `TransactionFilter` fields: type, sender, receiver, notePrefix, appId, assetId, amount, methodSignature, appOnComplete; AND/OR semantics |
| `references/balance-changes.md` | Filtering by balance changes (assetId, role, amount range), inspecting `.balanceChanges`, `BalanceChangeRole` values |
| `references/arc28-events.md` | Defining `Arc28Event`/`Arc28EventGroup`, filtering by emitted events, inspecting `EmittedArc28Event` args, error handling |
| `references/stateless-subscriptions.md` | `getSubscribedTransactions` standalone usage, watermark management, serverless/Lambda patterns |
| `references/sync-behaviours.md` | All five sync behaviours explained, `maxRoundsToSync` tuning |
| `references/inner-transactions.md` | Subscribing to inner transactions, ID format `{txId}/inner/{offset}`, navigating `.innerTxns` tree |
| `references/subscribed-transaction.md` | Reading transaction fields (indexer format), `filtersMatched`, block metadata, `customFilter` predicates |

## Common patterns to remember

- `subscriber.pollOnce()` executes a single poll — use it for cron/serverless. `subscriber.start()`
  begins continuous polling until `subscriber.stop()` is called.
- `subscriber.on(filterName, handler)` fires per transaction; `subscriber.onBatch(filterName, handler)`
  fires once per poll with all matching transactions in that batch.
- `getSubscribedTransactions()` is fully stateless — pass in the watermark and get back results plus
  a `newWatermark`. No class instantiation needed.
- Watermark persistence must be atomic with your processing — persist the new watermark only after
  you have successfully handled all transactions in the batch.
- `catchup-with-indexer` uses the indexer for fast historical sync, then switches to algod for
  real-time blocks. Requires an `IndexerClient` to be provided.
- Inner transaction IDs follow the format `{parentTxId}/inner/{offset}` and carry
  `parentTransactionId` and `parentIntraRoundOffset` for navigation.
- Within a single `TransactionFilter`, all specified fields are AND-ed. Across multiple
  `NamedTransactionFilter` entries in the `filters` array, matching is OR-ed.
- Set `waitForBlockWhenAtTip: true` to have the subscriber wait for a new block via algod's
  `/status/wait-for-block-after` endpoint instead of sleeping when caught up.
- Filters support arrays for `sender`, `receiver`, `appId`, `assetId`, and `methodSignature` —
  any match within the array satisfies that field.
