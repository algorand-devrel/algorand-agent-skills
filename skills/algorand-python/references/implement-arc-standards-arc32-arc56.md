# ARC-32/56 Client Usage (Python)

This reference covers generating and using ARC-32/ARC-56 application specifications in Python.

## Table of Contents

- [Generating App Specs](#generating-app-specs)
- [Python Client Usage](#python-client-usage)
  - [Factory and Deployment](#factory-and-deployment)
  - [Calling Methods](#calling-methods)
  - [State Access](#state-access)
- [Converting ARC-32 to ARC-56](#converting-arc-32-to-arc-56)
- [Events (ARC-28)](#events-arc-28)

## Generating App Specs

```bash
# Compile Python contract - generates both .arc32.json and .arc56.json
puyapy contracts/my_contract.py

# Or via AlgoKit
algokit project run build
```

Output files:
- `MyContract.arc32.json` - Legacy app spec
- `MyContract.arc56.json` - Modern app spec

### Generate Typed Clients

```bash
# Python client from ARC-56
puyapy-clientgen MyContract.arc56.json

# Or with AlgoKit CLI
algokit generate client -o ./clients MyContract.arc56.json
```

## Python Client Usage

### Factory and Deployment

```python
from algokit_utils import AlgorandClient
from artifacts.calculator_client import CalculatorFactory

algorand = AlgorandClient.default_localnet()

# Deploy new contract
factory = algorand.client.get_typed_app_factory(CalculatorFactory)
app_client, _ = factory.deploy(
    on_schema_break="replace",
    on_update="update",
)
```

### Calling Methods

```python
# Call methods with type hints
result = app_client.send.add(a=10, b=20)
print(result.return_value)  # int: 30
```

### State Access

```python
# Read state
state = app_client.state.global_state.get_all()
print(state["counter"])  # Typed value
```

## Converting ARC-32 to ARC-56

AlgoKit Utils provides a conversion utility for migrating legacy ARC-32 specs:

```python
from algokit_utils.applications.app_spec import arc32_to_arc56

arc56_spec = arc32_to_arc56(arc32_spec)
```

## Events (ARC-28)

Events are emitted using `arc4.emit()` with typed event structs:

```python
from algopy import arc4

class Transfer(arc4.Struct):
    from_addr: arc4.Address
    to_addr: arc4.Address
    amount: arc4.UInt64

# In contract method
arc4.emit(Transfer(
    from_addr=arc4.Address(sender),
    to_addr=arc4.Address(receiver),
    amount=arc4.UInt64(amount),
))
```
