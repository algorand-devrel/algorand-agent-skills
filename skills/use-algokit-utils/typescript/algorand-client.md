# AlgorandClient (TypeScript)

The main entry point for interacting with Algorand in TypeScript applications.

## Installation

```bash
npm install @algorandfoundation/algokit-utils
```

## Creating an AlgorandClient

```typescript
import { AlgorandClient } from '@algorandfoundation/algokit-utils'

// From environment variables (recommended for production)
const algorand = AlgorandClient.fromEnvironment()

// Default LocalNet configuration
const algorand = AlgorandClient.defaultLocalNet()

// TestNet using AlgoNode free tier
const algorand = AlgorandClient.testNet()

// MainNet using AlgoNode free tier
const algorand = AlgorandClient.mainNet()

// From existing clients
const algorand = AlgorandClient.fromClients({ algod, indexer, kmd })

// From custom configuration
const algorand = AlgorandClient.fromConfig({
  algodConfig: {
    server: 'http://localhost',
    port: '4001',
    token: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  },
})
```

## Accessing SDK Clients

```typescript
const algodClient = algorand.client.algod
const indexerClient = algorand.client.indexer
const kmdClient = algorand.client.kmd
```

## Account Management

### Getting Accounts

```typescript
// From environment variable (DEPLOYER_MNEMONIC)
const deployer = await algorand.account.fromEnvironment('DEPLOYER')

// Random account (for testing)
const random = algorand.account.random()

// From mnemonic
const account = algorand.account.fromMnemonic('abandon abandon...')

// From KMD (LocalNet)
const kmdAccount = await algorand.account.fromKmd('wallet-name', 'password')
```

### Registering Signers

```typescript
// Register a signer for automatic signing
algorand.setSignerFromAccount(account)

// Set default signer for all transactions
algorand.setDefaultSigner(account.signer)
```

## Sending Transactions

### Single Transactions

```typescript
import { algo } from '@algorandfoundation/algokit-utils'

// Payment
const result = await algorand.send.payment({
  sender: 'SENDERADDRESS',
  receiver: 'RECEIVERADDRESS',
  amount: algo(1),
})

// Asset transfer
await algorand.send.assetTransfer({
  sender: 'SENDERADDRESS',
  receiver: 'RECEIVERADDRESS',
  assetId: 12345n,
  amount: 100n,
})

// Asset opt-in
await algorand.send.assetOptIn({
  sender: 'SENDERADDRESS',
  assetId: 12345n,
})

// Asset create
const createResult = await algorand.send.assetCreate({
  sender: 'SENDERADDRESS',
  total: 1000000n,
  decimals: 6,
  assetName: 'My Token',
  unitName: 'MTK',
})
const assetId = createResult.assetId
```

### Transaction Groups

```typescript
const result = await algorand
  .newGroup()
  .addPayment({
    sender: 'SENDERADDRESS',
    receiver: 'RECEIVERADDRESS',
    amount: algo(1),
  })
  .addAssetOptIn({
    sender: 'SENDERADDRESS',
    assetId: 12345n,
  })
  .send()
```

### Creating Transactions (Without Sending)

```typescript
const payment = await algorand.createTransaction.payment({
  sender: 'SENDERADDRESS',
  receiver: 'RECEIVERADDRESS',
  amount: algo(1),
})
// payment is an unsigned algosdk.Transaction
```

## Common Transaction Parameters

All transactions support these common parameters:

```typescript
await algorand.send.payment({
  sender: 'SENDERADDRESS',
  receiver: 'RECEIVERADDRESS',
  amount: algo(1),

  // Optional parameters
  note: 'My note',
  lease: 'unique-lease-id',
  rekeyTo: 'NEWADDRESS',

  // Fee management
  staticFee: algo(0.001),
  extraFee: algo(0.001),  // For covering inner txn fees
  maxFee: algo(0.01),

  // Validity
  validityWindow: 1000,
  firstValidRound: 12345n,
  lastValidRound: 12445n,
})
```

## App Calls

### Using Typed App Clients (Recommended)

```typescript
// Get typed factory from generated client
const factory = algorand.client.getTypedAppFactory(MyContractFactory)

// Deploy
const { appClient, result } = await factory.deploy({
  sender: deployer.addr,
})

// Call methods
const response = await appClient.send.myMethod({
  sender: deployer.addr,
  args: { param1: 'value' },
})
```

### Generic App Calls

```typescript
await algorand.send.appCallMethodCall({
  sender: 'SENDERADDRESS',
  appId: 12345n,
  method: algosdk.ABIMethod.fromSignature('hello(string)string'),
  args: ['World'],
})
```

## Send Parameters

Control execution behavior when sending:

```typescript
await algorand.send.payment(
  {
    sender: 'SENDERADDRESS',
    receiver: 'RECEIVERADDRESS',
    amount: algo(1),
  },
  {
    // Wait for confirmation
    maxRoundsToWaitForConfirmation: 5,

    // Suppress logging
    suppressLog: true,

    // Auto-populate app call resources
    populateAppCallResources: true,

    // Auto-calculate inner txn fees
    coverAppCallInnerTransactionFees: true,
  }
)
```

## Amount Helpers

```typescript
import { algo, microAlgo } from '@algorandfoundation/algokit-utils'

algo(1)           // 1 Algo = 1,000,000 microAlgo
algo(0.5)         // 0.5 Algo = 500,000 microAlgo
microAlgo(1000)   // 1000 microAlgo
(100).microAlgo() // Extension method: 100 microAlgo
```

## Common Patterns

### Fund an Account

```typescript
await algorand.send.payment({
  sender: funderAccount.addr,
  receiver: newAccount.addr,
  amount: algo(10),
})
```

### Create and Fund in One Group

```typescript
const newAccount = algorand.account.random()

await algorand
  .newGroup()
  .addPayment({
    sender: funder.addr,
    receiver: newAccount.addr,
    amount: algo(1),
  })
  .addAssetOptIn({
    sender: newAccount.addr,
    assetId: 12345n,
  })
  .send()
```

### Deploy and Fund Contract

```typescript
const factory = algorand.client.getTypedAppFactory(MyContractFactory)
const { appClient } = await factory.deploy({ sender: deployer.addr })

// Fund the app account for box storage
await algorand.send.payment({
  sender: deployer.addr,
  receiver: appClient.appAddress,
  amount: algo(1),
})
```

## References

- [AlgoKit Utils TS Overview](https://dev.algorand.co/algokit/utils/typescript/overview/)
- [AlgorandClient API](https://dev.algorand.co/reference/algokit-utils-ts/api/classes/types_algorand_clientalgorandclient/)
- [Transaction Composer](https://dev.algorand.co/algokit/utils/typescript/transaction-composer/)
- [Account Management](https://dev.algorand.co/algokit/utils/typescript/account/)
