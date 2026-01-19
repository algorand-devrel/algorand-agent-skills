# Algorand Python Types

Algorand Python provides statically-typed representations of AVM (Algorand Virtual Machine) types. These types differ from standard Python types and are essential for writing correct smart contracts.

## When to use this reference

Use this reference when:

- Writing Algorand Python smart contract code
- Encountering type errors in contract compilation
- Needing to understand differences between Python and AVM types
- Working with numbers, strings, or binary data in contracts

## Core AVM Types

### UInt64

`algopy.UInt64` represents a 64-bit unsigned integer—the primary numeric type on the AVM.

```python
import algopy

# CORRECT - Initialize with integer literal
num = algopy.UInt64(1)
zero = algopy.UInt64()  # Defaults to 0

# CORRECT - Arithmetic operations
total = num + 100
result = num * 2
divided = num // 3  # Must use floor division

# CORRECT - Boolean evaluation (zero is False)
if num:
    algopy.log("Non-zero value")

# INCORRECT - Regular division not allowed
# bad = num / 2  # Error: Use // instead
```

**Key differences from Python `int`:**

| Feature | Python `int` | `algopy.UInt64` |
|---------|--------------|-----------------|
| Range | Unbounded | 0 to 2^64-1 |
| Signed | Yes | No (unsigned only) |
| Division | `/` allowed | Must use `//` |
| Overflow | Never | Errors on overflow |

### Bytes

`algopy.Bytes` represents a byte sequence with a maximum length of 4096 bytes.

```python
import algopy

# CORRECT - Initialize with bytes literal
data = algopy.Bytes(b"abc")
empty = algopy.Bytes()  # Empty bytes

# CORRECT - Concatenation
combined = data + b"def"  # b"abcdef"

# CORRECT - Indexing returns Bytes (not int!)
first = data[0]  # Returns Bytes(b"a"), not 97

# CORRECT - Slicing
slice = data[:2]  # Bytes(b"ab")

# CORRECT - Check containment
if b"ab" in data:
    algopy.log("Found")

# CORRECT - Get length (not len()!)
length = data.length  # UInt64(3)

# CORRECT - Construct from encodings
from_hex = algopy.Bytes.from_hex("FF")
from_base64 = algopy.Bytes.from_base64("RkY=")
from_base32 = algopy.Bytes.from_base32("74======")

# CORRECT - Binary operations
xor_result = data ^ b"xyz"
and_result = data & b"abc"
inverted = ~data
```

**Key differences from Python `bytes`:**

| Feature | Python `bytes` | `algopy.Bytes` |
|---------|----------------|----------------|
| Max length | Memory limit | 4096 bytes |
| Indexing | Returns `int` | Returns `Bytes` |
| Length | `len(x)` | `x.length` |

### String

`algopy.String` represents a UTF-8 encoded string backed by `Bytes`.

```python
import algopy

# CORRECT - Initialize with string literal
text = algopy.String("hello")
empty = algopy.String()

# CORRECT - Concatenation
greeting = text + " world"

# CORRECT - Boolean check (empty is False)
if text:
    algopy.log("Has content")

# CORRECT - String operations
if text.startswith("he"):
    algopy.log("Starts with 'he'")

if text.endswith("lo"):
    algopy.log("Ends with 'lo'")

if "ell" in text:
    algopy.log("Contains 'ell'")

# CORRECT - Join strings
result = algopy.String(", ").join((text, text))  # "hello, hello"

# CORRECT - Access underlying bytes
raw = text.bytes  # Bytes(b"hello")
byte_length = text.bytes.length  # UInt64(5)

# INCORRECT - No indexing or len()
# char = text[0]  # Error: Not supported
# length = len(text)  # Error: Use text.bytes.length
```

**String limitations:**

- No indexing (`text[0]`)
- No slicing (`text[1:3]`)
- No `len()` function (use `.bytes.length` for byte count)
- Expensive containment check (`in` operator)

### BigUInt

`algopy.BigUInt` represents a variable-length unsigned integer up to 512 bits.

```python
import algopy

# CORRECT - Initialize with integer or UInt64
big = algopy.BigUInt(12345678901234567890)
from_uint = algopy.BigUInt(algopy.UInt64(100))

# CORRECT - Arithmetic (same as UInt64)
result = big + 1000
divided = big // 10

# INCORRECT - No power or shift operators
# bad = big ** 2  # Error: Not supported
# bad = big << 2  # Error: Not supported
```

**When to use BigUInt:**

- Numbers exceeding 2^64-1
- Cryptographic operations requiring large integers
- High-precision financial calculations

**Cost consideration:** BigUInt operations are ~10x more expensive than UInt64 operations. Use `algopy.op` wide operations (`addw`, `mulw`) for overflow handling when possible.

## Reference Types

Reference types represent on-chain entities and require "resource availability" to access their properties.

### Account

`algopy.Account` represents an Algorand address.

```python
import algopy

# CORRECT - Initialize with address string
account = algopy.Account("WMHF4FLJNKY2BPFK7YPV5ID6OZ7LVDB2B66ZTXEAMLL2NX4WJZRJFVX66M")

# CORRECT - Initialize from bytes (32 bytes)
from_bytes = algopy.Account(some_32_bytes)

# Zero address (default)
zero_addr = algopy.Account()

# CORRECT - Boolean check (False if zero-address)
if account:
    algopy.log("Valid address")

# CORRECT - Access properties (requires resource availability)
balance = account.balance  # UInt64 in microAlgos
min_bal = account.min_balance
auth = account.auth_address  # Rekeyed address

# CORRECT - Check opt-in status
asset = algopy.Asset(1234)
if account.is_opted_in(asset):
    algopy.log("Opted into asset")

app = algopy.Application(5678)
if account.is_opted_in(app):
    algopy.log("Opted into app")

# CORRECT - Get raw bytes
raw = account.bytes  # 32 bytes
```

**Account properties (require resource availability):**

| Property | Type | Description |
|----------|------|-------------|
| `balance` | `UInt64` | Balance in microAlgos |
| `min_balance` | `UInt64` | Minimum required balance |
| `auth_address` | `Account` | Rekeyed-to address |
| `total_apps_created` | `UInt64` | Apps created by account |
| `total_apps_opted_in` | `UInt64` | Apps account opted into |
| `total_assets_created` | `UInt64` | Assets created |
| `total_extra_app_pages` | `UInt64` | Extra app pages |
| `bytes` | `Bytes` | Raw 32-byte address |

### Asset

`algopy.Asset` represents an Algorand Standard Asset (ASA).

```python
import algopy

# CORRECT - Initialize with asset ID
asset = algopy.Asset(1234)
invalid = algopy.Asset()  # ID 0 (invalid)

# CORRECT - Boolean check (False if ID is 0)
if asset:
    algopy.log("Valid asset")

# CORRECT - Access properties (requires resource availability)
name = asset.name  # Bytes
unit = asset.unit_name  # Bytes
total = asset.total  # UInt64
decimals = asset.decimals  # UInt64
creator = asset.creator  # Account
manager = asset.manager  # Account

# CORRECT - Get balance for an account
account = algopy.Account("...")
balance = asset.balance(account)

# CORRECT - Check frozen status
is_frozen = asset.frozen(account)
```

**Asset properties (require resource availability):**

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UInt64` | Asset ID |
| `name` | `Bytes` | Asset name |
| `unit_name` | `Bytes` | Unit name (ticker) |
| `total` | `UInt64` | Total supply |
| `decimals` | `UInt64` | Decimal places |
| `creator` | `Account` | Creator address |
| `manager` | `Account` | Manager address |
| `reserve` | `Account` | Reserve address |
| `freeze` | `Account` | Freeze address |
| `clawback` | `Account` | Clawback address |
| `default_frozen` | `bool` | Default frozen state |
| `url` | `Bytes` | Asset URL |
| `metadata_hash` | `Bytes` | 32-byte hash |

### Application

`algopy.Application` represents a smart contract application.

```python
import algopy

# CORRECT - Initialize with app ID
app = algopy.Application(5678)
invalid = algopy.Application()  # ID 0 (invalid)

# CORRECT - Boolean check
if app:
    algopy.log("Valid app")

# CORRECT - Access properties (requires resource availability)
creator = app.creator  # Account
address = app.address  # Account (app's address)
```

## Python Built-in Types

Standard Python types have limited support in Algorand Python.

### Supported

| Type | Usage |
|------|-------|
| `bool` | Full support |
| `tuple` | Arguments, return types, local variables |
| `typing.NamedTuple` | Structured data |
| `None` | Return type annotation only |

### Limited Support

```python
# Module-level constants only
MY_CONSTANT: int = 42
MY_STRING: str = "hello"
MY_BYTES: bytes = b"data"

# CORRECT - Use with AVM types
num = algopy.UInt64(MY_CONSTANT)
text = algopy.String(MY_STRING)
data = algopy.Bytes(MY_BYTES)

# INCORRECT - Cannot use as local variables
# def my_method(self) -> None:
#     x: int = 5  # Error: Use UInt64
```

### Not Supported

- `float` — No floating-point on AVM
- Nested tuples
- `None` as a value (only as type annotation)

## ARC-4 Types

ARC-4 types provide ABI-compatible encoding. Import from `algopy.arc4`.

```python
from algopy import arc4

# ARC-4 integers (big-endian encoded)
uint8 = arc4.UInt8(255)
uint64 = arc4.UInt64(12345)
uint256 = arc4.BigUIntN[typing.Literal[256]](...)

# ARC-4 strings (length-prefixed)
arc4_str = arc4.String("hello")
native_str = arc4_str.native  # Convert to algopy.String

# ARC-4 dynamic bytes
dyn_bytes = arc4.DynamicBytes(b"data")

# ARC-4 address (32 bytes)
address = arc4.Address("WMHF4...")
native_account = address.native  # Convert to algopy.Account

# ARC-4 arrays
static_arr = arc4.StaticArray[arc4.UInt8, typing.Literal[4]](...)
dynamic_arr = arc4.DynamicArray[arc4.UInt64](...)
```

**When to use ARC-4 types:**

- ABI method parameters and return values
- Structured data in boxes or state
- Interoperability with other contracts/clients

**Conversion to native types:**

```python
# Use .native property to convert
arc4_value = arc4.UInt64(100)
native_value = arc4_value.native  # algopy.UInt64
```

## Common Mistakes

### Using Python `int` instead of `UInt64`

```python
# INCORRECT
def bad_method(self) -> int:
    x = 5  # Python int not allowed
    return x

# CORRECT
def good_method(self) -> algopy.UInt64:
    x = algopy.UInt64(5)
    return x
```

### Using `len()` instead of `.length`

```python
# INCORRECT
data = algopy.Bytes(b"hello")
# length = len(data)  # Error: len() not supported

# CORRECT
length = data.length  # UInt64(5)
```

### Using `/` instead of `//`

```python
# INCORRECT
# result = algopy.UInt64(10) / 2  # Error

# CORRECT
result = algopy.UInt64(10) // 2  # UInt64(5)
```

### Forgetting resource availability

```python
# Properties require the Account/Asset/Application to be
# in the transaction's reference arrays

def check_balance(self, account: algopy.Account) -> algopy.UInt64:
    # This only works if 'account' is in the accounts array
    return account.balance
```

## Type Comparison Table

| Concept | Python | Algorand Python |
|---------|--------|-----------------|
| Integer | `int` | `UInt64`, `BigUInt` |
| Bytes | `bytes` | `Bytes` |
| String | `str` | `String` |
| Division | `x / y` | `x // y` |
| Length | `len(x)` | `x.length` |
| Iteration | `range()` | `urange()` |
| Enumerate | `enumerate()` | `uenumerate()` |

## References

- [Algorand Python Types Documentation](https://dev.algorand.co/algokit/languages/python/lg-types/)
- [ARC-4 Types](https://dev.algorand.co/algokit/languages/python/lg-arc4/)
- [Python Builtins](https://dev.algorand.co/algokit/languages/python/lg-builtins/)
- [algopy API Reference](https://dev.algorand.co/reference/algorand-python/api/api-algopy/)
