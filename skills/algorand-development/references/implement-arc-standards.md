# Implement ARC Standards

ARC (Algorand Request for Comments) standards define conventions for encoding, method calls, and application specifications on Algorand. This reference covers the most essential ARCs for smart contract development.

## Key ARCs for Smart Contract Development

| ARC | Purpose | When to Use |
|-----|---------|-------------|
| **ARC-4** | Application Binary Interface (ABI) | All smart contract method calls, type encoding |
| **ARC-22** | Read-only method annotation | Methods that don't modify state |
| **ARC-28** | Event logging specification | Emitting structured events |
| **ARC-32** | Application Specification (deprecated) | Legacy app specs (use ARC-56 instead) |
| **ARC-56** | Extended App Description | Modern app specs with full contract metadata |

## ARC-4: The Foundation

ARC-4 defines how to encode method calls and data types for Algorand smart contracts. It enables interoperability between contracts, clients, wallets, and explorers.

### Method Signatures

A method signature uniquely identifies a method: `name(arg_types)return_type`

- No spaces between elements
- No argument names, only types
- `void` for no return value

Examples:

| Method | Signature |
|--------|-----------|
| `add(a: UInt64, b: UInt64) -> UInt128` | `add(uint64,uint64)uint128` |
| `greet(name: String) -> String` | `greet(string)string` |
| `transfer(to: Account, amt: UInt64) -> None` | `transfer(account,uint64)void` |
| `process(p: PaymentTxn, d: Bytes) -> None` | `process(pay,byte[])void` |

### Method Selector Calculation

The method selector is the first 4 bytes of the SHA-512/256 hash of the method signature:

```
Method signature: add(uint64,uint64)uint128
SHA-512/256 hash: 8aa3b61f0f1965c3a1cbfa91d46b24e54c67270184ff89dc114e877b1753254a
Method selector: 8aa3b61f (first 4 bytes)
```

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

## ARC-32 vs ARC-56

| Feature | ARC-32 | ARC-56 |
|---------|--------|--------|
| **Status** | Deprecated | Current Standard |
| **ARC-4 methods** | Yes | Yes |
| **State schema** | Yes | Yes |
| **Method hints** | Partial | Full |
| **Named structs** | No | Yes |
| **Default argument values** | Limited | Full support |
| **Source code info** | No | Yes (optional) |
| **Source maps** | No | Yes (optional) |
| **ARC-28 events** | No | Yes |
| **Bare action config** | Yes | Yes |
| **Template variables** | No | Yes |
| **Scratch variables** | No | Yes |

**Use ARC-56** for all new projects. ARC-32 is maintained for legacy compatibility only.

## Important Rules / Guidelines

| Rule | Details |
|------|---------|
| **ARC-4 types only in ABI** | Use `arc4.UInt64`, `arc4.String`, etc. for method arguments and returns |
| **Reference types as arguments only** | `account`, `asset`, `application` cannot be return types |
| **15 argument limit** | Methods with 16+ args encode extras as a tuple in arg 15 |
| **Return prefix** | Return values are logged with `151f7c75` prefix |
| **Bare methods have no selector** | Bare calls use `NumAppArgs == 0` for routing |

## References

- [ARC-4 ABI Details](./implement-arc-standards-arc4.md) - Types, encoding rules, method invocation
- [ARC-32/56 App Specs](./implement-arc-standards-arc32-arc56.md) - Application specification details
- [ARC Standards](https://dev.algorand.co/arc-standards/) - Official ARC documentation
