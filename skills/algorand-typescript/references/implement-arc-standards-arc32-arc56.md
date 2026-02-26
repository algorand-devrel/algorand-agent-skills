# ARC-32/56 Client Usage (TypeScript)

This reference covers generating and using ARC-32/ARC-56 application specifications in TypeScript.

## Table of Contents

- [Generating App Specs](#generating-app-specs)
- [TypeScript Client Usage](#typescript-client-usage)
  - [Factory and Deployment](#factory-and-deployment)
  - [Calling Methods](#calling-methods)
  - [State Access](#state-access)
- [Converting ARC-32 to ARC-56](#converting-arc-32-to-arc-56)

## Generating App Specs

```bash
# Compile TypeScript contract - generates both .arc32.json and .arc56.json
npx puya-ts contracts/my_contract.ts

# Or via AlgoKit
algokit project run build
```

Output files:
- `MyContract.arc32.json` - Legacy app spec
- `MyContract.arc56.json` - Modern app spec

## TypeScript Client Usage

### Factory and Deployment

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
```

### Calling Methods

```typescript
// Call methods with full type safety
const result = await appClient.send.add({
  args: { a: 10n, b: 20n }
})
console.log(result.return) // BigInt: 30n
```

### State Access

```typescript
// Read state with typed access
const state = await appClient.state.global.getAll()
console.log(state.counter) // Typed as bigint
```

## Converting ARC-32 to ARC-56

AlgoKit Utils provides a conversion utility for migrating legacy ARC-32 specs:

```typescript
import { arc32ToArc56 } from '@algorandfoundation/algokit-utils'
import arc32Spec from './MyContract.arc32.json'

const arc56Spec = arc32ToArc56(arc32Spec)
```
