# ARC-4 Implementation (Python)

This reference covers implementing and calling ARC-4 methods in Algorand Python.

## Table of Contents

- [Using ARC-4 Types in Contracts](#using-arc-4-types-in-contracts)
- [Calling ARC-4 Methods](#calling-arc-4-methods)
  - [From Another Contract](#from-another-contract)
  - [From Client (AlgoKit Utils)](#from-client-algokit-utils)
- [Common ARC-4 Patterns](#common-arc-4-patterns)
  - [Structs](#structs)
  - [Arrays](#arrays)
  - [Bare Methods](#bare-methods)

## Using ARC-4 Types in Contracts

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

## Calling ARC-4 Methods

### From Another Contract

```python
from algopy import arc4, Application

# Call method on another contract using method reference
result, txn = arc4.abi_call(
    OtherContract.some_method,
    arg1,
    arg2,
    app_id=other_app,
)

# Or using method signature string
result, txn = arc4.abi_call[arc4.String](
    "greet(string)string",
    arc4.String("World"),
    app_id=other_app,
)
```

### From Client (AlgoKit Utils)

```python
result = client.send.add(a=10, b=20)

# Access return value
sum_value = result.return_value
```

### Getting Selector in Contract

```python
from algopy import arc4

# Get selector for a method by signature string
selector = arc4.arc4_signature("add(uint64,uint64)uint128")

# Or from a contract method reference
selector = arc4.arc4_signature(Calculator.add)
```

## Common ARC-4 Patterns

### Structs

```python
from algopy import ARC4Contract, arc4

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
from algopy import ARC4Contract, arc4
from typing import Literal

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

### Bare Methods

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
