# React Frontend Reference

Detailed API reference for building Algorand React frontends.

## Dependencies

```json
{
  "dependencies": {
    "@algorandfoundation/algokit-utils": "^9.0.0",
    "@txnlab/use-wallet-react": "^4.0.0",
    "algosdk": "^3.0.0",
    "react": "^18.2.0"
  }
}
```

## WalletManager Configuration

Create a `WalletManager` instance to configure available wallets:

```tsx
import { NetworkId, WalletId, WalletManager } from '@txnlab/use-wallet-react'

const walletManager = new WalletManager({
  wallets: WalletId[] | WalletConfig[],
  defaultNetwork: NetworkId | string,
  networks?: NetworkConfig,
  options?: ManagerOptions,
})
```

### Wallet IDs

| Wallet ID | Type | Notes |
|-----------|------|-------|
| `WalletId.PERA` | Mobile/Browser | Most popular Algorand wallet |
| `WalletId.DEFLY` | Mobile/Browser | Feature-rich wallet |
| `WalletId.EXODUS` | Desktop/Mobile | Multi-chain wallet |
| `WalletId.KIBISIS` | Browser Extension | AVM standard |
| `WalletId.LUTE` | Browser | Community wallet |
| `WalletId.KMD` | LocalNet only | For local development |

### Network IDs

```tsx
import { NetworkId } from '@txnlab/use-wallet-react'

NetworkId.MAINNET   // 'mainnet'
NetworkId.TESTNET   // 'testnet'
NetworkId.BETANET   // 'betanet'
```

### Basic Configuration

```tsx
// TestNet/MainNet with popular wallets
const walletManager = new WalletManager({
  wallets: [WalletId.PERA, WalletId.DEFLY, WalletId.EXODUS],
  defaultNetwork: NetworkId.TESTNET,
})
```

### Custom Network Configuration

```tsx
const walletManager = new WalletManager({
  wallets: [WalletId.PERA, WalletId.DEFLY],
  defaultNetwork: NetworkId.TESTNET,
  networks: {
    [NetworkId.TESTNET]: {
      algod: {
        baseServer: 'https://testnet-api.algonode.cloud',
        port: '',
        token: '',
      },
    },
  },
})
```

### LocalNet Configuration (Development)

```tsx
const walletManager = new WalletManager({
  wallets: [
    {
      id: WalletId.KMD,
      options: {
        baseServer: 'http://localhost',
        port: '4002',
        token: 'a]'.repeat(64),
        wallet: 'unencrypted-default-wallet',
      },
    },
  ],
  defaultNetwork: 'localnet',
  networks: {
    localnet: {
      algod: {
        baseServer: 'http://localhost',
        port: '4001',
        token: 'a'.repeat(64),
      },
    },
  },
})
```

## useWallet() Hook

The primary hook for wallet interactions:

```tsx
import { useWallet } from '@txnlab/use-wallet-react'

const {
  // Wallet state
  wallets,              // Wallet[] - all available wallets
  isReady,              // boolean - manager initialized

  // Active wallet info
  activeWallet,         // Wallet | null - current wallet
  activeAddress,        // string | null - current address
  activeWalletAccounts, // WalletAccount[] - accounts in active wallet

  // Signing
  transactionSigner,    // TransactionSigner - for signing txns
  signTransactions,     // (txns, indexes?) => Promise<Uint8Array[]>

  // Clients
  algodClient,          // Algodv2 - algod client instance
} = useWallet()
```

### Wallet Object

Each wallet in the `wallets` array has:

```tsx
interface Wallet {
  id: WalletId
  metadata: { name: string; icon: string }
  accounts: WalletAccount[]
  activeAccount: WalletAccount | null
  isConnected: boolean
  isActive: boolean

  // Methods
  connect: () => Promise<WalletAccount[]>
  disconnect: () => Promise<void>
  setActive: () => void
  setActiveAccount: (address: string) => void
}
```

### WalletAccount Object

```tsx
interface WalletAccount {
  name: string
  address: string
}
```

## AlgorandClient Signer Methods

Register wallet signers with `AlgorandClient`:

```tsx
import { AlgorandClient } from '@algorandfoundation/algokit-utils'

const algorand = AlgorandClient.testNet()

// Register signer for specific address
algorand.setSigner(address: string, signer: TransactionSigner)

// Register signer from account object
algorand.setSignerFromAccount(account: { addr: string; signer: TransactionSigner })

// Set default signer for all transactions
algorand.setDefaultSigner(signer: TransactionSigner)
```

### Signer Resolution Order

When sending transactions, AlgorandClient resolves signers in this order:

1. Explicit `signer` parameter in the method call
2. Registered signer for the sender address (via `setSigner()`)
3. Default signer (via `setDefaultSigner()`)

## AlgorandClient Factory Methods

```tsx
// Network presets
AlgorandClient.mainNet()     // MainNet via AlgoNode
AlgorandClient.testNet()     // TestNet via AlgoNode
AlgorandClient.defaultLocalNet()  // LocalNet defaults

// From configuration
AlgorandClient.fromConfig({
  algodConfig: { server: '...', port: '...', token: '...' },
})

// From environment variables
AlgorandClient.fromEnvironment()
```

## Typed App Client Methods

### Get Client by App ID

```tsx
const appClient = algorand.client.getTypedAppClientById(
  MyContractClient,  // Generated client class
  {
    appId: 12345n,                    // Required: App ID
    defaultSender: activeAddress,     // Optional: default sender
    defaultSigner: transactionSigner, // Optional: explicit signer
  }
)
```

### Get Client by Creator and Name

```tsx
const appClient = await algorand.client.getTypedAppClientByCreatorAndName(
  MyContractClient,
  {
    creatorAddress: 'ABC123...',
    appName: 'MyContract',         // Optional: defaults to spec name
    defaultSender: activeAddress,
  }
)
```

### Get Client by Network (ARC-56)

For contracts with network-specific App IDs in their spec:

```tsx
const appClient = await algorand.client.getTypedAppClientByNetwork(
  MyContractClient,
  {
    defaultSender: activeAddress,
  }
)
```

## Typed App Factory

Use factories to deploy new contracts or manage multiple instances:

```tsx
import { MyContractFactory } from './contracts/MyContractClient'

// Create factory
const factory = new MyContractFactory({
  algorand,
  defaultSender: activeAddress,
})

// Deploy new instance
const { appClient, result } = await factory.deploy({
  onSchemaBreak: 'append',  // 'replace' | 'append' | 'fail'
  onUpdate: 'append',       // 'replace' | 'append' | 'fail'
})

// Get client for existing app by ID
const existingClient = factory.getAppClientById({ appId: 12345n })

// Get client by creator and name
const namedClient = await factory.getAppClientByCreatorAndName({
  creatorAddress: 'ABC123...',
  appName: 'MyContract',
})
```

## Calling Contract Methods

### Send (Execute Transaction)

```tsx
// Single method call
const result = await appClient.send.methodName({
  args: { param1: 'value', param2: 42n },
})

console.log(result.return)     // Return value
console.log(result.txIds)      // Transaction IDs
console.log(result.transaction) // Transaction object
```

### Simulate (Dry Run)

```tsx
// Test without submitting
const simResult = await appClient.newGroup()
  .methodName({ args: { param1: 'value' } })
  .simulate()

console.log(simResult.returns[0]) // Simulated return value
```

### Chained Calls (Atomic Group)

```tsx
const result = await appClient.newGroup()
  .method1({ args: { ... } })
  .method2({ args: { ... } })
  .send()
```

## App Client Properties

```tsx
appClient.appId        // bigint - Application ID
appClient.appAddress   // string - Application account address
appClient.appName      // string - Application name
appClient.appSpec      // Arc56Contract - ARC-56 spec
```

## Payment Transactions

Send ALGO payments using the wallet signer:

```tsx
import { algo } from '@algorandfoundation/algokit-utils'

const result = await algorand.send.payment({
  sender: activeAddress,
  receiver: 'RECIPIENTADDRESS...',
  amount: algo(1),  // 1 ALGO
  signer: transactionSigner,
})
```

## Error Handling Pattern

```tsx
const callContract = async () => {
  if (!activeAddress || !transactionSigner) {
    throw new Error('Wallet not connected')
  }

  try {
    const algorand = AlgorandClient.testNet()
    algorand.setSigner(activeAddress, transactionSigner)

    const appClient = algorand.client.getTypedAppClientById(MyContractClient, {
      appId: APP_ID,
      defaultSender: activeAddress,
    })

    const result = await appClient.send.myMethod({ args: { value: 42n } })
    return result.return
  } catch (error) {
    if (error.message.includes('rejected')) {
      // User cancelled in wallet
      console.log('Transaction cancelled by user')
    } else if (error.message.includes('below min')) {
      // Insufficient funds
      console.log('Insufficient balance')
    } else {
      // Other error
      console.error('Transaction failed:', error)
    }
    throw error
  }
}
```

## Type Imports

Common imports for TypeScript:

```tsx
// use-wallet
import {
  NetworkId,
  WalletId,
  WalletManager,
  WalletProvider,
  useWallet,
} from '@txnlab/use-wallet-react'

// AlgoKit Utils
import {
  AlgorandClient,
  algo,
  microAlgo,
} from '@algorandfoundation/algokit-utils'

// algosdk (rarely needed directly)
import algosdk from 'algosdk'
```
