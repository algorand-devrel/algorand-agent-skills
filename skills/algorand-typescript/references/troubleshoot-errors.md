# Troubleshoot Errors (TypeScript)

Diagnose and resolve common Algorand development errors when working with TypeScript and AlgoKit Utils TypeScript.

## Error References

| Category | Description | Reference |
|----------|-------------|-----------|
| Contract Errors | Assert failures, opcode budget, ABI issues, state errors | [troubleshoot-errors-contract.md](./troubleshoot-errors-contract.md) |
| Transaction Errors | Overspend, invalid params, group issues, asset/account errors | [troubleshoot-errors-transaction.md](./troubleshoot-errors-transaction.md) |

## TypeScript Debugging Quick Start

### Enable Debug Logging

```typescript
import { Config } from '@algorandfoundation/algokit-utils'
Config.configure({ debug: true })
```

### Simulate with Execution Trace

```typescript
// Simulate to get execution trace before sending
const result = await algorand.newGroup()
  .addAppCallMethodCall(params)
  .simulate({ execTraceConfig: { enable: true } })

console.log(result.simulateResponse.txnGroups[0].txnResults[0].execTrace)
```

### Catch and Inspect Errors

```typescript
try {
  await appClient.send.myMethod({ args: { value: 0 } })
} catch (e) {
  // AlgoKit Utils automatically includes source-mapped error info
  // Error includes: "assert failed at contracts/my_contract.py:45"
  console.error(e)
}
```

### Check Transaction Status

```typescript
// Check pending transaction
const pending = await algorand.client.algod.pendingTransactionInformation(txId).do()
console.log('Pool error:', pending.poolError)
```

## How to Proceed

1. **Find your error** in the contract or transaction error references
2. **Understand the cause** from the explanation
3. **Apply the TypeScript fix** from the code examples
