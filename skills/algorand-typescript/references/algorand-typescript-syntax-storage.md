# Storage Patterns

## Storage Types Overview

| Storage | Scope | Who Pays MBR | Use Case |
|---------|-------|--------------|----------|
| `GlobalState` | App-wide | App account | Shared app data |
| `LocalState` | Per-user | User (on opt-in) | Per-user data with opt-in |
| `Box` | App-wide | App account | Large data, single key |
| `BoxMap` | Per-key | App account | Per-user data without opt-in |

## Storage Access Patterns

### GlobalState

```typescript
import { GlobalState, clone } from '@algorandfoundation/algorand-typescript'

export class MyContract extends Contract {
  appState = GlobalState<MyData>({ key: 'state' })

  public updateState(amount: uint64): void {
    const state = clone(this.appState.value)
    const updated = clone(state)
    updated.counter = updated.counter + amount
    this.appState.value = clone(updated)
  }
}
```

### LocalState (Requires Opt-in)

```typescript
import { LocalState, Txn, clone } from '@algorandfoundation/algorand-typescript'

export class MyContract extends Contract {
  userData = LocalState<UserData>({ key: 'user' })

  public optInToApplication(): void {
    const initial: UserData = { balance: Uint64(0) }
    this.userData(Txn.sender).value = clone(initial)
  }

  public getBalance(): uint64 {
    return clone(this.userData(Txn.sender).value).balance
  }
}
```

### BoxMap (No Opt-in Required)

```typescript
import { BoxMap, Account, clone } from '@algorandfoundation/algorand-typescript'

export class MyContract extends Contract {
  userBoxes = BoxMap<Account, UserData>({ keyPrefix: 'u' })

  public createUser(user: Account): void {
    const initial: UserData = { balance: Uint64(0) }
    this.userBoxes(user).value = clone(initial)
  }
}
```

## Box Storage MBR (CRITICAL)

Box storage increases the app account's Minimum Balance Requirement (MBR). The app account must be funded BEFORE boxes can be created.

### MBR Formula

```
(2500 per box) + (400 * (box size + key size)) microAlgos per box
```

### Funding Pattern in deploy-config.ts

```typescript
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { MyAppFactory } from '../artifacts/my_app/MyAppClient'

export async function deploy() {
  const algorand = AlgorandClient.fromEnvironment()
  const deployer = await algorand.account.fromEnvironment('DEPLOYER')

  const factory = algorand.client.getTypedAppFactory(MyAppFactory, {
    defaultSender: deployer.addr,
  })

  const { appClient, result } = await factory.deploy({
    onUpdate: 'append',
    onSchemaBreak: 'append'
  })

  // MANDATORY: Fund app account if BoxMap is used
  if (['create', 'replace'].includes(result.operationPerformed)) {
    await algorand.send.payment({
      amount: (1).algo(),  // Fund app account for box MBR
      sender: deployer.addr,
      receiver: appClient.appAddress,
    })
  }
}
```

**Note**: `operationPerformed` values are `'create'`, `'replace'`, `'update'`, or `'append'`. Only fund on `'create'` or `'replace'` to avoid redundant funding.

### Testing with BoxMap

E2E tests using BoxMap require app account funding before first box operation:

```typescript
// Fund immediately after deployment in test setup
const { client } = await deploy(testAccount)

await localnet.algorand.send.payment({
  amount: (1).algo(),
  sender: testAccount,
  receiver: client.appAddress,
})

// Now box operations will work
await client.send.createUser({ args: [userAccount] })
```

## Choosing Storage Type

| Scenario | Recommended | Reason |
|----------|-------------|--------|
| Per-user data, user pays | `LocalState` | User covers MBR on opt-in |
| Per-user data, app pays | `BoxMap` | No opt-in needed, app funds MBR |
| Shared app config | `GlobalState` | Simple, always available |
| Large data (>128 bytes) | `Box` or `BoxMap` | No size limits like GlobalState |

## Class Properties

Cannot define class properties or constants. Only storage proxies allowed on contract classes:

```typescript
// CORRECT: Module-level constants
const MAX_ITEMS: uint64 = Uint64(100)

class MyContract extends Contract {
  items = GlobalState<ItemList>({ key: 'items' })  // OK: storage proxy

  public addItem(): void {
    // Use MAX_ITEMS here
  }
}

// INCORRECT: Class properties
class MyContract extends Contract {
  private readonly MAX_ITEMS: uint64 = Uint64(100)  // Compiler error
}
```
