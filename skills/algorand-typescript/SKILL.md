---
name: algorand-typescript
description: Comprehensive guide for Algorand TypeScript (PuyaTs) smart contract development — syntax rules, migration, testing, deployment, React frontends, AlgoKit Utils, ARC standards, and troubleshooting. This is the parent skill for all TypeScript-specific Algorand content. Use when writing TypeScript contract code, encountering Puya compiler errors, migrating from TEALScript or beta, testing contracts with Vitest, deploying with typed clients, building React frontends, or using AlgoKit Utils in TypeScript. Strong triggers include "Puya compiler error", "uint64", "clone()", "BoxMap", ".algo.ts", "migrate from TEALScript", "algorandFixture", "vitest", "deploy contract", "call method", "React frontend", "use-wallet", "AlgorandClient TypeScript", "npm install algokit-utils".
---

# Algorand TypeScript

This is the aggregated parent skill for all TypeScript-specific Algorand development. Use the reference files below to find detailed guidance for each topic.

## Quick Start

```bash
# Create TypeScript project
algokit init -n my-project -t typescript --answer preset_name production --defaults

# Install AlgoKit Utils
npm install @algorandfoundation/algokit-utils

# Development cycle
algokit project run build    # Compile .algo.ts contracts
algokit project run test     # Run Vitest tests
```

### Key TypeScript Rule

Contract files must use `.algo.ts` extension. Use AVM types (`uint64`, `bytes`), never JavaScript `number`. Always `clone()` complex types.

## Reference Guide

Navigate to the appropriate reference based on your task. Each topic has one or more files.

### Algorand TypeScript Syntax

Critical syntax rules for Algorand TypeScript (PuyaTs) that prevent compiler errors.

- [algorand-typescript-syntax.md](./references/algorand-typescript-syntax.md) — Core syntax rules overview
- [algorand-typescript-syntax-reference.md](./references/algorand-typescript-syntax-reference.md) — Full reference index
- [algorand-typescript-syntax-types-and-values.md](./references/algorand-typescript-syntax-types-and-values.md) — AVM types, numbers, clone(), value semantics
- [algorand-typescript-syntax-storage.md](./references/algorand-typescript-syntax-storage.md) — GlobalState, LocalState, BoxMap, MBR funding
- [algorand-typescript-syntax-methods-and-abi.md](./references/algorand-typescript-syntax-methods-and-abi.md) — Decorators, lifecycle methods, visibility
- [algorand-typescript-syntax-transactions.md](./references/algorand-typescript-syntax-transactions.md) — Group transactions (gtxn), inner transactions (itxn)

### Migration to Algorand TypeScript 1.0

Migrate from TEALScript or Algorand TypeScript Beta to 1.0.

- [algorand-ts-migration.md](./references/algorand-ts-migration.md) — Migration workflow and quick reference
- [algorand-ts-migration-from-tealscript.md](./references/algorand-ts-migration-from-tealscript.md) — TEALScript migration guide
- [algorand-ts-migration-from-beta.md](./references/algorand-ts-migration-from-beta.md) — Beta migration guide

### Testing Smart Contracts

Write integration and unit tests using algorandFixture and Vitest.

- [test-smart-contracts.md](./references/test-smart-contracts.md) — Testing patterns and canonical examples
- [test-smart-contracts-examples.md](./references/test-smart-contracts-examples.md) — Complete test examples
- [test-smart-contracts-unit-tests.md](./references/test-smart-contracts-unit-tests.md) — Unit testing guide

### Calling Smart Contracts

Deploy and interact with contracts using generated TypeScript clients.

- [call-smart-contracts.md](./references/call-smart-contracts.md) — Deployment and interaction workflow
- [call-smart-contracts-reference.md](./references/call-smart-contracts-reference.md) — CLI commands reference

### React Frontends

Build React frontends with wallet integration and typed contract clients.

- [deploy-react-frontend.md](./references/deploy-react-frontend.md) — Frontend workflow and signer pattern
- [deploy-react-frontend-reference.md](./references/deploy-react-frontend-reference.md) — API reference
- [deploy-react-frontend-examples.md](./references/deploy-react-frontend-examples.md) — Complete code examples

### Creating TypeScript Projects

Initialize TypeScript AlgoKit projects with proper templates and presets.

- [create-project.md](./references/create-project.md) — TypeScript project creation
- [create-project-reference.md](./references/create-project-reference.md) — TypeScript presets and templates

### Building Smart Contracts (TypeScript)

TypeScript-specific contract building with PuyaTs.

- [build-smart-contracts.md](./references/build-smart-contracts.md) — TypeScript contract building guide
- [build-smart-contracts-reference.md](./references/build-smart-contracts-reference.md) — TypeScript repos and patterns

### AlgoKit Utils (TypeScript)

Interact with Algorand from TypeScript applications.

- [use-algokit-utils.md](./references/use-algokit-utils.md) — TypeScript AlgoKit Utils overview
- [use-algokit-utils-reference.md](./references/use-algokit-utils-reference.md) — AlgorandClient TypeScript API reference

### Implementing ARC Standards (TypeScript)

TypeScript implementations of ARC-4, ARC-32, and ARC-56.

- [implement-arc-standards.md](./references/implement-arc-standards.md) — TypeScript ARC overview
- [implement-arc-standards-arc4.md](./references/implement-arc-standards-arc4.md) — TypeScript ARC-4 implementations
- [implement-arc-standards-arc32-arc56.md](./references/implement-arc-standards-arc32-arc56.md) — TypeScript typed client usage

### Troubleshooting Errors (TypeScript)

TypeScript-specific error diagnosis and fixes.

- [troubleshoot-errors.md](./references/troubleshoot-errors.md) — TypeScript error overview
- [troubleshoot-errors-contract.md](./references/troubleshoot-errors-contract.md) — Contract errors with TypeScript fixes
- [troubleshoot-errors-transaction.md](./references/troubleshoot-errors-transaction.md) — Transaction errors with TypeScript fixes

## Topic Quick Reference

| Topic | Files | Description |
| ----- | ----- | ----------- |
| Syntax Rules | 6 | PuyaTs types, storage, methods, transactions |
| Migration | 3 | TEALScript and beta migration guides |
| Testing | 3 | Vitest integration and unit tests |
| Calling Contracts | 2 | Deployment and typed client interaction |
| React Frontends | 3 | Wallet integration and dApp UI |
| Create Project | 2 | TypeScript template initialization |
| Build Contracts | 2 | TypeScript-focused contract building |
| AlgoKit Utils | 2 | AlgorandClient TypeScript API |
| ARC Standards | 3 | TypeScript ARC implementations |
| Troubleshoot | 3 | TypeScript error fixes |

## How to Use This Skill

1. **Start here** to understand which reference you need
2. **Read the topic `.md`** file for step-by-step guidance
3. **Consult detail files** for specific subtopics (syntax, examples, reference)
4. **For language-agnostic content** (CLI, ARC specs, general workflows), see the `algorand-development` parent skill
