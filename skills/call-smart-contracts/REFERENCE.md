# Calling Smart Contracts Reference

CLI commands and TypeScript client patterns for contract interaction.

## CLI Commands

### Build Contract

```bash
algokit project run build
```

Compiles contracts and generates:
- ARC-56 app spec (`*.arc56.json`)
- TypeScript client (`client.ts`)

### Deploy Contract

```bash
# To localnet
algokit project deploy localnet

# To testnet (requires funded account)
algokit project deploy testnet

# To mainnet
algokit project deploy mainnet
```

### Localnet Management

```bash
# Start localnet
algokit localnet start

# Check status
algokit localnet status

# Reset (clears all data)
algokit localnet reset

# Stop
algokit localnet stop
```

### Run Custom Scripts

```bash
# Run a TypeScript script
npx tsx scripts/my-script.ts
```

---

## TypeScript Client Patterns

### Initialize AlgorandClient

```typescript
import { AlgorandClient } from '@algorandfoundation/algokit-utils'

// From environment (reads ALGORAND_* env vars)
const algorand = AlgorandClient.fromEnvironment()

// Explicit localnet
const algorand = AlgorandClient.defaultLocalNet()

// Explicit testnet
const algorand = AlgorandClient.testNet()

// Explicit mainnet
const algorand = AlgorandClient.mainNet()
```

### Get Account

```typescript
// From environment variable (e.g., DEPLOYER_MNEMONIC)
const account = await algorand.account.fromEnvironment('DEPLOYER')

// From mnemonic directly
const account = await algorand.account.fromMnemonic('word1 word2 ...')

// Localnet dispenser (auto-funded)
const dispenser = await algorand.account.localNetDispenser()
```

### Create Typed Client

```typescript
import { MyContractClient } from './artifacts/MyContract/client'

// By App ID (for existing deployment)
const client = algorand.client.getTypedAppClientById(MyContractClient, {
  appId: BigInt(1234),
  sender: account,
})

// By creator (finds latest deployment by creator address)
const client = await algorand.client.getTypedAppClientByCreatorAndName(MyContractClient, {
  creatorAddress: account.addr,
  sender: account,
})
```

### Call Methods

```typescript
// No arguments, no return
await client.send.myMethod({})

// With arguments
await client.send.setValue({ args: { value: 42n } })

// With payment
await client.send.deposit({
  args: { amount: 1_000_000n },
  extraFee: AlgoAmount.MicroAlgos(1000),
})

// Get return value
const result = await client.send.getValue({})
console.log(result.return) // typed return value
```

### Read State

```typescript
// Global state - all keys
const globalState = await client.state.global.getAll()

// Global state - specific typed key
const count = await client.state.global.count()

// Local state for an address
const localState = await client.state.local(address).getAll()

// Box storage
const boxValue = await client.state.box.myBox()
```

### Opt-In / Close-Out

```typescript
// Opt-in with ABI method
await client.send.optIn.optIn({})

// Bare opt-in (no method call)
await client.send.optIn.bare({})

// Close-out with ABI method
await client.send.closeOut.closeOut({})

// Bare close-out
await client.send.closeOut.bare({})
```

### Delete Application

```typescript
// With ABI method
await client.send.delete.deleteApplication({})

// Bare delete
await client.send.delete.bare({})
```

---

## deploy-config.ts Pattern

The standard deployment configuration file:

```typescript
// smart_contracts/deploy-config.ts
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { MyContractClient } from './artifacts/MyContract/client'

export async function deploy() {
  const algorand = AlgorandClient.fromEnvironment()
  const deployer = await algorand.account.fromEnvironment('DEPLOYER')

  const client = await algorand.client.getTypedAppClientByCreatorAndName(
    MyContractClient,
    {
      creatorAddress: deployer.addr,
      sender: deployer,
    }
  )

  // Deploy or get existing
  const app = await client.deploy({
    onUpdate: 'update',
    onSchemaBreak: 'replace',
  })

  console.log(`App ID: ${app.appId}`)
  return app
}
```

---

## Error Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| "logic eval error" | Contract rejected call | Check method args, contract logic |
| "below min" | Insufficient funds | Fund the sender account |
| "not opted in" | Account hasn't opted in | Call opt-in first |
| "app does not exist" | Wrong App ID | Verify App ID from deployment |
| "network unreachable" | Localnet not running | `algokit localnet start` |
| "Cannot find module" | Client not generated | `algokit project run build` |

---

## Environment Variables

```bash
# Network selection
ALGORAND_NETWORK=localnet  # or testnet, mainnet

# Account mnemonic (for testnet/mainnet)
DEPLOYER_MNEMONIC="word1 word2 word3 ..."

# Algod connection (usually auto-configured)
ALGOD_SERVER=http://localhost
ALGOD_PORT=4001
ALGOD_TOKEN=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```
