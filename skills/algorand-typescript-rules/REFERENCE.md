# Algorand TypeScript Reference Index

This skill includes detailed reference files for specific topics. Consult these when you need in-depth guidance.

## Reference Files

| File | Topics Covered |
|------|----------------|
| [types-and-values.md](./types-and-values.md) | AVM types, `uint64`, `bytes`, `clone()`, value semantics |
| [storage.md](./storage.md) | GlobalState, LocalState, BoxMap, Box, MBR funding |
| [methods-and-abi.md](./methods-and-abi.md) | Decorators, lifecycle methods, visibility, return types |
| [transactions.md](./transactions.md) | Group transactions (gtxn), inner transactions (itxn) |

## Quick Reference

### Types

| AVM Type | TypeScript | Creation |
|----------|------------|----------|
| uint64 | `uint64` | `Uint64(n)` |
| bytes | `bytes` | `Bytes('...')` |
| string | `string` | Native string |
| bool | `boolean` | Native boolean |
| biguint | `biguint` | `BigUint(n)` |

### Storage

| Type | Scope | Use Case |
|------|-------|----------|
| GlobalState | App-wide | Single values, app config |
| LocalState | Per-account | User-specific data |
| BoxMap | App-wide | Key-value storage, large data |
| Box | App-wide | Single large value |

### Method Decorators

| Decorator | Purpose |
|-----------|---------|
| `@abimethod()` | ABI-callable method |
| `@abimethod({ readonly: true })` | Read-only method |
| `@baremethod({ onCreate: 'require' })` | Create handler |
| `@baremethod({ onUpdate: 'require' })` | Update handler |

### Clone Rules

```typescript
// Always clone when:
const value = clone(this.storage.value)  // Reading from storage
this.storage.value = clone(updated)       // Writing to storage
for (const item of clone(array)) { }      // Iterating arrays
const copy = clone(original)              // Copying complex types
```

## External Documentation

- [Algorand TypeScript Documentation](https://dev.algorand.co/docs/get-started/algokit/typescript)
- [Puya Compiler](https://github.com/algorandfoundation/puya-ts)
- [AVM Specification](https://developer.algorand.org/docs/get-details/dapps/avm/)
