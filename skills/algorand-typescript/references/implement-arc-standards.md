# Implement ARC Standards (TypeScript)

This reference covers implementing ARC standards in Algorand TypeScript smart contracts and clients. ARC-4 defines the ABI for method calls and type encoding, while ARC-56 provides the modern application specification format for typed client generation.

## ARC-4 Contract Method Example

```typescript
import { Contract } from '@algorandfoundation/algorand-typescript'
import { abimethod, UInt64, UInt128 } from '@algorandfoundation/algorand-typescript/arc4'

class Calculator extends Contract {
  @abimethod()
  add(a: UInt64, b: UInt64): UInt128 {
    return new UInt128(a.native + b.native)
  }
}
```

## Using Typed Clients with ARC-56

```typescript
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { CalculatorFactory } from './clients/Calculator'

const algorand = AlgorandClient.defaultLocalNet()

// Deploy new contract
const factory = algorand.client.getTypedAppFactory(CalculatorFactory)
const { appClient } = await factory.deploy({
  onSchemaBreak: 'replace',
  onUpdate: 'update',
})

// Call methods with full type safety
const result = await appClient.send.add({
  args: { a: 10n, b: 20n }
})
console.log(result.return) // BigInt: 30n
```

## References

- [TypeScript ARC-4 Implementation](./implement-arc-standards-arc4.md) - ARC-4 types, contracts, and client calls
- [TypeScript ARC-32/56 Client Usage](./implement-arc-standards-arc32-arc56.md) - App specs, typed clients, and state access
