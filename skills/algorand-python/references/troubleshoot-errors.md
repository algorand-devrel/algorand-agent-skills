# Troubleshoot Errors (Python)

Diagnose and resolve common Algorand development errors when working with Python and AlgoKit Utils Python.

## Error References

| Category | Description | Reference |
|----------|-------------|-----------|
| Contract Errors | Assert failures, opcode budget, ABI issues, state errors | [troubleshoot-errors-contract.md](./troubleshoot-errors-contract.md) |
| Transaction Errors | Overspend, invalid params, group issues, asset/account errors | [troubleshoot-errors-transaction.md](./troubleshoot-errors-transaction.md) |

## Python Debugging Quick Start

### Enable Debug Logging

```python
import logging
logging.getLogger("algokit").setLevel(logging.DEBUG)
```

### Catch and Inspect LogicError

```python
from algokit_utils import LogicError

try:
    app_client.send.my_method(value=0)
except LogicError as e:
    print(e)       # Shows: assert failed at contracts/my_contract.py:45
    print(e.pc)    # Program counter: 123
    print(e.line)  # Source line number
```

### Check Transaction Status

```python
# Check pending transaction
pending = algorand.client.algod.pending_transaction_info(tx_id)
print("Pool error:", pending.get("pool-error", ""))
```

## How to Proceed

1. **Find your error** in the contract or transaction error references
2. **Understand the cause** from the explanation
3. **Apply the Python fix** from the code examples
