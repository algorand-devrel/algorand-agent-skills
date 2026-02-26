# Building Smart Contracts (TypeScript)

Create Algorand smart contracts using Algorand TypeScript (PuyaTs) -- a statically-typed TypeScript subset compiled to TEAL bytecode by the Puya compiler.

## Core Workflow

1. **Search documentation** for concepts and best practices
2. **Retrieve canonical TypeScript examples** from priority repositories
3. **Generate code** following Algorand TypeScript syntax rules
4. **Include integration tests** using generated clients
5. **Build and test** with AlgoKit commands

## TypeScript Repository Priorities

When retrieving examples, search these repositories in order:

1. **`algorandfoundation/devportal-code-examples`**
   - Path: `projects/typescript-examples/contracts/`
   - Best source for common patterns (BoxStorage, state management, etc.)
   - Always include corresponding test files

2. **`algorandfoundation/puya-ts`**
   - Path: `examples/`
   - Examples: `hello_world_arc4/`, `voting/`, `amm/`
   - Best for compiler-level patterns and advanced features

3. **`algorandfoundation/algokit-typescript-template`**
   - Project scaffolding and structure reference
   - Integration test patterns

## TypeScript-Specific Patterns

### File Extension
All Algorand TypeScript contract files must use the `.algo.ts` extension:
```
contracts/MyContract.algo.ts
```

### Clone Pattern
When working with mutable ARC-4 types, use `clone()` to avoid aliasing issues:
```typescript
const copy = original.clone()
```

### Key Syntax Rules

- Contracts extend `Contract` class from `@algorandfoundation/algorand-typescript`
- Use `@abimethod()` decorator for ABI-callable methods
- Use `GlobalState<T>` and `LocalState<T>` for on-chain storage
- Use `itxn` namespace for inner transactions
- Always set `fee: 0` on inner transactions (fee pooling)

For full TypeScript syntax rules, see the `algorand-typescript-syntax` topic and its detailed references.

## Build and Test

```bash
algokit project run build   # Compile contracts
algokit project run test    # Run tests
```

## Important Rules

- **NEVER use PyTEAL or Beaker** -- these are legacy
- **NEVER write raw TEAL** -- always use Algorand TypeScript
- **NEVER import external libraries** into contract code
- **Always search docs first** before writing code
- **Always retrieve TypeScript examples** from priority repositories

## References

- [TypeScript Repository and Pattern Reference](./build-smart-contracts-reference.md)
- [Algorand TypeScript Syntax](./algorand-typescript-syntax.md)
- [TypeScript Syntax Reference](./algorand-typescript-syntax-reference.md)
