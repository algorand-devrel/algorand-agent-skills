---
name: algokit-utils-ts
description: >
  Guide for writing TypeScript code with AlgoKit Utils (`@algorandfoundation/algokit-utils`).
  Use this skill whenever the user is building on Algorand with TypeScript — including client setup,
  account management, payments, asset operations (ASA create/opt-in/transfer/freeze/destroy),
  atomic transaction groups, smart contract deployment and interaction (AppFactory, AppClient,
  ARC-56/ARC-32 app specs), raw app calls, key registration, network management, testing with
  algorandFixture, and error handling. Trigger on imports from `@algorandfoundation/algokit-utils`,
  references to `AlgorandClient`, `AppFactory`, `AppClient`, `AlgoAmount`, `algorandFixture`,
  or any Algorand TypeScript development context. Also trigger when the user mentions AlgoKit,
  algokit-utils, or asks how to do something on Algorand in TypeScript/JavaScript.
---

# AlgoKit Utils TypeScript — Quick Reference

This skill targets **version 10.x** of `@algorandfoundation/algokit-utils`.

This skill provides idiomatic patterns for `@algorandfoundation/algokit-utils` (TypeScript).
When helping users, prefer the patterns below over raw `algosdk` calls — AlgoKit Utils wraps the
SDK with higher-level, type-safe abstractions.

## How to use this skill

Reference docs are split into individual files under `references/`. Only read the file(s) relevant
to the user's question — this keeps context lean. The table below maps topics to filenames.

## Key concepts

- **AlgorandClient** is the single entry point. Create one via `AlgorandClient.defaultLocalNet()`,
  `.testNet()`, `.mainNet()`, `.fromConfig()`, or `.fromEnvironment()`.
- **AlgoAmount** provides type-safe Algo/microAlgo values. Use `algo(5)`, `microAlgo(1000)`,
  `AlgoAmount.Algo(5)`, or the prototype extensions `(5).algo()`.
- **AccountManager** (`algorand.account.*`) handles key generation, mnemonics, multisig, logic
  sigs, funding, and signer registration.
- **TransactionComposer** (`algorand.newGroup()`) builds atomic groups with fluent chaining.
  Supports `.addPayment()`, `.addAssetTransfer()`, `.addAppCallMethodCall()`, etc.
- **AppFactory** creates and deploys smart contracts from ARC-56/ARC-32 app specs. Supports
  idempotent deploy with `onUpdate`/`onSchemaBreak` strategies and template variable substitution.
- **AppClient** interacts with deployed contracts — ABI method calls, state reads (global, local,
  box), bare calls, and the `params` builder for deferred composition.
- **Raw app calls** via `algorand.send.appCall()`, `.appCreate()`, `.appUpdate()`, `.appDelete()`,
  `.appCallMethodCall()`, `.appCreateMethodCall()` when you don't have an app spec.

## Reference file index

Read only the file(s) relevant to the user's current question.

| File | What it covers |
|------|---------------|
| `references/getting-started.md` | Installation, imports, LocalNet prerequisites |
| `references/client-initialization.md` | LocalNet, TestNet, MainNet, custom config, env vars |
| `references/account-management.md` | Random accounts, mnemonics, multisig, logic sigs, funding, signers |
| `references/algoamount-and-value-handling.md` | `algo()`, `microAlgo()`, conversions, prototype extensions, fees |
| `references/payment-transactions.md` | Simple payments, unsigned txns, notes, leases, fee control |
| `references/asset-operations.md` | Create, opt-in/out, transfer, freeze, config, destroy, bulk ops, get info |
| `references/key-registration.md` | Online/offline key registration for consensus participation |
| `references/transaction-composition.md` | Atomic groups, build/send/simulate, fee control, clone |
| `references/smart-contract-deployment.md` | AppFactory, bare/ABI create, idempotent deploy, template vars |
| `references/smart-contract-interaction.md` | AppClient, ABI calls, bare calls, global/local/box state, params builder |
| `references/raw-app-calls.md` | Low-level app create/call/update/delete, ABI method calls without app spec |
| `references/network-and-client-management.md` | Algod/indexer/kmd access, LocalNet detection, rounds, timestamps, time/block warp |
| `references/configuration-and-global-settings.md` | `populateAppCallResources`, confirmation rounds, logging |
| `references/testing-utilities.md` | `algorandFixture`, `newScope`, `generateAccount`, transaction logger, log capture, indexer waits |
| `references/error-handling.md` | Try/catch patterns, error transformers, overspend, app call rejections |

## Common patterns to remember

- `algorand.send.*` builds, signs, and submits in one call.
- `algorand.createTransaction.*` builds without signing or sending.
- `appClient.params.*` builds call params for deferred use in groups or nested args.
- `appClient.send.bare.*` for bare calls; `appClient.send.call()` for ABI calls.
- Readonly ABI methods (marked in ARC-56) automatically use `simulate` — no fees spent.
- `algorand.account.ensureFunded()` is idempotent — skips if balance is already sufficient.
- `factory.deploy()` is idempotent — creates, updates, replaces, or no-ops based on state.
- Use `Config.configure({ populateAppCallResources: true })` to auto-populate app call resources.
