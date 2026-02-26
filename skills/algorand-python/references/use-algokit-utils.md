# AlgoKit Utils (Python)

AlgoKit Utils for Python is the primary library for building Algorand applications in Python. It provides a high-level, ergonomic interface via the `AlgorandClient` class, which is the single entry point for interacting with the Algorand network -- sending transactions, managing accounts, deploying smart contracts, and more.

## Installation

```bash
pip install algokit-utils
```

## Quick Start

### 1. Create an AlgorandClient

```python
from algokit_utils import AlgorandClient

# Connect to LocalNet (development)
algorand = AlgorandClient.default_localnet()

# Connect to TestNet
algorand = AlgorandClient.testnet()

# Connect to MainNet
algorand = AlgorandClient.mainnet()

# From environment variables (recommended for production)
algorand = AlgorandClient.from_environment()
```

### 2. Get and Register an Account

```python
# Get a random account (testing)
account = algorand.account.random()

# From environment variable (e.g. DEPLOYER_MNEMONIC)
deployer = algorand.account.from_environment("DEPLOYER")

# Register the signer so transactions are automatically signed
algorand.set_signer_from_account(account)
```

### 3. Send a Transaction

```python
from algokit_utils import AlgoAmount, PaymentParams

result = algorand.send.payment(
    PaymentParams(
        sender=account.address,
        receiver="RECEIVERADDRESS",
        amount=AlgoAmount(algo=1),
    )
)
```

## Key Rules

1. **Always use `AlgorandClient`** as the single entry point. Do not instantiate lower-level SDK clients directly.
2. **Use `AlgorandClient.from_environment()`** for production deployments and CI/CD pipelines.
3. **Register signers** with `algorand.set_signer_from_account(account)` before sending transactions so signing is handled automatically.
4. **Use `AlgoAmount`** for all amounts (e.g. `AlgoAmount(algo=1)`, `AlgoAmount(micro_algo=1000)`) instead of raw numbers to avoid unit conversion errors.

## Reference

For the full AlgorandClient API covering client creation, account management, transaction sending, app calls, transaction groups, amount helpers, and common patterns:

[AlgorandClient Reference](./use-algokit-utils-reference.md)

## External Links

- [AlgoKit Utils Python Overview](https://dev.algorand.co/algokit/utils/python/overview/)
- [AlgorandClient API Reference](https://dev.algorand.co/reference/algokit-utils-py/api/algorand/)
- [Transaction Composer](https://dev.algorand.co/algokit/utils/python/transaction-composer/)
- [Account Management](https://dev.algorand.co/algokit/utils/python/account/)
