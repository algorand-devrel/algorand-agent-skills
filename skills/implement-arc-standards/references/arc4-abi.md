# ARC-4: Application Binary Interface

ARC-4 defines how to encode method calls, arguments, and return values for Algorand smart contracts. It enables interoperability between contracts, clients, wallets, and explorers.

## Table of Contents

- [ARC-4 Types](#arc-4-types)
  - [Primitive Types](#primitive-types)
  - [Complex Types](#complex-types)
  - [Reference Types](#reference-types-arguments-only)
  - [Transaction Types](#transaction-types-arguments-only)
- [Using ARC-4 Types](#using-arc-4-types)
- [Method Signatures and Selectors](#method-signatures-and-selectors)
- [Encoding Rules](#encoding-rules)
  - [Static vs Dynamic Types](#static-vs-dynamic-types)
  - [Tuple Encoding](#tuple-encoding-head--tail)
  - [Boolean Packing](#boolean-packing)
- [Method Invocation](#method-invocation)
- [Calling ARC-4 Methods](#calling-arc-4-methods)
- [Common Patterns](#common-patterns)
- [Common Mistakes](#common-mistakes)

## ARC-4 Types

### Primitive Types

| Type | Description | Encoding |
|------|-------------|----------|
| `uint<N>` | N-bit unsigned integer (8-512, N%8=0) | Big-endian N bits |
| `byte` | Alias for `uint8` | 1 byte |
| `bool` | Boolean (0 or 1) | MSB of 1 byte; consecutive bools are packed |
| `ufixed<N>x<M>` | Fixed-point decimal | N bits, value = encoded / 10^M |

### Complex Types

| Type | Description | Encoding |
|------|-------------|----------|
| `address` | 32-byte Algorand address | Equivalent to `byte[32]` |
| `string` | UTF-8 encoded text | 2-byte length prefix + bytes |
| `<type>[N]` | Fixed-length array | N elements packed together |
| `<type>[]` | Variable-length array | 2-byte length prefix + elements |
| `(T1,T2,...,TN)` | Tuple | Head (offsets) + Tail (dynamic data) |

### Reference Types (Arguments Only)

| Type | Description | Encoded As |
|------|-------------|------------|
| `account` | Algorand account | `uint8` index into Accounts array |
| `asset` | Algorand Standard Asset | `uint8` index into Foreign Assets array |
| `application` | Algorand Application | `uint8` index into Foreign Apps array |

**Important:** Reference types cannot be used as return types.

### Transaction Types (Arguments Only)

| Type | Description |
|------|-------------|
| `txn` | Any transaction |
| `pay` | Payment transaction |
| `axfer` | Asset transfer transaction |
| `acfg` | Asset config transaction |
| `afrz` | Asset freeze transaction |
| `appl` | Application call transaction |
| `keyreg` | Key registration transaction |

Transaction arguments are encoded as preceding transactions in the group, not in ApplicationArgs.

## Using ARC-4 Types

### Python (Algorand Python)

```python
from algopy import ARC4Contract, arc4, Account, Asset, Application

class MyContract(ARC4Contract):
    @arc4.abimethod
    def demo_types(
        self,
        # Primitive types
        amount: arc4.UInt64,
        flag: arc4.Bool,
        name: arc4.String,

        # Reference types (automatically handled)
        user: Account,      # Passed as Account, encoded as uint8 index
        token: Asset,       # Passed as Asset, encoded as uint8 index
        app: Application,   # Passed as Application, encoded as uint8 index

        # Complex types
        data: arc4.DynamicBytes,
        addr: arc4.Address,
    ) -> arc4.String:
        return arc4.String("Success")

    @arc4.abimethod
    def with_transaction(
        self,
        payment: gtxn.PaymentTransaction,  # Preceding payment in group
        amount: arc4.UInt64,
    ) -> None:
        assert payment.receiver == Global.current_application_address
```

### TypeScript (Algorand TypeScript)

```typescript
import { Contract, Account, Asset, Application, Global } from '@algorandfoundation/algorand-typescript'
import { abimethod, UInt64, Bool, Str, DynamicBytes, Address } from '@algorandfoundation/algorand-typescript/arc4'
import { PaymentTxn } from '@algorandfoundation/algorand-typescript/gtxn'

class MyContract extends Contract {
  @abimethod()
  demoTypes(
    // Primitive types
    amount: UInt64,
    flag: Bool,
    name: Str,

    // Reference types
    user: Account,
    token: Asset,
    app: Application,

    // Complex types
    data: DynamicBytes,
    addr: Address,
  ): Str {
    return new Str('Success')
  }

  @abimethod()
  withTransaction(
    payment: PaymentTxn,  // Preceding payment in group
    amount: UInt64,
  ): void {
    assert(payment.receiver === Global.currentApplicationAddress)
  }
}
```

## Method Signatures and Selectors

### Signature Format

```
method_name(arg1_type,arg2_type,...)return_type
```

- No spaces
- No argument names
- `void` for no return value

### Examples

| Method | Signature |
|--------|-----------|
| `def add(a: UInt64, b: UInt64) -> UInt128` | `add(uint64,uint64)uint128` |
| `def greet(name: String) -> String` | `greet(string)string` |
| `def transfer(to: Account, amt: UInt64) -> None` | `transfer(account,uint64)void` |
| `def process(p: PaymentTxn, d: Bytes) -> None` | `process(pay,byte[])void` |

### Selector Calculation

```python
import hashlib

def get_selector(signature: str) -> bytes:
    """Calculate ARC-4 method selector."""
    hash_bytes = hashlib.sha512_256(signature.encode()).digest()
    return hash_bytes[:4]

# Example
selector = get_selector("add(uint64,uint64)uint128")
# Returns: b'\x8a\xa3\xb6\x1f' (hex: 8aa3b61f)
```

### Getting Selector in Contract

```python
from algopy import arc4

# Get selector for a method
selector = arc4.arc4_signature("add(uint64,uint64)uint128")

# Or from a contract method reference
selector = arc4.arc4_signature(Calculator.add)
```

## Encoding Rules

### Static vs Dynamic Types

**Static types** have fixed size:
- `uint<N>`, `byte`, `bool`, `ufixed<N>x<M>`
- `address` (always 32 bytes)
- `<type>[N]` where `type` is static
- `(T1,...,TN)` where all Ti are static

**Dynamic types** have variable size:
- `string`, `<type>[]`
- `<type>[N]` where `type` is dynamic
- `(T1,...,TN)` where any Ti is dynamic

### Tuple Encoding (Head + Tail)

For a tuple `(T1, T2, ..., TN)`:

1. **Head:** For each element:
   - Static: encode value directly
   - Dynamic: encode 2-byte offset to tail

2. **Tail:** For each dynamic element:
   - Encode the actual data

```
Example: (uint64, string, uint32, string)

Head: [8 bytes uint64][2 byte offset1][4 bytes uint32][2 byte offset2]
Tail: [string1 data][string2 data]

Offsets point to start of each string in tail relative to head start.
```

### Boolean Packing

Up to 8 consecutive booleans are packed into a single byte (MSB first):

```python
# (bool, bool, bool, uint64, bool, bool)
# First 3 bools: packed into 1 byte
# Then uint64: 8 bytes
# Last 2 bools: packed into 1 byte
```

## Method Invocation

### Application Call Structure

```
ApplicationArgs[0]: Method selector (4 bytes)
ApplicationArgs[1]: First argument (encoded)
ApplicationArgs[2]: Second argument (encoded)
...
ApplicationArgs[15]: 15th+ arguments encoded as tuple (if >15 args)

Accounts[]: Referenced accounts (for `account` args)
ForeignAssets[]: Referenced assets (for `asset` args)
ForeignApps[]: Referenced apps (for `application` args)
```

### Return Value

Return values are logged with a specific prefix:

```
Log format: 0x151f7c75 + encoded_return_value

The prefix 151f7c75 = SHA-512/256("return")[:4]
```

### Bare Methods

Bare methods have no selector and no arguments:

```python
from algopy import ARC4Contract, arc4

class MyContract(ARC4Contract):
    @arc4.baremethod(create="require")
    def create(self) -> None:
        """Called on app creation with no args."""
        pass

    @arc4.baremethod(allow_actions=["OptIn"])
    def opt_in(self) -> None:
        """Called on OptIn with no args."""
        pass
```

Bare calls are identified by `NumAppArgs == 0`.

## Calling ARC-4 Methods

### From Another Contract

```python
from algopy import arc4, Application

# Call method on another contract
result, txn = arc4.abi_call(
    OtherContract.some_method,
    arg1,
    arg2,
    app_id=other_app,
)

# Or using method signature
result, txn = arc4.abi_call[arc4.String](
    "greet(string)string",
    arc4.String("World"),
    app_id=other_app,
)
```

### From Client (AlgoKit Utils)

```typescript
// TypeScript
const result = await client.send.add({
  args: { a: 10n, b: 20n }
})

// Access return value
const sum = result.return  // BigInt
```

```python
# Python
result = client.send.add(a=10, b=20)

# Access return value
sum_value = result.return_value
```

## Common Patterns

### Structs (Named Tuples)

```python
from algopy import arc4

class UserInfo(arc4.Struct):
    name: arc4.String
    balance: arc4.UInt64
    active: arc4.Bool

class MyContract(ARC4Contract):
    @arc4.abimethod
    def get_user(self, addr: arc4.Address) -> UserInfo:
        return UserInfo(
            name=arc4.String("Alice"),
            balance=arc4.UInt64(1000),
            active=arc4.Bool(True),
        )
```

### Arrays

```python
from algopy import arc4

# Fixed-size array
Balances = arc4.StaticArray[arc4.UInt64, Literal[10]]

# Dynamic array
Names = arc4.DynamicArray[arc4.String]

class MyContract(ARC4Contract):
    @arc4.abimethod
    def process_list(self, items: arc4.DynamicArray[arc4.UInt64]) -> arc4.UInt64:
        total = arc4.UInt64(0)
        for item in items:
            total = arc4.UInt64(total.native + item.native)
        return total
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using native types in ABI | `def foo(x: int)` won't work | Use `arc4.UInt64` for arguments |
| Returning reference type | `-> Account` is invalid | Return `arc4.Address` instead |
| Wrong selector | Method not found | Verify signature matches exactly |
| Missing transaction arg | Transaction not in group | Add preceding transaction |
| Index out of bounds | Reference type index wrong | Check Accounts/Assets/Apps arrays |

## References

- [ARC-4 Specification](https://dev.algorand.co/arc-standards/arc-0004/)
- [ARC-22 Read-only Methods](https://dev.algorand.co/arc-standards/arc-0022/)
- [ARC-28 Event Logging](https://dev.algorand.co/arc-standards/arc-0028/)
