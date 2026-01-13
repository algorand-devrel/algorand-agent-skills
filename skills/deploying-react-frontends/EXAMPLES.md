# React Frontend Examples

Complete, minimal examples for Algorand React frontends.

## Example 1: Minimal Wallet Connection

Basic wallet connection without contract interaction.

### App.tsx

```tsx
import { NetworkId, WalletId, WalletManager, WalletProvider } from '@txnlab/use-wallet-react'
import { WalletConnect } from './WalletConnect'

const walletManager = new WalletManager({
  wallets: [WalletId.PERA, WalletId.DEFLY],
  defaultNetwork: NetworkId.TESTNET,
})

export default function App() {
  return (
    <WalletProvider manager={walletManager}>
      <WalletConnect />
    </WalletProvider>
  )
}
```

### WalletConnect.tsx

```tsx
import { useWallet } from '@txnlab/use-wallet-react'

export function WalletConnect() {
  const { wallets, activeAddress, activeWallet } = useWallet()

  if (activeAddress) {
    return (
      <div>
        <p>Connected: {activeAddress.slice(0, 8)}...{activeAddress.slice(-4)}</p>
        <button onClick={() => activeWallet?.disconnect()}>Disconnect</button>
      </div>
    )
  }

  return (
    <div>
      <h2>Connect Wallet</h2>
      {wallets.map((wallet) => (
        <button key={wallet.id} onClick={() => wallet.connect()}>
          {wallet.metadata.name}
        </button>
      ))}
    </div>
  )
}
```

---

## Example 2: Contract Interaction (Existing App)

Connect to an already-deployed contract by App ID.

### App.tsx

```tsx
import { NetworkId, WalletId, WalletManager, WalletProvider } from '@txnlab/use-wallet-react'
import { ContractDemo } from './ContractDemo'

const walletManager = new WalletManager({
  wallets: [WalletId.PERA, WalletId.DEFLY],
  defaultNetwork: NetworkId.TESTNET,
})

export default function App() {
  return (
    <WalletProvider manager={walletManager}>
      <ContractDemo />
    </WalletProvider>
  )
}
```

### ContractDemo.tsx

```tsx
import { useState } from 'react'
import { useWallet } from '@txnlab/use-wallet-react'
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { HelloWorldClient } from './contracts/HelloWorldClient'

const APP_ID = 12345n // Replace with your App ID

export function ContractDemo() {
  const { transactionSigner, activeAddress, wallets } = useWallet()
  const [result, setResult] = useState<string>('')
  const [loading, setLoading] = useState(false)

  const callContract = async () => {
    if (!activeAddress || !transactionSigner) return

    setLoading(true)
    try {
      const algorand = AlgorandClient.testNet()
      algorand.setSigner(activeAddress, transactionSigner)

      const appClient = algorand.client.getTypedAppClientById(HelloWorldClient, {
        appId: APP_ID,
        defaultSender: activeAddress,
      })

      const response = await appClient.send.hello({ args: { name: 'World' } })
      setResult(response.return ?? 'No return value')
    } catch (error) {
      setResult(`Error: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setLoading(false)
    }
  }

  if (!activeAddress) {
    return (
      <div>
        <h2>Connect Wallet</h2>
        {wallets.map((wallet) => (
          <button key={wallet.id} onClick={() => wallet.connect()}>
            {wallet.metadata.name}
          </button>
        ))}
      </div>
    )
  }

  return (
    <div>
      <p>Connected: {activeAddress.slice(0, 8)}...</p>
      <button onClick={callContract} disabled={loading}>
        {loading ? 'Calling...' : 'Call hello()'}
      </button>
      {result && <p>Result: {result}</p>}
    </div>
  )
}
```

---

## Example 3: Deploy and Call Contract

Deploy a new contract instance from the frontend.

### DeployContract.tsx

```tsx
import { useState } from 'react'
import { useWallet } from '@txnlab/use-wallet-react'
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { HelloWorldFactory } from './contracts/HelloWorldClient'

export function DeployContract() {
  const { transactionSigner, activeAddress } = useWallet()
  const [appId, setAppId] = useState<bigint | null>(null)
  const [loading, setLoading] = useState(false)

  const deployContract = async () => {
    if (!activeAddress || !transactionSigner) return

    setLoading(true)
    try {
      const algorand = AlgorandClient.testNet()
      algorand.setSigner(activeAddress, transactionSigner)

      const factory = new HelloWorldFactory({
        algorand,
        defaultSender: activeAddress,
      })

      const { appClient } = await factory.deploy({
        onSchemaBreak: 'append',
        onUpdate: 'append',
      })

      setAppId(appClient.appId)
    } catch (error) {
      console.error('Deploy failed:', error)
    } finally {
      setLoading(false)
    }
  }

  if (!activeAddress) {
    return <p>Please connect your wallet first.</p>
  }

  return (
    <div>
      <button onClick={deployContract} disabled={loading}>
        {loading ? 'Deploying...' : 'Deploy Contract'}
      </button>
      {appId && <p>Deployed! App ID: {appId.toString()}</p>}
    </div>
  )
}
```

---

## Example 4: Send Payment

Send ALGO to another address.

### SendPayment.tsx

```tsx
import { useState } from 'react'
import { useWallet } from '@txnlab/use-wallet-react'
import { AlgorandClient, algo } from '@algorandfoundation/algokit-utils'

export function SendPayment() {
  const { transactionSigner, activeAddress } = useWallet()
  const [receiver, setReceiver] = useState('')
  const [loading, setLoading] = useState(false)
  const [txId, setTxId] = useState('')

  const sendPayment = async () => {
    if (!activeAddress || !transactionSigner || !receiver) return

    setLoading(true)
    try {
      const algorand = AlgorandClient.testNet()

      const result = await algorand.send.payment({
        sender: activeAddress,
        receiver: receiver,
        amount: algo(1),
        signer: transactionSigner,
      })

      setTxId(result.txIds[0])
    } catch (error) {
      console.error('Payment failed:', error)
    } finally {
      setLoading(false)
    }
  }

  if (!activeAddress) {
    return <p>Please connect your wallet first.</p>
  }

  return (
    <div>
      <input
        type="text"
        placeholder="Receiver address"
        value={receiver}
        onChange={(e) => setReceiver(e.target.value)}
      />
      <button onClick={sendPayment} disabled={loading || receiver.length !== 58}>
        {loading ? 'Sending...' : 'Send 1 ALGO'}
      </button>
      {txId && <p>Sent! TX: {txId}</p>}
    </div>
  )
}
```

---

## Example 5: Multiple Account Selection

Handle wallets with multiple accounts.

### AccountSelector.tsx

```tsx
import { useWallet } from '@txnlab/use-wallet-react'

export function AccountSelector() {
  const { activeWallet, activeWalletAccounts, activeAddress } = useWallet()

  if (!activeWallet || activeWalletAccounts.length <= 1) {
    return null
  }

  return (
    <div>
      <label>Select Account:</label>
      <select
        value={activeAddress ?? ''}
        onChange={(e) => activeWallet.setActiveAccount(e.target.value)}
      >
        {activeWalletAccounts.map((account) => (
          <option key={account.address} value={account.address}>
            {account.name || account.address.slice(0, 8) + '...'}
          </option>
        ))}
      </select>
    </div>
  )
}
```

---

## Example 6: Contract with Arguments

Call a contract method with typed arguments.

### CounterContract.tsx

```tsx
import { useState } from 'react'
import { useWallet } from '@txnlab/use-wallet-react'
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { CounterClient } from './contracts/CounterClient'

const APP_ID = 12345n

export function CounterContract() {
  const { transactionSigner, activeAddress } = useWallet()
  const [count, setCount] = useState<bigint | null>(null)

  const getClient = () => {
    if (!activeAddress || !transactionSigner) return null

    const algorand = AlgorandClient.testNet()
    algorand.setSigner(activeAddress, transactionSigner)

    return algorand.client.getTypedAppClientById(CounterClient, {
      appId: APP_ID,
      defaultSender: activeAddress,
    })
  }

  const increment = async () => {
    const client = getClient()
    if (!client) return

    const result = await client.send.increment()
    setCount(result.return ?? 0n)
  }

  const add = async (value: bigint) => {
    const client = getClient()
    if (!client) return

    const result = await client.send.add({ args: { value } })
    setCount(result.return ?? 0n)
  }

  const readCount = async () => {
    const client = getClient()
    if (!client) return

    const result = await client.send.getCount()
    setCount(result.return ?? 0n)
  }

  if (!activeAddress) {
    return <p>Connect wallet to interact with counter.</p>
  }

  return (
    <div>
      <p>Count: {count?.toString() ?? 'Unknown'}</p>
      <button onClick={readCount}>Read Count</button>
      <button onClick={increment}>Increment</button>
      <button onClick={() => add(5n)}>Add 5</button>
      <button onClick={() => add(10n)}>Add 10</button>
    </div>
  )
}
```

---

## Example 7: Read Global State

Read contract global state without sending a transaction.

### ReadState.tsx

```tsx
import { useState, useEffect } from 'react'
import { useWallet } from '@txnlab/use-wallet-react'
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { MyContractClient } from './contracts/MyContractClient'

const APP_ID = 12345n

export function ReadState() {
  const { activeAddress } = useWallet()
  const [globalState, setGlobalState] = useState<Record<string, unknown>>({})

  useEffect(() => {
    const fetchState = async () => {
      const algorand = AlgorandClient.testNet()

      // Reading state doesn't require a signer
      const appClient = algorand.client.getTypedAppClientById(MyContractClient, {
        appId: APP_ID,
      })

      // Access typed state if available
      const state = await appClient.state.global.getAll()
      setGlobalState(state as Record<string, unknown>)
    }

    fetchState()
  }, [])

  return (
    <div>
      <h3>Global State</h3>
      <pre>{JSON.stringify(globalState, null, 2)}</pre>
    </div>
  )
}
```

---

## Example 8: Custom Hook for Contract

Create a reusable hook for contract interactions.

### useContract.ts

```tsx
import { useMemo } from 'react'
import { useWallet } from '@txnlab/use-wallet-react'
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { MyContractClient } from './contracts/MyContractClient'

const APP_ID = 12345n

export function useContract() {
  const { transactionSigner, activeAddress, isReady } = useWallet()

  const client = useMemo(() => {
    if (!activeAddress || !transactionSigner || !isReady) return null

    const algorand = AlgorandClient.testNet()
    algorand.setSigner(activeAddress, transactionSigner)

    return algorand.client.getTypedAppClientById(MyContractClient, {
      appId: APP_ID,
      defaultSender: activeAddress,
    })
  }, [activeAddress, transactionSigner, isReady])

  return {
    client,
    isConnected: !!activeAddress,
    address: activeAddress,
  }
}
```

### Usage

```tsx
import { useContract } from './useContract'

function MyComponent() {
  const { client, isConnected } = useContract()

  const callMethod = async () => {
    if (!client) return
    const result = await client.send.myMethod({ args: { value: 42n } })
    console.log(result.return)
  }

  if (!isConnected) return <p>Connect wallet first</p>

  return <button onClick={callMethod}>Call Method</button>
}
```

---

## Project Structure

Recommended file organization:

```
src/
├── App.tsx                    # Root with WalletProvider
├── components/
│   ├── WalletConnect.tsx      # Wallet connection UI
│   ├── AccountSelector.tsx    # Multi-account selection
│   └── ContractInteraction.tsx
├── contracts/
│   └── MyContractClient.ts    # Generated typed client
├── hooks/
│   └── useContract.ts         # Custom contract hook
└── config/
    └── wallet.ts              # WalletManager configuration
```

### config/wallet.ts

```tsx
import { NetworkId, WalletId, WalletManager } from '@txnlab/use-wallet-react'

export const walletManager = new WalletManager({
  wallets: [WalletId.PERA, WalletId.DEFLY, WalletId.EXODUS],
  defaultNetwork: NetworkId.TESTNET,
})
```

Then in App.tsx:

```tsx
import { WalletProvider } from '@txnlab/use-wallet-react'
import { walletManager } from './config/wallet'

export default function App() {
  return (
    <WalletProvider manager={walletManager}>
      <YourApp />
    </WalletProvider>
  )
}
```
