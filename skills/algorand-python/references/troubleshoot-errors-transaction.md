# Transaction & Account Errors (Python)

Python-focused fixes for common Algorand transaction and account errors.

## Table of Contents

- [Transaction Errors](#transaction-errors)
  - [Overspend](#overspend)
  - [Transaction Already in Ledger](#transaction-already-in-ledger)
  - [Transaction Pool Full](#transaction-pool-full)
  - [Fee Too Low](#fee-too-low)
  - [Round Out of Range](#round-out-of-range)
  - [Invalid Group](#invalid-group)
  - [Group Size Limit](#group-size-limit)
- [Asset Errors](#asset-errors)
  - [Asset Not Found](#asset-not-found)
  - [Asset Not Opted In](#asset-not-opted-in)
  - [Asset Frozen](#asset-frozen)
  - [Clawback Not Authorized](#clawback-not-authorized)
  - [Cannot Close Asset](#cannot-close-asset)
- [Account Errors](#account-errors)
  - [Account Not Found](#account-not-found)
  - [Invalid Address](#invalid-address)
  - [Wrong Network](#wrong-network)
- [SDK Errors](#sdk-errors)
- [Application Errors](#application-errors)
- [Debugging Tips](#debugging-tips)

## Transaction Errors

### Overspend

```
TransactionPool.Remember: transaction TXID: overspend (account ADDRESS, data {_struct:{} Status:Offline MicroAlgos:{Raw:1000} ...})
```

**Cause:** Sender account has insufficient balance for amount + fee + minimum balance.

**Minimum balance requirements:**
| Item | MBR |
|------|-----|
| Base account | 100,000 microAlgo |
| Each opted-in asset | +100,000 microAlgo |
| Each created asset | +100,000 microAlgo |
| Each opted-in app | +100,000 microAlgo |
| Each created app | +100,000 microAlgo |
| App local state per schema | Varies |
| Box storage | 2,500 + 400 * size |

**Fix:**
```python
# Calculate available balance
account_info = algorand.account.get_information(address)
available = account_info.amount - account_info.min_balance
```

### Transaction Already in Ledger

```
TransactionPool.Remember: transaction already in ledger: TXID
```

**Cause:** Duplicate transaction submitted (same txn ID).

**Common causes:**
- Retrying a transaction that already succeeded
- Using same lease within validity window
- Network latency causing duplicate submission

**Fix:** Check if transaction exists before retrying:
```python
try:
    result = algorand.client.algod.pending_transaction_info(tx_id)
    # Transaction exists
except Exception:
    # Safe to retry
    pass
```

### Transaction Pool Full

```
TransactionPool.Remember: transaction pool is full
```

**Cause:** Node's transaction pool at capacity.

**Fix:**
1. Wait and retry with exponential backoff
2. Increase fee to prioritize transaction
3. Try a different node

### Fee Too Low

```
TransactionPool.Remember: transaction TXID: fee X below threshold Y
```

**Cause:** Transaction fee below minimum (usually 1000 microAlgo).

**Fix:**
```python
algorand.send.payment(PaymentParams(
    sender=sender,
    receiver=receiver,
    amount=AlgoAmount(algo=1),
    static_fee=AlgoAmount(micro_algo=1000),  # Minimum fee
))
```

### Round Out of Range

```
TransactionPool.Remember: transaction TXID: round X outside of Y-Z range
```

**Cause:** Transaction's validity window expired or is in the future.

**Fix:**
```python
algorand.send.payment(PaymentParams(
    sender=sender,
    receiver=receiver,
    amount=AlgoAmount(algo=1),
    validity_window=1000,  # Valid for 1000 rounds (~1 hour)
))
```

### Invalid Group

```
TransactionPool.Remember: transaction TXID: bad group assignment
```

**Cause:** Transaction claims to be part of a group but has wrong group ID.

**Fix:** Use AlgoKit Utils for proper grouping:
```python
algorand.new_group()
    .add_payment(PaymentParams(sender=sender, receiver=receiver, amount=AlgoAmount(algo=1)))
    .add_asset_opt_in(AssetOptInParams(sender=sender, asset_id=12345))
    .send()
```

### Group Size Limit

```
cannot send transaction group with more than 16 transactions
```

**Cause:** Transaction group exceeds 16 transaction limit.

**Fix:** Split into multiple groups or optimize to fewer transactions.

## Asset Errors

### Asset Not Found

```
asset ASSET_ID does not exist
```

**Cause:** Asset ID doesn't exist on the network.

**Common causes:**
- Wrong network (TestNet vs MainNet)
- Asset was deleted
- Typo in asset ID

**Fix:** Verify asset exists:
```python
asset_info = algorand.client.algod.asset_info(asset_id)
```

### Asset Not Opted In

```
asset ASSET_ID missing from ACCOUNT_ADDRESS
```

**Cause:** Receiving account hasn't opted into the asset.

**Fix:**
```python
algorand.send.asset_opt_in(AssetOptInParams(
    sender=receiver_address,
    asset_id=asset_id,
))
```

### Asset Frozen

```
asset ASSET_ID frozen in ACCOUNT_ADDRESS
```

**Cause:** Account's holding of this asset is frozen.

**Fix:** Asset freeze manager must unfreeze the account.

### Clawback Not Authorized

```
only clawback address can clawback
```

**Cause:** Attempting clawback without being the clawback address.

**Fix:** Only the designated clawback address can perform clawbacks.

### Cannot Close Asset

```
cannot close asset: ACCOUNT_ADDRESS still has X units
```

**Cause:** Trying to opt out while still holding units.

**Fix:** Transfer all units before opting out:
```python
# First transfer all units
algorand.send.asset_transfer(AssetTransferParams(
    sender=account,
    receiver=creator_or_other,
    asset_id=asset_id,
    amount=balance,  # All remaining
))

# Then opt out
algorand.send.asset_opt_out(AssetOptOutParams(
    sender=account,
    asset_id=asset_id,
    creator=creator_address,
))
```

## Account Errors

### Account Not Found

```
account ADDRESS not found
```

**Cause:** Account doesn't exist (never funded).

**Note:** Algorand accounts must receive at least minimum balance to exist.

**Fix:**
```python
algorand.send.payment(PaymentParams(
    sender=funder.address,
    receiver=new_account.address,
    amount=AlgoAmount(micro_algo=100_000),  # Minimum
))
```

### Invalid Address

```
invalid address: ADDRESS
```

**Cause:** Malformed Algorand address.

**Valid address format:**
- 58 characters
- Base32 encoded
- Includes checksum

**Verify address:**
```python
from algosdk import encoding
if not encoding.is_valid_address(address):
    raise ValueError("Invalid address")
```

### Wrong Network

```
genesis hash mismatch
```

**Cause:** Transaction built for different network than target.

**Fix:**
```python
# For TestNet
algorand = AlgorandClient.test_net()

# For MainNet
algorand = AlgorandClient.main_net()
```

## SDK Errors

### AlgodHTTPError

```
AlgodHTTPError: Network request error. Received status 401
```

**Common status codes:**
| Status | Meaning | Fix |
|--------|---------|-----|
| 401 | Unauthorized | Check API token |
| 404 | Not found | Check server URL |
| 500 | Server error | Node issue, retry |
| 503 | Unavailable | Node overloaded, retry |

**Fix for 401:**
```python
algorand = AlgorandClient.from_config(
    algod_config=AlgoClientNetworkConfig(
        server="https://testnet-api.algonode.cloud",
        port="443",
        token="",  # AlgoNode doesn't require token
    )
)
```

### Timeout Waiting for Confirmation

```
Timeout waiting for transaction TXID to be confirmed
```

**Cause:** Transaction not confirmed within wait rounds.

**Fix:**
```python
result = algorand.send.payment(PaymentParams(
    sender=sender,
    receiver=receiver,
    amount=AlgoAmount(algo=1),
    max_rounds_to_wait_for_confirmation=10,  # Wait longer
))
```

### Connection Refused

```
fetch failed: ECONNREFUSED
```

**Cause:** Cannot connect to Algorand node.

**Fix:**
1. For LocalNet: Ensure AlgoKit LocalNet is running (`algokit localnet start`)
2. For public networks: Check internet connection
3. Verify server URL is correct

## Application Errors

### Application Not Found

```
application APPID does not exist
```

**Cause:** App ID doesn't exist on the network.

**Fix:**
```python
app_info = algorand.client.algod.application_info(app_id)
```

### Not Opted Into Application

```
address ADDRESS has not opted in to application APPID
```

**Cause:** Account trying to access local state without opt-in.

**Fix:**
```python
algorand.send.app_call(AppCallParams(
    sender=user_address,
    app_id=app_id,
    on_complete=OnComplete.OptIn,
))
```

### Application Creator Only

```
cannot update or delete application: only creator can modify
```

**Cause:** Attempting to modify app without being creator.

**Fix:**
```python
app_info = algorand.app.get_by_id(app_id)
if sender != app_info.creator:
    raise Error("Only creator can modify")
```

## Debugging Tips

### Enable Verbose Logging

```python
import logging
logging.getLogger("algokit").setLevel(logging.DEBUG)
```

### Check Transaction Status

```python
# Check pending transaction
pending = algorand.client.algod.pending_transaction_info(tx_id)
print("Pool error:", pending.get("pool-error", ""))
```

### Simulate Before Sending

```python
result = algorand.new_group() \
    .add_payment(PaymentParams(sender=sender, receiver=receiver, amount=AlgoAmount(algo=1))) \
    .simulate()
```

## References

- [Transaction Structure](https://dev.algorand.co/concepts/transactions/structure/)
- [Account Management](https://dev.algorand.co/concepts/accounts/)
- [Asset Overview](https://dev.algorand.co/concepts/assets/)
- [AlgoKit Utils Debugging](https://dev.algorand.co/algokit/utils/typescript/debugging/)
