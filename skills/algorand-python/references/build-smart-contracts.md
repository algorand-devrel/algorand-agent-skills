# Building Smart Contracts (Python)

Create Algorand smart contracts using Algorand Python (PuyaPy) -- a statically-typed Python subset compiled to TEAL bytecode by the Puya compiler.

## Core Workflow

1. **Search documentation** for concepts and best practices
2. **Retrieve canonical Python examples** from priority repositories
3. **Generate code** following Algorand Python syntax rules
4. **Include integration tests** using generated clients
5. **Build and test** with AlgoKit commands

## Python Repository Priorities

When retrieving examples, search these repositories in order:

1. **`algorandfoundation/devportal-code-examples`**
   - Path: `projects/python-examples/contracts/`
   - Best source for common patterns (state management, ABI methods, etc.)
   - Always include corresponding test files

2. **`algorandfoundation/puya`**
   - Path: `examples/`
   - Examples: `hello_world_arc4/`, `voting/`, `amm/`
   - Best for compiler-level patterns and advanced features (BoxMap, inner transactions)

3. **`algorandfoundation/algokit-python-template`**
   - Project scaffolding and structure reference
   - Integration test patterns

## Python-Specific Patterns

### Contract Base Class
Use `ARC4Contract` for contracts that expose ABI methods:
```python
from algopy import ARC4Contract, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def hello(self, name: arc4.String) -> arc4.String:
        return "Hello, " + name
```

### Key Syntax Rules

- Contracts extend `ARC4Contract` from `algopy`
- Use `@arc4.abimethod` decorator for ABI-callable methods
- Use `@arc4.baremethod` for bare methods (no ABI selector, no args)
- Use `@subroutine` for internal reusable functions
- Use `GlobalState`, `LocalState`, `Box`, `BoxMap`, `BoxRef` for storage
- Use `itxn` namespace for inner transactions
- Always set `fee=0` on inner transactions (fee pooling)
- Use ARC-4 types (`arc4.UInt64`, `arc4.String`) for ABI method signatures
- Use native types (`UInt64`, `String`) for internal logic

## Python-Specific Deep-Dive References

For detailed Python syntax patterns, consult these references:

- [Decorators](./build-smart-contracts-decorators.md) -- `@arc4.abimethod`, `@arc4.baremethod`, `@subroutine`, lifecycle methods
- [Storage](./build-smart-contracts-storage.md) -- GlobalState, LocalState, Box, BoxMap, BoxRef, MBR costs
- [Transactions](./build-smart-contracts-transactions.md) -- Inner transactions, group transactions, fee pooling
- [Types](./build-smart-contracts-types.md) -- AVM types (`UInt64`, `Bytes`, `String`), ARC-4 types, reference types

## Build and Test

```bash
algokit project run build   # Compile contracts
algokit project run test    # Run tests
```

## Important Rules

- **NEVER use PyTEAL or Beaker** -- these are legacy, superseded by Puya
- **NEVER write raw TEAL** -- always use Algorand Python
- **NEVER import external libraries** into contract code
- **Always search docs first** before writing code
- **Always retrieve Python examples** from priority repositories

## References

- [Python Repository and Pattern Reference](./build-smart-contracts-reference.md)
