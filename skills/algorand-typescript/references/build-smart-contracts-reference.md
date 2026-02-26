# TypeScript Smart Contract Repository and Pattern Reference

TypeScript-specific repositories, paths, and patterns for building Algorand smart contracts with PuyaTs.

## Priority Repositories

### Priority 1: DevPortal Code Examples (TypeScript)
**Repository:** `algorandfoundation/devportal-code-examples`
**Path:** `projects/typescript-examples/contracts/`

Common contract patterns available:
- `BoxStorage/` -- Box, BoxMap, BoxRef patterns
- State management examples (GlobalState, LocalState)
- ARC-4 method examples
- Inner transaction patterns

Always retrieve corresponding test files alongside contracts.

### Priority 2: Puya-TS Compiler Examples
**Repository:** `algorandfoundation/puya-ts`
**Path:** `examples/`

Key examples:
- `hello_world_arc4/` -- Basic ARC-4 contract structure
- `voting/` -- State management and complex logic
- `amm/` -- Advanced patterns (multi-asset, inner transactions)
- Search for `itxn` patterns for inner transaction examples

### Priority 3: AlgoKit TypeScript Template
**Repository:** `algorandfoundation/algokit-typescript-template`

Provides:
- Project structure and scaffolding
- Build and test configuration
- Integration test patterns with generated clients

## Pattern-Specific Lookups

| Pattern | Where to Look |
|---------|--------------|
| Box storage | `devportal-code-examples/projects/typescript-examples/contracts/BoxStorage/` |
| Inner transactions | `puya-ts/examples/` (search for itxn usage) |
| ARC-4 methods | `puya-ts/examples/hello_world_arc4/` |
| State management | `devportal-code-examples/projects/typescript-examples/contracts/` |
| AMM / DeFi | `puya-ts/examples/amm/` |
| Voting | `puya-ts/examples/voting/` |

## Supporting Repositories

- `algorandfoundation/algokit-cli` -- CLI tool reference
- `algorandfoundation/algokit-client-generator-ts` -- Generated client patterns
- `algorandfoundation/algokit-utils-ts` -- Utility functions for deployment and testing
