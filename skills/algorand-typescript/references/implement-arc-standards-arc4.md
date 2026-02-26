# ARC-4 Implementation (TypeScript)

This reference covers implementing and calling ARC-4 methods in Algorand TypeScript.

## Table of Contents

- [Using ARC-4 Types in Contracts](#using-arc-4-types-in-contracts)
- [Calling ARC-4 Methods from Clients](#calling-arc-4-methods-from-clients)
- [Common ARC-4 Patterns](#common-arc-4-patterns)
  - [Structs](#structs)
  - [Arrays](#arrays)
  - [Bare Methods](#bare-methods)

## Using ARC-4 Types in Contracts

```typescript
import { Contract, Account, Asset, Application, Global } from '@algorandfoundation/algorand-typescript'
import { abimethod, UInt64, Bool, Str, DynamicBytes, Address } from '@algorandfoundation/algorand-typescript/arc4'
import { PaymentTxn } from '@algorandfoundation/algorand-typescript/gtxn'

class MyContract extends Contract {
  @abimethod()
  demoTypes(
    // Primitive types
    amount: UInt64,
    flag: Bool,
    name: Str,

    // Reference types
    user: Account,
    token: Asset,
    app: Application,

    // Complex types
    data: DynamicBytes,
    addr: Address,
  ): Str {
    return new Str('Success')
  }

  @abimethod()
  withTransaction(
    payment: PaymentTxn,  // Preceding payment in group
    amount: UInt64,
  ): void {
    assert(payment.receiver === Global.currentApplicationAddress)
  }
}
```

## Calling ARC-4 Methods from Clients

```typescript
// Using AlgoKit Utils typed client
const result = await client.send.add({
  args: { a: 10n, b: 20n }
})

// Access return value
const sum = result.return  // BigInt
```

## Common ARC-4 Patterns

### Structs

```typescript
import { Contract } from '@algorandfoundation/algorand-typescript'
import { abimethod, Struct, UInt64, Bool, Str, Address } from '@algorandfoundation/algorand-typescript/arc4'

class UserInfo extends Struct<{
  name: Str
  balance: UInt64
  active: Bool
}> {}

class MyContract extends Contract {
  @abimethod()
  getUser(addr: Address): UserInfo {
    return new UserInfo({
      name: new Str('Alice'),
      balance: new UInt64(1000),
      active: new Bool(true),
    })
  }
}
```

### Arrays

```typescript
import { Contract } from '@algorandfoundation/algorand-typescript'
import { abimethod, UInt64, DynamicArray, StaticArray } from '@algorandfoundation/algorand-typescript/arc4'

class MyContract extends Contract {
  @abimethod()
  processList(items: DynamicArray<UInt64>): UInt64 {
    let total = 0n
    for (const item of items) {
      total += item.native
    }
    return new UInt64(total)
  }
}
```

### Bare Methods

```typescript
import { Contract } from '@algorandfoundation/algorand-typescript'
import { baremethod } from '@algorandfoundation/algorand-typescript/arc4'

class MyContract extends Contract {
  @baremethod({ create: 'require' })
  create(): void {
    // Called on app creation with no args
  }

  @baremethod({ allowActions: ['OptIn'] })
  optIn(): void {
    // Called on OptIn with no args
  }
}
```

Bare calls are identified by `NumAppArgs == 0`.
