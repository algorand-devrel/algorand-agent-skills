# AlgorandClient (Python)

The main entry point for interacting with Algorand in Python applications.

## Installation

```bash
pip install algokit-utils
```

## Creating an AlgorandClient

```python
from algokit_utils import AlgorandClient

# From environment variables (recommended for production)
algorand = AlgorandClient.from_environment()

# Default LocalNet configuration
algorand = AlgorandClient.default_localnet()

# TestNet using AlgoNode free tier
algorand = AlgorandClient.testnet()

# MainNet using AlgoNode free tier
algorand = AlgorandClient.mainnet()

# From existing clients
algorand = AlgorandClient.from_clients(algod=algod, indexer=indexer, kmd=kmd)

# From custom configuration
from algokit_utils import AlgoClientNetworkConfig

algorand = AlgorandClient.from_config(
    algod_config=AlgoClientNetworkConfig(
        server="http://localhost",
        port="4001",
        token="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    )
)
```

## Accessing SDK Clients

```python
algod_client = algorand.client.algod
indexer_client = algorand.client.indexer
kmd_client = algorand.client.kmd
```

## Account Management

### Getting Accounts

```python
# From environment variable (DEPLOYER_MNEMONIC)
deployer = algorand.account.from_environment("DEPLOYER")

# Random account (for testing)
random_account = algorand.account.random()

# From mnemonic
account = algorand.account.from_mnemonic("abandon abandon...")

# From KMD (LocalNet)
kmd_account = algorand.account.from_kmd("wallet-name", "password")
```

### Registering Signers

```python
# Register a signer for automatic signing
algorand.set_signer_from_account(account)

# Set default signer for all transactions
algorand.set_default_signer(account.signer)
```

## Sending Transactions

### Single Transactions

```python
from algokit_utils import AlgoAmount, PaymentParams, AssetTransferParams
from algokit_utils import AssetOptInParams, AssetCreateParams

# Payment
result = algorand.send.payment(
    PaymentParams(
        sender="SENDERADDRESS",
        receiver="RECEIVERADDRESS",
        amount=AlgoAmount(algo=1),
    )
)

# Asset transfer
algorand.send.asset_transfer(
    AssetTransferParams(
        sender="SENDERADDRESS",
        receiver="RECEIVERADDRESS",
        asset_id=12345,
        amount=100,
    )
)

# Asset opt-in
algorand.send.asset_opt_in(
    AssetOptInParams(
        sender="SENDERADDRESS",
        asset_id=12345,
    )
)

# Asset create
create_result = algorand.send.asset_create(
    AssetCreateParams(
        sender="SENDERADDRESS",
        total=1_000_000,
        decimals=6,
        asset_name="My Token",
        unit_name="MTK",
    )
)
asset_id = create_result.asset_id
```

### Transaction Groups

```python
result = (
    algorand
    .new_group()
    .add_payment(
        PaymentParams(
            sender="SENDERADDRESS",
            receiver="RECEIVERADDRESS",
            amount=AlgoAmount(algo=1),
        )
    )
    .add_asset_opt_in(
        AssetOptInParams(
            sender="SENDERADDRESS",
            asset_id=12345,
        )
    )
    .send()
)
```

### Creating Transactions (Without Sending)

```python
payment = algorand.create_transaction.payment(
    PaymentParams(
        sender="SENDERADDRESS",
        receiver="RECEIVERADDRESS",
        amount=AlgoAmount(algo=1),
    )
)
# payment is an unsigned algosdk.Transaction
```

## Common Transaction Parameters

All transactions support these common parameters:

```python
algorand.send.payment(
    PaymentParams(
        sender="SENDERADDRESS",
        receiver="RECEIVERADDRESS",
        amount=AlgoAmount(algo=1),

        # Optional parameters
        note=b"My note",
        lease="unique-lease-id",
        rekey_to="NEWADDRESS",

        # Fee management
        static_fee=AlgoAmount(micro_algo=1000),
        extra_fee=AlgoAmount(micro_algo=1000),  # For covering inner txn fees
        max_fee=AlgoAmount(micro_algo=10000),

        # Validity
        validity_window=1000,
        first_valid_round=12345,
    )
)
```

## App Calls

### Using Typed App Clients (Recommended)

```python
# Get typed factory from generated client
factory = algorand.client.get_typed_app_factory(MyContractFactory)

# Deploy
result = factory.deploy(sender=deployer.address)
app_client = result.app_client

# Call methods
response = app_client.send.my_method(
    sender=deployer.address,
    args={"param1": "value"},
)
```

### Generic App Calls

```python
from algokit_utils import AppCallMethodCallParams
from algosdk.abi import Method

algorand.send.app_call_method_call(
    AppCallMethodCallParams(
        sender="SENDERADDRESS",
        app_id=12345,
        method=Method.from_signature("hello(string)string"),
        args=["World"],
    )
)
```

## Send Parameters

Control execution behavior when sending:

```python
from algokit_utils import SendParams

algorand.send.payment(
    PaymentParams(
        sender="SENDERADDRESS",
        receiver="RECEIVERADDRESS",
        amount=AlgoAmount(algo=1),
    ),
    send_params=SendParams(
        # Wait for confirmation
        max_rounds_to_wait_for_confirmation=5,

        # Suppress logging
        suppress_log=True,

        # Auto-populate app call resources
        populate_app_call_resources=True,

        # Auto-calculate inner txn fees
        cover_app_call_inner_transaction_fees=True,
    )
)
```

## Amount Helpers

```python
from algokit_utils import AlgoAmount

AlgoAmount(algo=1)           # 1 Algo = 1,000,000 microAlgo
AlgoAmount(algo=0.5)         # 0.5 Algo = 500,000 microAlgo
AlgoAmount(micro_algo=1000)  # 1000 microAlgo

# Access values
amount = AlgoAmount(algo=1)
amount.algo        # 1.0
amount.micro_algo  # 1000000
```

## Common Patterns

### Fund an Account

```python
algorand.send.payment(
    PaymentParams(
        sender=funder_account.address,
        receiver=new_account.address,
        amount=AlgoAmount(algo=10),
    )
)
```

### Create and Fund in One Group

```python
new_account = algorand.account.random()

(
    algorand
    .new_group()
    .add_payment(
        PaymentParams(
            sender=funder.address,
            receiver=new_account.address,
            amount=AlgoAmount(algo=1),
        )
    )
    .add_asset_opt_in(
        AssetOptInParams(
            sender=new_account.address,
            asset_id=12345,
        )
    )
    .send()
)
```

### Deploy and Fund Contract

```python
factory = algorand.client.get_typed_app_factory(MyContractFactory)
result = factory.deploy(sender=deployer.address)
app_client = result.app_client

# Fund the app account for box storage
algorand.send.payment(
    PaymentParams(
        sender=deployer.address,
        receiver=app_client.app_address,
        amount=AlgoAmount(algo=1),
    )
)
```

### Using Environment-Based Accounts

```python
# Set environment variables:
# DEPLOYER_MNEMONIC="word1 word2 ... word25"

algorand = AlgorandClient.from_environment()
deployer = algorand.account.from_environment("DEPLOYER")

# Now use deployer for transactions
algorand.send.payment(
    PaymentParams(
        sender=deployer.address,
        receiver="RECEIVERADDRESS",
        amount=AlgoAmount(algo=1),
    )
)
```

## References

- [AlgoKit Utils Python Overview](https://dev.algorand.co/algokit/utils/python/overview/)
- [AlgorandClient API](https://dev.algorand.co/reference/algokit-utils-py/api/algorand/)
- [Transaction Composer](https://dev.algorand.co/algokit/utils/python/transaction-composer/)
- [Account Management](https://dev.algorand.co/algokit/utils/python/account/)
