# Implement ARC Standards (Python)

This reference covers implementing ARC standards in Algorand Python smart contracts and clients. ARC-4 defines the ABI for method calls and type encoding, while ARC-56 provides the modern application specification format for typed client generation.

## ARC-4 Contract Method Example

```python
from algopy import ARC4Contract, arc4

class Calculator(ARC4Contract):
    @arc4.abimethod
    def add(self, a: arc4.UInt64, b: arc4.UInt64) -> arc4.UInt128:
        return arc4.UInt128(a.native + b.native)
```

## Using Typed Clients with ARC-56

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

# Call methods with type hints
result = app_client.send.add(a=10, b=20)
print(result.return_value)  # int: 30
```

## References

- [Python ARC-4 Implementation](./implement-arc-standards-arc4.md) - ARC-4 types, contracts, and client calls
- [Python ARC-32/56 Client Usage](./implement-arc-standards-arc32-arc56.md) - App specs, typed clients, and state access
