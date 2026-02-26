# Smart Contract Errors (TypeScript)

TypeScript-focused fixes for common Algorand smart contract errors.

## Table of Contents

- [Logic Eval Errors](#logic-eval-errors)
  - [Assert Failed](#assert-failed)
  - [Opcode Budget Exceeded](#opcode-budget-exceeded)
  - [Invalid Program](#invalid-program)
  - [Stack Underflow](#stack-underflow)
  - [Byte/Int Type Mismatch](#byteint-type-mismatch)
- [ABI Errors](#abi-errors)
  - [Method Not Found](#method-not-found)
  - [ABI Encoding Error](#abi-encoding-error)
  - [Return Value Decoding Error](#return-value-decoding-error)
- [State Errors](#state-errors)
  - [Global State Full](#global-state-full)
  - [Local State Not Opted In](#local-state-not-opted-in)
  - [Box Not Found](#box-not-found)
  - [Box MBR Not Met](#box-mbr-not-met)
- [Inner Transaction Errors](#inner-transaction-errors)
- [Debugging Tips](#debugging-tips)

## Logic Eval Errors

### Assert Failed

```
logic eval error: assert failed pc=123
```

**Cause:** An `assert` statement evaluated to false.

**Debug with source maps:**

```typescript
// Errors include source location automatically with AlgoKit Utils
try {
  await appClient.send.myMethod({ args: { value: 0 } })
} catch (e) {
  // Error includes: "assert failed at contracts/my_contract.py:45"
  console.error(e)
}
```

**Common causes:**
- Input validation failed (e.g., `assert amount > 0`)
- Authorization check failed (e.g., `assert Txn.sender == self.owner`)
- State precondition not met (e.g., `assert self.is_initialized`)

**Fix:** Check the assertion condition and ensure inputs satisfy it.

### Opcode Budget Exceeded

```
logic eval error: dynamic cost budget exceeded
```

**Cause:** Contract exceeded the 700 opcode budget per app call.

**Budget limits:**
| Context | Budget |
|---------|--------|
| Single app call | 700 opcodes |
| Max pooled (16 app calls) | 11,200 opcodes |
| Logic signature | 20,000 opcodes |

**Fix - Pool budget with extra app calls:**
```typescript
await algorand.newGroup()
  .addAppCallMethodCall(actualCallParams)
  .addAppCall({
    sender: sender,
    appId: appId,
    onComplete: OnComplete.NoOp,
    args: [new Uint8Array(Buffer.from('noop'))],  // Dummy call for budget
  })
  .send()
```

### Invalid Program

```
logic eval error: invalid program
```

**Cause:** The TEAL program is malformed or uses unsupported opcodes.

**Common causes:**
- Compiling for wrong AVM version
- Using opcodes not supported on target network
- Corrupted approval/clear program bytes

**Fix:** Ensure compilation targets the correct AVM version.

### Stack Underflow

```
logic eval error: stack underflow
```

**Cause:** Operation tried to pop from empty stack. Usually indicates a bug in low-level operations.

### Byte/Int Type Mismatch

```
logic eval error: assert failed: wanted type uint64 but got []byte
```

**Cause:** Wrong type passed to an operation. Ensure correct types in contract code.

## ABI Errors

### Method Not Found

```
error: method "foo(uint64)void" not found
```

**Cause:** Calling a method that doesn't exist in the contract ABI.

**Fix:**
```typescript
// 1. Regenerate typed client after contract changes
// 2. Check method signature matches exactly
// 3. Verify contract was deployed with latest code

// Regenerate typed client
// algokit generate client -a ./artifacts -o ./client.ts
```

### ABI Encoding Error

```
ABIEncodingError: value out of range for uint64
```

**Cause:** Value doesn't fit the ABI type. Check value ranges for the target type.

### Return Value Decoding Error

```
error: could not decode return value
```

**Cause:** Method returned unexpected data format.

**Common causes:**
- Contract didn't log the return value properly
- Wrong return type in client
- Transaction failed before return

**Fix:** Check contract method has correct return annotation.

## State Errors

### Global State Full

```
logic eval error: store global state: failed
```

**Cause:** Exceeded declared global state schema.

**Fix:** Increase schema in contract deployment configuration.

### Local State Not Opted In

```
logic eval error: application APPID not opted in
```

**Cause:** Account hasn't opted into the application.

**Fix:**
```typescript
await algorand.send.appCall({
  sender: userAddress,
  appId: appId,
  onComplete: OnComplete.OptIn,
})
```

### Box Not Found

```
logic eval error: box not found
```

**Cause:** Accessing a box that doesn't exist. Create box before access or check existence in contract code.

### Box MBR Not Met

```
logic eval error: box create with insufficient funds
```

**Cause:** App account lacks funds for box minimum balance requirement.

**MBR formula:** `2500 + (400 * (key_length + value_length))` microAlgos per box

**Fix:** Fund the app account:
```typescript
await algorand.send.payment({
  sender: funder.address,
  receiver: appClient.appAddress,
  amount: algo(1),  // Cover box MBR
})
```

## Inner Transaction Errors

### Insufficient Balance for Inner Txn

```
logic eval error: insufficient balance
```

**Cause:** App account lacks funds for inner transaction amount.

**Fix:** Fund the app account before calling methods with inner transactions:
```typescript
await algorand.send.payment({
  sender: deployer.address,
  receiver: appClient.appAddress,
  amount: algo(5),
})
```

### Inner Transaction Limit

```
logic eval error: too many inner transactions
```

**Cause:** Exceeded 256 inner transactions per group.

**Fix:** Split operations across multiple outer transactions.

### App Not Opted Into Asset

```
logic eval error: asset ASSET_ID not opted in
```

**Cause:** Contract account isn't opted into the asset. The contract must have an opt-in method that sends a 0-amount inner asset transfer.

## Debugging Tips

### Enable Debug Logging

```typescript
import { Config } from '@algorandfoundation/algokit-utils'
Config.configure({ debug: true })
```

### Get Transaction Trace

```typescript
// Simulate to get execution trace
const result = await algorand.newGroup()
  .addAppCallMethodCall(params)
  .simulate({ execTraceConfig: { enable: true } })

console.log(result.simulateResponse.txnGroups[0].txnResults[0].execTrace)
```

### Simulate Before Sending

```typescript
const result = await algorand
  .newGroup()
  .addPayment({ sender, receiver, amount: algo(1) })
  .simulate()

if (result.simulateResponse.txnGroups[0].failureMessage) {
  console.error('Would fail:', result.simulateResponse.txnGroups[0].failureMessage)
}
```

### Check Program Counter Location

When you see `pc=123`, use algokit to find the source:

```bash
algokit compile contracts/my_contract.py --output-sourcemap
```

Then map the PC to source using the generated `.map` file.

## References

- [Debugging Smart Contracts](https://dev.algorand.co/concepts/smart-contracts/debugging/)
- [AVM Opcodes Reference](https://dev.algorand.co/reference/teal/opcodes/)
- [Error Handling in AlgoKit Utils TS](https://dev.algorand.co/algokit/utils/typescript/debugging/)
