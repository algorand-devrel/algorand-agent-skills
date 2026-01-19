# Group and Inner Transactions

## Group Transactions (gtxn)

Access group transactions using typed `gtxn` functions with `uint64` indices:

```typescript
import { gtxn, Global, Uint64 } from '@algorandfoundation/algorand-typescript'

// Verify group size
assert(Global.groupSize === Uint64(3), 'Must be group of 3 transactions')

// Access group transactions using typed functions
const assetTransfer = gtxn.AssetTransferTxn(Uint64(0))  // First transaction
const payment = gtxn.PaymentTxn(Uint64(1))              // Second transaction

// Verify transaction properties
assert(assetTransfer.sender.bytes === sellerBytes, 'Asset must come from seller')
assert(assetTransfer.assetReceiver.bytes === buyer.bytes, 'Asset must go to buyer')
assert(assetTransfer.xferAsset === asset, 'Asset ID mismatch')
assert(payment.amount === listing.price, 'Payment amount mismatch')
```

**INCORRECT**: `const txn = gtxn[0]` — array indexing doesn't work.

### Available Typed Functions

| Function | Transaction Type |
|----------|------------------|
| `gtxn.PaymentTxn(n)` | Payment |
| `gtxn.AssetTransferTxn(n)` | Asset transfer |
| `gtxn.AssetConfigTxn(n)` | Asset configuration |
| `gtxn.ApplicationCallTxn(n)` | Application call |
| `gtxn.AssetFreezeTxn(n)` | Asset freeze |
| `gtxn.KeyRegistrationTxn(n)` | Key registration |
| `gtxn.Transaction(n)` | Untyped access |

## Inner Transactions (itxn)

### Method Selector Helper

Use `methodSelector` to get the 4-byte ARC-4 method selector for inner app calls:

```typescript
import { methodSelector } from '@algorandfoundation/algorand-typescript/arc4'

// Get selector from method signature
const selector = methodSelector('transfer(address,uint64)void')

// Use in inner app call
itxn.applicationCall({
  appId: targetApp,
  appArgs: [selector, encodedArg1, encodedArg2],
  fee: Uint64(0),
}).submit()
```

### Method Names

Inner transaction methods use **lowercase**:

```typescript
import { itxn, Global, Uint64 } from '@algorandfoundation/algorand-typescript'

// CORRECT - lowercase
itxn.payment({ ... }).submit()
itxn.assetTransfer({ ... }).submit()

// INCORRECT
itxn.Payment({ ... })  // Wrong case
```

### Application Address

Use `Global.currentApplicationAddress`, not `this.appAddress()`:

```typescript
// CORRECT
assert(payment.receiver.bytes === Global.currentApplicationAddress.bytes)

// INCORRECT
assert(payment.receiver.bytes === this.appAddress().bytes)
```

### Account from Bytes

When storing Account as bytes and converting back for inner transactions:

```typescript
// Store Account as bytes (required for GlobalState/BoxMap)
const escrow = clone(this.escrow.value)
const sellerBytes = escrow.seller  // bytes stored in state

// Convert bytes to Account for inner transaction
itxn.payment({
  receiver: Account(sellerBytes),  // Convert bytes to Account
  amount: escrow.amount,
  fee: Uint64(0),
}).submit()
```

### Fee Pooling (CRITICAL)

Always set `fee: Uint64(0)` for inner transactions. The app call sender covers fees through fee pooling:

```typescript
itxn.payment({
  receiver: Account(sellerBytes),
  amount: escrow.amount,
  fee: Uint64(0),  // Caller covers fees
}).submit()
```

This prevents app account drain attacks where malicious callers force the app to pay fees.

### Composing Multiple Inner Transactions

Use `itxnCompose` for submitting multiple inner transactions atomically:

```typescript
import { itxn, itxnCompose, Global, Account, Uint64 } from '@algorandfoundation/algorand-typescript'

// Submit multiple inner transactions as a group
itxnCompose.begin()

itxnCompose.next(
  itxn.payment({
    receiver: Account(recipientBytes),
    amount: Uint64(100_000),
    fee: Uint64(0),
  })
)

itxnCompose.next(
  itxn.assetTransfer({
    xferAsset: assetId,
    assetReceiver: Account(recipientBytes),
    assetAmount: Uint64(50),
    fee: Uint64(0),
  })
)

itxnCompose.submit()
```

**Note**: `itxnCompose.begin()` starts a new group, `itxnCompose.next()` adds transactions, and `itxnCompose.submit()` sends them all atomically.

## Asset Type

`Asset` constructor takes `uint64` directly:

```typescript
// CORRECT
const asset = Asset(assetId)  // if assetId is already uint64
const asset = Asset(Uint64(123))

// INCORRECT
const asset = Asset(123)  // number literal
const asset = Asset({ id: 123 })  // object
```

## Complete Example: Escrow Release

```typescript
import { 
  itxn, gtxn, Global, Account, Uint64, assert, clone 
} from '@algorandfoundation/algorand-typescript'

public releaseEscrow(): void {
  const escrow = clone(this.escrowData.value)
  
  // Verify the payment came to app
  assert(Global.groupSize === Uint64(2), 'Expected 2 txns')
  const payment = gtxn.PaymentTxn(Uint64(0))
  assert(
    payment.receiver.bytes === Global.currentApplicationAddress.bytes,
    'Payment must go to app'
  )
  
  // Send funds to seller via inner transaction
  itxn.payment({
    receiver: Account(escrow.seller),
    amount: escrow.amount,
    fee: Uint64(0),  // Fee pooling
  }).submit()
}
```
