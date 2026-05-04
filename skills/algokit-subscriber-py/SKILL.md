---
name: algokit-subscriber-py
description: >
  Guide for subscribing to Algorand transactions with AlgoKit Subscriber
  (`algokit-subscriber`). Use this skill whenever the user needs real-time or
  historical transaction subscription, filtering, or event processing on Algorand — including
  AlgorandSubscriber setup, get_subscribed_transactions for stateless polling, TransactionFilter
  configuration, NamedTransactionFilter, SubscribedTransaction inspection, BalanceChangeRole-based
  filtering, ARC-28 event decoding, sync behaviours (catchup-with-indexer, skip-sync-newest,
  sync-oldest), watermark persistence, inner transaction navigation, and transaction subscription
  patterns. Trigger on imports from `algokit_subscriber`, references to
  `AlgorandSubscriber`, `get_subscribed_transactions`, `TransactionFilter`, `SubscribedTransaction`,
  `BalanceChangeRole`, or any Algorand transaction subscription context.
---

# AlgoKit Subscriber Python — Quick Reference (v2)

This skill targets **version 2.x** of `algokit-subscriber`.

This skill provides idiomatic patterns for `algokit-subscriber` (Python).
The library subscribes to and filters Algorand transactions in real-time or historically, with
support for ARC-28 event decoding, balance change tracking, and inner transaction navigation.

## How to use this skill

Reference docs are split into individual files under `references/`. Only read the file(s) relevant
to the user's question — this keeps context lean. The table below maps topics to filenames.

## Key concepts

- **AlgorandSubscriber** is the main class for continuous or one-shot transaction polling. Create
  one with an `AlgorandSubscriberConfig`, an `AlgodClient`, and an optional `IndexerClient`.
- **get_subscribed_transactions** is a stateless function that executes a single subscription poll.
  Ideal for serverless/cron-style invocations where you manage the watermark externally.
- **TransactionFilter** specifies which transactions to match — by type, sender, receiver, app ID,
  asset ID, amount range, ABI method signature, ARC-28 events, balance changes, or custom predicate.
- **NamedTransactionFilter** wraps a `TransactionFilter` with a `name` string, so matched
  transactions report which filter(s) they matched via `filters_matched`.
- **watermark_persistence** is the `WatermarkPersistence(get, set)` dataclass on
  `AlgorandSubscriberConfig` that tracks the last processed round. Implement it with a file,
  database, or use the built-in `in_memory_watermark()` helper.
- **sync_behaviour** determines what happens when the subscriber is behind: `skip-sync-newest`,
  `sync-oldest`, `sync-oldest-start-now`, `catchup-with-indexer`, or `fail`.
- **SubscribedTransaction** extends the indexer `Transaction` with `id_`, `filters_matched`,
  `arc28_events`, `balance_changes`, `parent_transaction_id`, and recursive `inner_txns`.
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
| `references/subscriber-lifecycle.md` | `poll_once()`, `start()`, `stop()`, error handling, before/after-poll hooks |
| `references/event-handlers.md` | `on()` per-transaction handlers, `on_batch()` batch handlers, data mappers, fluent chaining |
| `references/transaction-filters.md` | All `TransactionFilter` fields: type, sender, receiver, note_prefix, app_id, asset_id, amount, method_signature, app_on_complete; AND/OR semantics |
| `references/balance-changes.md` | Filtering by balance changes (asset_id, role, amount range), inspecting `.balance_changes`, `BalanceChangeRole` values |
| `references/arc28-events.md` | Defining `Arc28Event`/`Arc28EventGroup`, filtering by emitted events, inspecting `EmittedArc28Event` args, error handling |
| `references/stateless-subscriptions.md` | `get_subscribed_transactions` standalone usage, watermark management, serverless patterns |
| `references/sync-behaviours.md` | All five sync behaviours explained, `max_rounds_to_sync` tuning |
| `references/inner-transactions.md` | Subscribing to inner transactions, ID format `{txId}/inner/{offset}`, navigating `.inner_txns` tree |
| `references/subscribed-transaction.md` | Reading transaction fields (indexer format), `filters_matched`, block metadata, `custom_filter` predicates |

## Common patterns to remember

- `subscriber.poll_once()` executes a single poll — use it for cron/serverless. `subscriber.start()`
  begins continuous polling until `subscriber.stop()` is called.
- `subscriber.on(filter_name, handler)` fires per transaction; `subscriber.on_batch(filter_name, handler)`
  fires once per poll with all matching transactions in that batch.
- `get_subscribed_transactions()` is fully stateless — pass in the watermark and get back results plus
  a `new_watermark`. No class instantiation needed.
- Watermark persistence must be atomic with your processing — persist the new watermark only after
  you have successfully handled all transactions in the batch.
- `catchup-with-indexer` uses the indexer for fast historical sync, then switches to algod for
  real-time blocks. Requires an `IndexerClient` to be provided.
- Inner transaction IDs follow the format `{parentTxId}/inner/{offset}` and carry
  `parent_transaction_id` and `parent_intra_round_offset` for navigation.
- Within a single `TransactionFilter`, all specified fields are AND-ed. Across multiple
  `NamedTransactionFilter` entries in the `filters` array, matching is OR-ed.
- Set `wait_for_block_when_at_tip=True` to have the subscriber wait for a new block via algod's
  `/status/wait-for-block-after` endpoint instead of sleeping when caught up.
- Filters support lists for `sender`, `receiver`, `app_id`, `asset_id`, and `method_signature` —
  any match within the list satisfies that field.
