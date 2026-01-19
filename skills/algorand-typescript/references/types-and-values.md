# AVM Types and Value Semantics

## Basic AVM Types

| Type | Description | Constructor |
|------|-------------|-------------|
| `uint64` | 64-bit unsigned integer | `Uint64()` |
| `bytes` | Byte array | `Bytes()` |
| `bigint` | Up to 512-bit unsigned integer | `BigUInt` |
| `string` | UTF-8 string | Native strings |
| `bool` | Boolean | `true`/`false` |

## Type Mappings

AVM types don't map to JavaScript primitives:
- JavaScript `number` is signed and unbounded; AVM `uint64` is 64-bit unsigned
- JavaScript `Uint8Array`/`ArrayBuffer` don't exist; use `bytes`

## Objects and Arrays

**Plain TypeScript objects** are supported and mutable:
```typescript
type Point = { x: uint64; y: uint64 }
```

**Plain TypeScript arrays** are supported and mutable:
```typescript
const values: uint64[] = []
const items: Array<uint64> = []
```

**Prefer native types over ARC4**: Plain objects and arrays are more efficient for computations and mutations than `arc4.StaticArray`, `arc4.DynamicArray`, `arc4.Struct`.

## Numbers (CRITICAL)

Puya rejects JavaScript `number` entirely:

```typescript
// CORRECT
const amount: uint64 = Uint64(20)
const total: uint64 = amount + Uint64(100)
return this.counter.value  // Safe if already uint64

// INCORRECT - Compiler error
const amount = 20
const total = amount + 100
```

**Arithmetic type inference**: Explicitly type results to avoid inference as `number`:

```typescript
// CORRECT
const timeout: uint64 = Global.latestTimestamp + timeoutSeconds

// INCORRECT - May infer as number
const timeout = Global.latestTimestamp + timeoutSeconds
```

## String Operations

`string.length` is NOT supported. Use equality checks:

```typescript
// CORRECT
assert(text !== '', 'Text cannot be empty')

// INCORRECT - Compiler error
assert(text.length > 0, 'Text cannot be empty')
assert(text.length <= 200, 'Text too long')
```

## Value Semantics (CRITICAL)

AVM uses value semantics only. Use `clone()` for complex types (structs, arrays, objects):

```typescript
import { clone } from '@algorandfoundation/algorand-typescript'

// GlobalState: clone on read, modify, write
const state = clone(this.appState.value)  // Clone on read
const updated = clone(state)              // Clone for modification
updated.field1 = updated.field1 + amount
this.appState.value = clone(updated)      // Clone on write

// Box: reads OK without clone, writes need clone
const stored = this.someBox.value         // Read OK
const copy = clone(stored)                // Clone for modification
copy.someField = copy.someField + amount
this.someBox.value = clone(copy)          // Clone before write
```

**When to clone**:
- ALWAYS when reading from `GlobalState`, `Box`, `BoxMap`, `LocalState` with complex types
- ALWAYS when assigning structs/arrays to storage
- Even if already cloned, clone again when assigning to storage

**Exception**: Primitive types (`uint64`, `bytes`, `string`, `bool`) stored directly (not in structs) do NOT require `clone()`.

## Union Types (Not Supported)

Cannot use union types like `Item | null` or `string | uint64`:

```typescript
// CORRECT - Use boolean flags
let found = false
let foundItem: Item = { /* default values */ }
for (const item of clone(items)) {
  if (matches(item)) {
    foundItem = clone(item)
    found = true
    break
  }
}
assert(found, 'Item not found')
return foundItem

// INCORRECT - Compiler error
let foundItem: Item | null = null
let value: string | uint64 = someValue
```

## Array Operations

- **AVOID**: `forEach` — use `for...of`
- **AVOID**: `splice` on dynamic arrays — opcode-heavy
- **PREFER**: `StaticArray<uint64, N>` for fixed-size arrays
- **AVOID**: Nested dynamic types (`uint64[][]`) — encode as tuples

**Critical array rules**:
- Functions cannot mutate passed arrays
- Cannot specify array lengths with square brackets (`number[10]` invalid)
- Arrays in object literals must be cloned: `{ todos: clone(array) }`
- Clone arrays before iterating: `for (const item of clone(array))`
- Loop indices must be `uint64`, not `number`:

```typescript
let index = Uint64(0)
for (const item of clone(array)) {
  // use index
  index = index + Uint64(1)
}
```

## Unavailable APIs

These JavaScript APIs are NOT supported (AVM constraints):
- `Uint8Array` / `ArrayBuffer`
- Object methods (`.keys()`, `.values()`, etc.)
- Array length via square brackets
- Standard JavaScript APIs
