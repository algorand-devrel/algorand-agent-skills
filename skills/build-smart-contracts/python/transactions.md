# Algorand Python Transactions

Create inner transactions and access group transactions in Algorand Python smart contracts.

## When to use this reference

Use this reference when:

- Creating inner transactions to send payments, transfer assets, or call other contracts
- Submitting multiple inner transactions atomically
- Accessing other transactions in an atomic group
- Requiring payment or asset transactions as method parameters

## Transaction Types Overview

| Group Transactions | Inner Transaction Params | Inner Transaction Result |
|-------------------|--------------------------|--------------------------|
| `gtxn.PaymentTransaction` | `itxn.Payment` | `PaymentInnerTransaction` |
| `gtxn.AssetTransferTransaction` | `itxn.AssetTransfer` | `AssetTransferInnerTransaction` |
| `gtxn.AssetConfigTransaction` | `itxn.AssetConfig` | `AssetConfigInnerTransaction` |
| `gtxn.AssetFreezeTransaction` | `itxn.AssetFreeze` | `AssetFreezeInnerTransaction` |
| `gtxn.ApplicationCallTransaction` | `itxn.ApplicationCall` | `ApplicationCallInnerTransaction` |
| `gtxn.KeyRegistrationTransaction` | `itxn.KeyRegistration` | `KeyRegistrationInnerTransaction` |
| `gtxn.Transaction` | `itxn.InnerTransaction` | `InnerTransactionResult` |

## Inner Transactions

Smart contracts can execute inner transactions to send payments, transfer assets, create assets, and call other applications.

### Basic Payment

```python
from algopy import ARC4Contract, UInt64, Txn, itxn, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def send_payment(self) -> UInt64:
        # Create and submit a payment inner transaction
        result = itxn.Payment(
            amount=5000,
            receiver=Txn.sender,
            fee=0  # Always use 0 - caller covers via fee pooling
        ).submit()

        return result.amount
```

### Asset Transfer

```python
from algopy import ARC4Contract, Asset, Account, UInt64, itxn, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def transfer_asset(self, asset: Asset, receiver: Account, amount: UInt64) -> None:
        itxn.AssetTransfer(
            xfer_asset=asset,
            asset_receiver=receiver,
            asset_amount=amount,
            fee=0
        ).submit()
```

### Asset Opt-In (Self Transfer)

```python
from algopy import ARC4Contract, Asset, Global, itxn, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def opt_in_to_asset(self, asset: Asset) -> None:
        # Opt the contract into an asset
        itxn.AssetTransfer(
            xfer_asset=asset,
            asset_receiver=Global.current_application_address,
            asset_amount=0,
            fee=0
        ).submit()
```

### Create Fungible Asset

```python
from algopy import ARC4Contract, UInt64, Global, itxn, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def create_token(self) -> UInt64:
        result = itxn.AssetConfig(
            total=100_000_000_000,
            decimals=2,
            unit_name=b"TKN",
            asset_name=b"My Token",
            manager=Global.current_application_address,
            reserve=Global.current_application_address,
            fee=0
        ).submit()

        return result.created_asset.id
```

### Create NFT

```python
from algopy import ARC4Contract, UInt64, Global, itxn, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def create_nft(self) -> UInt64:
        # ARC-3 NFT: total=1, decimals=0
        result = itxn.AssetConfig(
            total=1,
            decimals=0,
            unit_name=b"NFT",
            asset_name=b"My NFT",
            url=b"https://example.com/nft.json",
            manager=Global.current_application_address,
            reserve=Global.current_application_address,
            freeze=Global.current_application_address,
            clawback=Global.current_application_address,
            fee=0
        ).submit()

        return result.created_asset.id
```

### Call Another Application

```python
from algopy import ARC4Contract, Application, Bytes, arc4, itxn

class MyContract(ARC4Contract):
    @arc4.abimethod
    def call_other_app(self, app: Application) -> arc4.String:
        # Call an ARC-4 method on another app
        result = itxn.ApplicationCall(
            app_id=app,
            app_args=(
                arc4.arc4_signature("hello(string)string"),
                arc4.String("World")
            ),
            fee=0
        ).submit()

        # Extract return value from logs
        return arc4.String.from_log(result.last_log)
```

### Deploy Another Contract

```python
from algopy import ARC4Contract, UInt64, arc4, itxn, compile_contract
from .other_contract import OtherContract

class MyContract(ARC4Contract):
    @arc4.abimethod
    def deploy_contract(self) -> UInt64:
        # Compile and deploy another contract
        compiled = compile_contract(OtherContract)

        result = itxn.ApplicationCall(
            approval_program=compiled.approval_program,
            clear_state_program=compiled.clear_state_program,
            fee=0
        ).submit()

        return result.created_app.id

    @arc4.abimethod
    def deploy_with_arc4(self) -> UInt64:
        # Simpler: use arc4.arc4_create
        result = arc4.arc4_create(OtherContract)
        return result.created_app.id
```

## Grouped Inner Transactions

Submit multiple inner transactions atomically using `itxn.submit_txns()`.

```python
from algopy import ARC4Contract, Application, UInt64, Txn, arc4, itxn

class MyContract(ARC4Contract):
    @arc4.abimethod
    def multi_txn(self, app: Application) -> tuple[UInt64, arc4.String]:
        # Create transaction parameters (not submitted yet)
        payment_params = itxn.Payment(
            amount=5000,
            receiver=Txn.sender,
            fee=0
        )

        app_call_params = itxn.ApplicationCall(
            app_id=app,
            app_args=(
                arc4.arc4_signature("hello(string)string"),
                arc4.String("World")
            ),
            fee=0
        )

        # Submit both atomically
        pay_txn, app_txn = itxn.submit_txns(payment_params, app_call_params)

        # Access results
        hello_result = arc4.String.from_log(app_txn.last_log)
        return pay_txn.amount, hello_result
```

### Inner Transactions in Loops

```python
from algopy import ARC4Contract, Account, UInt64, itxn, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def distribute(self, receivers: tuple[Account, Account, Account]) -> None:
        for receiver in receivers:
            itxn.Payment(
                amount=UInt64(1_000_000),
                receiver=receiver,
                fee=0
            ).submit()
```

## Inner Transaction Result Properties

### Payment Result

| Property | Type | Description |
|----------|------|-------------|
| `amount` | `UInt64` | Payment amount in microAlgos |
| `receiver` | `Account` | Payment receiver |
| `close_remainder_to` | `Account` | Close remainder to address |
| `sender` | `Account` | Transaction sender |
| `txn_id` | `Bytes` | Transaction ID |

### Asset Config Result

| Property | Type | Description |
|----------|------|-------------|
| `created_asset` | `Asset` | Newly created asset |
| `config_asset` | `Asset` | Configured asset |
| `txn_id` | `Bytes` | Transaction ID |

### Application Call Result

| Property | Type | Description |
|----------|------|-------------|
| `created_app` | `Application` | Newly created application |
| `last_log` | `Bytes` | Last log entry |
| `logs(index)` | `Bytes` | Log entry at index |
| `txn_id` | `Bytes` | Transaction ID |

### Asset Transfer Result

| Property | Type | Description |
|----------|------|-------------|
| `asset_amount` | `UInt64` | Amount transferred |
| `asset_receiver` | `Account` | Asset receiver |
| `xfer_asset` | `Asset` | Transferred asset |
| `txn_id` | `Bytes` | Transaction ID |

## Group Transactions

Access other transactions in an atomic group.

### As ABI Method Parameters

```python
from algopy import ARC4Contract, arc4, gtxn, Txn, Global

class MyContract(ARC4Contract):
    @arc4.abimethod
    def process_payment(self, payment: gtxn.PaymentTransaction) -> None:
        # Verify payment is to this app
        assert payment.receiver == Global.current_application_address
        assert payment.amount >= 1_000_000

        # Process the payment...
```

### By Group Index

```python
from algopy import ARC4Contract, arc4, gtxn, UInt64, Global

class MyContract(ARC4Contract):
    @arc4.abimethod
    def verify_group(self) -> None:
        # Access transaction at specific index
        pay_txn = gtxn.PaymentTransaction(0)

        assert pay_txn.receiver == Global.current_application_address
        assert pay_txn.amount >= UInt64(1_000_000)
```

### Untyped Access

```python
from algopy import ARC4Contract, arc4, gtxn, UInt64

class MyContract(ARC4Contract):
    @arc4.abimethod
    def check_any_txn(self, index: UInt64) -> None:
        # Access any transaction type
        txn = gtxn.Transaction(index)

        # Access common properties
        sender = txn.sender
        fee = txn.fee
        txn_type = txn.type
```

## Group Transaction Types

| Type | Usage |
|------|-------|
| `gtxn.PaymentTransaction` | Payment transactions |
| `gtxn.AssetTransferTransaction` | Asset transfers |
| `gtxn.AssetConfigTransaction` | Asset configuration |
| `gtxn.AssetFreezeTransaction` | Asset freeze/unfreeze |
| `gtxn.ApplicationCallTransaction` | App calls |
| `gtxn.KeyRegistrationTransaction` | Key registration |
| `gtxn.Transaction` | Any transaction type |

## Fee Pooling (CRITICAL)

Always set `fee=0` for inner transactions. The caller covers all fees through fee pooling.

```python
# CORRECT - Caller covers fees
itxn.Payment(
    amount=1000,
    receiver=Txn.sender,
    fee=0  # Always 0
).submit()

# INCORRECT - App pays fees (security risk!)
itxn.Payment(
    amount=1000,
    receiver=Txn.sender,
    fee=1000  # Don't do this!
).submit()
```

**Why?** If inner transactions specify non-zero fees, malicious callers can drain the app account by repeatedly invoking methods that execute inner transactions.

## Common Mistakes

### Forgetting Fee Pooling

```python
# INCORRECT - App pays fee (vulnerability!)
@arc4.abimethod
def bad_payment(self) -> None:
    itxn.Payment(
        amount=1000,
        receiver=Txn.sender
        # fee defaults to minimum, draining app account
    ).submit()

# CORRECT - Caller pays via fee pooling
@arc4.abimethod
def good_payment(self) -> None:
    itxn.Payment(
        amount=1000,
        receiver=Txn.sender,
        fee=0  # Explicit: caller covers
    ).submit()
```

### Not Checking Group Transaction Properties

```python
# INCORRECT - Trusts payment without verification
@arc4.abimethod
def accept_payment(self, payment: gtxn.PaymentTransaction) -> None:
    self.balance += payment.amount  # Who received it?

# CORRECT - Verify payment destination
@arc4.abimethod
def accept_payment_safe(self, payment: gtxn.PaymentTransaction) -> None:
    assert payment.receiver == Global.current_application_address
    self.balance += payment.amount
```

### Wrong Sender for Inner Transactions

```python
# Inner transactions are always sent from the app address
# The sender is automatically Global.current_application_address
# You cannot send from arbitrary accounts (unless rekeyed to app)

# CORRECT - Default sender is app address
itxn.Payment(
    amount=1000,
    receiver=some_account,
    fee=0
).submit()

# To send from a different account, it must be rekeyed to app
itxn.Payment(
    sender=rekeyed_account,  # Must be rekeyed to app address
    amount=1000,
    receiver=some_account,
    fee=0
).submit()
```

### Not Funding App Before Inner Transactions

```python
# Inner transactions require the app account to have sufficient balance
# Fund the app account before executing inner transactions

# In deploy script:
algorand.send.payment(
    sender=deployer.address,
    receiver=app_client.app_address,
    amount=1_000_000  # Fund app with 1 Algo
)
```

### Using Wrong Index for Group Transactions

```python
# INCORRECT - Hardcoded index may be wrong
@arc4.abimethod
def process(self) -> None:
    payment = gtxn.PaymentTransaction(0)  # Assumes payment is first

# CORRECT - Use transaction parameter
@arc4.abimethod
def process_safe(self, payment: gtxn.PaymentTransaction) -> None:
    # ARC-4 router handles finding the correct transaction
    assert payment.receiver == Global.current_application_address
```

## References

- [Algorand Python Transactions](https://dev.algorand.co/algokit/languages/python/lg-transactions/)
- [Inner Transactions Concepts](https://dev.algorand.co/concepts/smart-contracts/inner-txn/)
- [algopy.itxn API](https://dev.algorand.co/reference/algorand-python/api/api-algopyitxn/)
- [algopy.gtxn API](https://dev.algorand.co/reference/algorand-python/api/api-algopygtxn/)
