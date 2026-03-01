# Python Smart Contract Repository and Pattern Reference

Python-specific repositories, paths, and patterns for building Algorand smart contracts with PuyaPy.

## Priority Repositories

### Priority 1: DevPortal Code Examples (Python)
**Repository:** `algorandfoundation/devportal-code-examples`
**Path:** `projects/python-examples/contracts/`

Common contract patterns available:
- State management examples (GlobalState, LocalState)
- ARC-4 method examples
- Inner transaction patterns
- Box storage patterns

Always retrieve corresponding test files alongside contracts.

### Priority 2: Puya Compiler Examples
**Repository:** `algorandfoundation/puya`
**Path:** `examples/`

Key examples:
- `hello_world_arc4/` -- Basic ARC-4 contract structure
- `voting/` -- State management, BoxMap patterns, complex logic
- `amm/` -- Advanced patterns (multi-asset, inner transactions, BoxMap)
- Search for `itxn` patterns for inner transaction examples

### Priority 3: AlgoKit Python Template
**Repository:** `algorandfoundation/algokit-python-template`

Provides:
- Project structure and scaffolding
- Build and test configuration
- Integration test patterns with generated clients

## Pattern-Specific Lookups

| Pattern | Where to Look |
|---------|--------------|
| Box storage / BoxMap | `puya/examples/voting/`, `puya/examples/amm/` |
| Inner transactions | `puya/examples/` (search for itxn usage) |
| ARC-4 methods | `puya/examples/hello_world_arc4/` |
| State management | `devportal-code-examples/projects/python-examples/contracts/` |
| AMM / DeFi | `puya/examples/amm/` |
| Voting | `puya/examples/voting/` |
| Decorators | See [build-smart-contracts-decorators.md](./build-smart-contracts-decorators.md) |
| Storage types | See [build-smart-contracts-storage.md](./build-smart-contracts-storage.md) |
| Transactions | See [build-smart-contracts-transactions.md](./build-smart-contracts-transactions.md) |
| Types | See [build-smart-contracts-types.md](./build-smart-contracts-types.md) |

## Supporting Repositories

- `algorandfoundation/algokit-cli` -- CLI tool reference
- `algorandfoundation/algokit-utils-ts` -- Utility functions for deployment and testing
