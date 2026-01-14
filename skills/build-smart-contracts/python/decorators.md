# Algorand Python Decorators

Define smart contract methods and their behavior using decorators in Algorand Python.

## When to use this reference

Use this reference when:

- Creating ABI methods that external callers can invoke
- Defining bare methods for application lifecycle operations
- Writing internal subroutines for code reuse
- Controlling method visibility and call permissions
- Handling application create, update, delete, and opt-in actions

## Contract Base Classes

### ARC4Contract (Recommended)

Use `ARC4Contract` for contracts that expose ABI methods.

```python
from algopy import ARC4Contract, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def hello(self, name: arc4.String) -> arc4.String:
        return "Hello, " + name
```

### Contract (Low-Level)

Use `Contract` for raw approval/clear program control.

```python
from algopy import Contract, UInt64

class MyContract(Contract):
    def approval_program(self) -> UInt64:
        return UInt64(1)  # Approve

    def clear_state_program(self) -> UInt64:
        return UInt64(1)  # Approve
```

## @arc4.abimethod

Marks a method as an ABI method callable by external transactions.

### Basic Usage

```python
from algopy import ARC4Contract, arc4, UInt64

class MyContract(ARC4Contract):
    @arc4.abimethod
    def add(self, a: arc4.UInt64, b: arc4.UInt64) -> arc4.UInt64:
        return arc4.UInt64(a.native + b.native)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `str` | Method name | Override method name in ABI |
| `create` | `"allow"`, `"require"`, `"disallow"` | `"disallow"` | Application creation behavior |
| `allow_actions` | `list[str]` | `["NoOp"]` | Allowed OnComplete actions |
| `readonly` | `bool` | `False` | Mark as read-only (no state changes) |
| `default_args` | `dict` | `{}` | Default argument sources |

### Application Creation

```python
from algopy import ARC4Contract, arc4, String

class MyContract(ARC4Contract):
    def __init__(self) -> None:
        self.name = String()

    # CORRECT - Method that creates the application
    @arc4.abimethod(create="require")
    def create(self, name: arc4.String) -> None:
        self.name = name.native

    # CORRECT - Method that can optionally create
    @arc4.abimethod(create="allow")
    def initialize(self, name: arc4.String) -> None:
        self.name = name.native

    # CORRECT - Method that cannot create (default)
    @arc4.abimethod  # create="disallow" is default
    def update_name(self, name: arc4.String) -> None:
        self.name = name.native
```

### OnComplete Actions

```python
from algopy import ARC4Contract, arc4, Txn

class MyContract(ARC4Contract):
    # CORRECT - Allow opt-in calls
    @arc4.abimethod(allow_actions=["OptIn"])
    def opt_in(self) -> None:
        pass

    # CORRECT - Allow close-out calls
    @arc4.abimethod(allow_actions=["CloseOut"])
    def close_out(self) -> None:
        pass

    # CORRECT - Allow update calls (requires UpdateApplication)
    @arc4.abimethod(allow_actions=["UpdateApplication"])
    def update(self) -> None:
        assert Txn.sender == self.creator

    # CORRECT - Allow delete calls
    @arc4.abimethod(allow_actions=["DeleteApplication"])
    def delete(self) -> None:
        assert Txn.sender == self.creator

    # CORRECT - Allow multiple actions
    @arc4.abimethod(allow_actions=["NoOp", "OptIn"])
    def register(self) -> None:
        pass
```

### Read-Only Methods

```python
from algopy import ARC4Contract, arc4, UInt64

class MyContract(ARC4Contract):
    def __init__(self) -> None:
        self.counter = UInt64(0)

    # CORRECT - Mark as read-only for simulation
    @arc4.abimethod(readonly=True)
    def get_counter(self) -> arc4.UInt64:
        return arc4.UInt64(self.counter)
```

### Custom Method Names

```python
from algopy import ARC4Contract, arc4

class MyContract(ARC4Contract):
    # CORRECT - Override ABI method name
    @arc4.abimethod(name="getBalance")
    def get_balance(self) -> arc4.UInt64:
        return arc4.UInt64(0)
```

### Default Arguments

```python
from algopy import ARC4Contract, arc4, Asset, Global

class MyContract(ARC4Contract):
    def __init__(self) -> None:
        self.asset = Asset()

    # CORRECT - Default arg from state or constant
    @arc4.abimethod(
        default_args={
            "asset": "asset",  # From self.asset
            "sender": "global.creator_address"  # From Global
        }
    )
    def transfer(self, asset: Asset, sender: arc4.Address) -> None:
        pass
```

## @arc4.baremethod

Marks a method as a bare method (no ABI selector, no arguments/return).

### Basic Usage

```python
from algopy import ARC4Contract, arc4

class MyContract(ARC4Contract):
    # CORRECT - Bare method for creation
    @arc4.baremethod(create="require")
    def create(self) -> None:
        pass

    # CORRECT - Bare method for opt-in
    @arc4.baremethod(allow_actions=["OptIn"])
    def opt_in(self) -> None:
        pass
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `create` | `"allow"`, `"require"`, `"disallow"` | `"disallow"` | Application creation behavior |
| `allow_actions` | `list[str]` | `["NoOp"]` | Allowed OnComplete actions |

### Common Bare Method Patterns

```python
from algopy import ARC4Contract, arc4, Txn

class MyContract(ARC4Contract):
    # CORRECT - Bare create (no arguments needed)
    @arc4.baremethod(create="require")
    def create(self) -> None:
        pass

    # CORRECT - Bare update
    @arc4.baremethod(allow_actions=["UpdateApplication"])
    def update(self) -> None:
        assert Txn.sender == self.creator

    # CORRECT - Bare delete
    @arc4.baremethod(allow_actions=["DeleteApplication"])
    def delete(self) -> None:
        assert Txn.sender == self.creator

    # CORRECT - Bare opt-in
    @arc4.baremethod(allow_actions=["OptIn"])
    def opt_in(self) -> None:
        pass

    # CORRECT - Bare close-out
    @arc4.baremethod(allow_actions=["CloseOut"])
    def close_out(self) -> None:
        pass
```

## @subroutine

Marks a function as a reusable subroutine (internal, not callable externally).

### Basic Usage

```python
from algopy import ARC4Contract, arc4, UInt64, subroutine

class MyContract(ARC4Contract):
    @arc4.abimethod
    def calculate(self, value: arc4.UInt64) -> arc4.UInt64:
        result = self._double(value.native)
        return arc4.UInt64(result)

    # CORRECT - Private subroutine
    @subroutine
    def _double(self, value: UInt64) -> UInt64:
        return value * UInt64(2)
```

### Module-Level Subroutines

```python
from algopy import ARC4Contract, arc4, UInt64, subroutine

# CORRECT - Module-level subroutine
@subroutine
def calculate_fee(amount: UInt64) -> UInt64:
    return amount * UInt64(3) // UInt64(100)

class MyContract(ARC4Contract):
    @arc4.abimethod
    def process(self, amount: arc4.UInt64) -> arc4.UInt64:
        fee = calculate_fee(amount.native)
        return arc4.UInt64(fee)
```

### Inline Parameter

Control whether the subroutine is inlined at call sites.

```python
from algopy import subroutine, UInt64

# CORRECT - Force inlining (small, frequently called)
@subroutine(inline=True)
def is_valid(value: UInt64) -> bool:
    return value > UInt64(0)

# CORRECT - Prevent inlining (large, called multiple times)
@subroutine(inline=False)
def complex_calculation(a: UInt64, b: UInt64, c: UInt64) -> UInt64:
    # Complex logic here
    return a * b + c

# CORRECT - Let compiler decide (default)
@subroutine  # inline="auto" is default
def helper(value: UInt64) -> UInt64:
    return value + UInt64(1)
```

## Lifecycle Methods

### __init__ (State Initialization)

```python
from algopy import ARC4Contract, UInt64, String

class MyContract(ARC4Contract):
    def __init__(self) -> None:
        # Initialize state - runs on application creation
        self.counter = UInt64(0)
        self.name = String("default")
```

### clear_state_program (Clear State)

```python
from algopy import ARC4Contract, UInt64

class MyContract(ARC4Contract):
    # CORRECT - Custom clear state logic
    def clear_state_program(self) -> UInt64:
        # Return 1 to approve, 0 to reject
        return UInt64(1)
```

## Method Visibility Summary

| Decorator | Externally Callable | Has ABI Selector | Can Have Args/Return |
|-----------|---------------------|------------------|----------------------|
| `@arc4.abimethod` | Yes | Yes | Yes |
| `@arc4.baremethod` | Yes | No | No |
| `@subroutine` | No | No | Yes |
| (no decorator) | No | No | Yes (internal only) |

## Common Mistakes

### Using abimethod for Internal Logic

```python
# INCORRECT - Internal logic exposed as ABI method
@arc4.abimethod
def _calculate_fee(self, amount: arc4.UInt64) -> arc4.UInt64:
    return arc4.UInt64(amount.native * UInt64(3) // UInt64(100))

# CORRECT - Use subroutine for internal logic
@subroutine
def _calculate_fee(self, amount: UInt64) -> UInt64:
    return amount * UInt64(3) // UInt64(100)
```

### Forgetting create Parameter for Creation Methods

```python
# INCORRECT - Cannot call this during creation
@arc4.abimethod
def create_app(self, name: arc4.String) -> None:
    self.name = name.native

# CORRECT - Explicitly allow or require creation
@arc4.abimethod(create="require")
def create_app(self, name: arc4.String) -> None:
    self.name = name.native
```

### Arguments on Bare Methods

```python
# INCORRECT - Bare methods cannot have arguments
@arc4.baremethod
def opt_in(self, user_name: arc4.String) -> None:  # Error!
    pass

# CORRECT - Use abimethod if you need arguments
@arc4.abimethod(allow_actions=["OptIn"])
def opt_in(self, user_name: arc4.String) -> None:
    pass

# CORRECT - Bare method without arguments
@arc4.baremethod(allow_actions=["OptIn"])
def opt_in(self) -> None:
    pass
```

### Missing Return Type on Subroutines

```python
# INCORRECT - Missing return type annotation
@subroutine
def calculate(value: UInt64):
    return value * UInt64(2)

# CORRECT - Include return type
@subroutine
def calculate(value: UInt64) -> UInt64:
    return value * UInt64(2)
```

### Using Native Types in ABI Method Signatures

```python
# INCORRECT - ABI methods should use arc4 types for args/return
@arc4.abimethod
def add(self, a: UInt64, b: UInt64) -> UInt64:
    return a + b

# CORRECT - Use arc4 types in signature
@arc4.abimethod
def add(self, a: arc4.UInt64, b: arc4.UInt64) -> arc4.UInt64:
    return arc4.UInt64(a.native + b.native)
```

## References

- [Algorand Python Contract Structure](https://dev.algorand.co/algokit/languages/python/lg-contract-structure/)
- [ARC-4 ABI Methods](https://dev.algorand.co/algokit/languages/python/lg-arc4/)
- [algopy API Reference](https://dev.algorand.co/reference/algorand-python/api/api-algopy/)
- [algopy.arc4 Reference](https://dev.algorand.co/reference/algorand-python/api/api-algopy-arc4/)
