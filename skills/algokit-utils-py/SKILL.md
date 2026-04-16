---
name: algokit-utils-py
description: >
  Guide for writing Python code with AlgoKit Utils (`algokit-utils`).
  Use this skill whenever the user is building on Algorand with Python — including client setup,
  account management, payments, asset operations (ASA create/opt-in/transfer/freeze/destroy),
  atomic transaction groups, smart contract deployment and interaction (AppFactory, AppClient,
  ARC-56/ARC-32 app specs), raw app calls, TEAL compilation, key registration, network management,
  and error handling. Trigger on imports from `algokit_utils`, references to `AlgorandClient`,
  `AppFactory`, `AppClient`, `AlgoAmount`, or any Algorand Python development context. Also trigger
  when the user mentions AlgoKit, algokit-utils, or asks how to do something on Algorand in Python.
---

# AlgoKit Utils Python — Quick Reference

This skill targets **version 5.x** of `algokit-utils`.

This skill provides idiomatic patterns for `algokit-utils` (Python).
When helping users, prefer the patterns below over raw `algosdk` calls — AlgoKit Utils wraps the
SDK with higher-level, type-safe abstractions.

## How to use this skill

Reference docs are split into individual files under `references/`. Only read the file(s) relevant
to the user's question — this keeps context lean. The table below maps topics to filenames.

## Key concepts

- **AlgorandClient** is the single entry point. Create one via `AlgorandClient.default_localnet()`,
  `.testnet()`, `.mainnet()`, `.from_config()`, `.from_clients()`, or `.from_environment()`.
- **AlgoAmount** provides type-safe Algo/microAlgo values. Use `algo(5)`, `micro_algo(1000)`,
  `AlgoAmount.from_algo(5)`, or `AlgoAmount(algo=5)`.
- **AccountManager** (`algorand.account.*`) handles key generation, mnemonics, multisig, logic
  sigs, rekeyed accounts, funding, and signer registration.
- **TransactionComposer** (`algorand.new_group()`) builds atomic groups with fluent chaining.
  Supports `.add_payment()`, `.add_asset_transfer()`, `.add_app_call_method_call()`, etc.
- **AppFactory** creates and deploys smart contracts from ARC-56/ARC-32 app specs. Supports
  idempotent deploy with `on_update`/`on_schema_break` strategies and template variable substitution.
- **AppClient** interacts with deployed contracts — ABI method calls, state reads (global, local,
  box), bare calls, and the `params` builder for deferred composition.
- **Raw app calls** via `algorand.send.app_call()`, `.app_create()`, `.app_update()`,
  `.app_delete()`, `.app_call_method_call()`, `.app_create_method_call()` when you don't have an app spec.
- **TEAL compilation** via `algorand.app.compile_teal()` and `.compile_teal_template()` with
  caching and template variable substitution.

## Key Python-specific differences from TypeScript

- Parameter objects use dataclasses (e.g., `PaymentParams`, `AssetCreateParams`) — pass them
  positionally to `algorand.send.*` methods.
- `AlgoAmount.algo` returns `Decimal` (not `number`); `.micro_algo` returns `int` (not `bigint`).
- `asset_opt_out()` takes `ensure_zero_balance` as a keyword argument outside the params object.
- `from_clients()` accepts pre-created SDK clients (`AlgodClient`, `IndexerClient`, `KmdClient`).
- Error types: `LogicError` (AVM failures), `TransactionComposerError` (group failures).
- Error transformers are sync functions `(Exception) -> Exception`, not async.

## Reference file index

Read only the file(s) relevant to the user's current question.

| File | What it covers |
|------|---------------|
| `references/getting-started.md` | Installation (`pip install algokit-utils`), imports, LocalNet prerequisites |
| `references/client-initialization.md` | LocalNet, TestNet, MainNet, custom config, from_clients, env vars |
| `references/account-management.md` | Random accounts, mnemonics, rekeyed, multisig, logic sigs, funding, signers |
| `references/algoamount-and-value-handling.md` | `algo()`, `micro_algo()`, conversions, transaction fees |
| `references/payment-transactions.md` | Simple payments, unsigned txns, notes, leases, fee control, close account |
| `references/asset-operations.md` | Create, opt-in/out, transfer, freeze, config, destroy, bulk ops, get info |
| `references/key-registration.md` | Online/offline key registration for consensus participation |
| `references/transaction-composition.md` | Atomic groups, multi-signer, atomic swaps, build/send/simulate, clone |
| `references/smart-contract-deployment.md` | AppFactory, bare/ABI create, idempotent deploy, template vars |
| `references/smart-contract-interaction.md` | AppClient, ABI calls, bare calls, global/local/box state, params builder |
| `references/raw-app-calls.md` | Low-level app create/call/update/delete, ABI method calls without app spec |
| `references/compile-teal.md` | compile_teal, compile_teal_template, template variable substitution |
| `references/network-and-client-management.md` | Algod/indexer/kmd access, LocalNet detection, validity window, params cache |
| `references/configuration-and-global-settings.md` | `populate_app_call_resources`, debug mode, trace collection, logging |
| `references/error-handling.md` | LogicError, parse_logic_error, TransactionComposerError, error transformers |

## Common patterns to remember

- `algorand.send.*` builds, signs, and submits in one call.
- `algorand.create_transaction.*` builds without signing or sending.
- `app_client.params.*` builds call params for deferred use in groups.
- `app_client.send.bare.*` for bare calls; `app_client.send.call()` for ABI calls.
- Readonly ABI methods (marked in ARC-56) automatically use `simulate` — no fees spent.
- `algorand.account.ensure_funded()` is idempotent — skips if balance is already sufficient.
- `factory.deploy()` is idempotent — creates, updates, replaces, or no-ops based on state.
- Use `config.configure(populate_app_call_resources=True)` to auto-populate app call resources.
- `Method.from_signature("hello(string)string")` for raw ABI method calls without app spec.
