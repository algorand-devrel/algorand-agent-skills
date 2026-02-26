# Troubleshoot Errors

Diagnose and resolve common Algorand development errors.

## Error Categories

| Category | Common Causes | Reference |
|----------|---------------|-----------|
| Contract Errors | Assert failures, opcode budget, invalid operations, ABI issues, state errors | [troubleshoot-errors-contract.md](./troubleshoot-errors-contract.md) |
| Transaction Errors | Overspend, invalid params, group issues, asset errors, SDK errors | [troubleshoot-errors-transaction.md](./troubleshoot-errors-transaction.md) |

## Quick Diagnosis Flow

1. **Identify the error type** from the message
2. **Check the error code** if present (e.g., `pc=123`)
3. **Find the root cause** using the reference docs
4. **Apply the fix** from the common solutions

## Common Error Patterns

### Logic Eval Error (Contract Failure)

```
logic eval error: assert failed pc=123
```

**Cause:** An `assert` statement in the smart contract evaluated to false.

**Debug steps:**
1. The `pc=123` indicates the program counter where failure occurred
2. Use source maps to find the exact line in your code
3. Check the assertion condition and input values
4. Use AlgoKit Utils LogicError for automatic source mapping

### Transaction Rejected (Overspend)

```
TransactionPool.Remember: transaction TXID: overspend
```

**Cause:** Sender account has insufficient balance for amount + fee + minimum balance requirement.

**Debug steps:**
1. Check the sender's account balance
2. Calculate the minimum balance requirement (base 100,000 microAlgo + opted-in assets/apps)
3. Ensure `available balance = total balance - minimum balance` covers the transaction amount + fee

### Opcode Budget Exceeded

```
logic eval error: dynamic cost budget exceeded
```

**Cause:** Contract exceeded the 700 opcode budget per app call.

**Solutions:**
- Add more app calls to the group for additional budget (pooled up to 11,200 with 16 calls)
- Optimize contract logic to reduce operations
- Split complex operations across multiple calls

### Asset Not Opted In

```
asset ASSET_ID missing from ACCOUNT_ADDRESS
```

**Cause:** The receiving account has not opted into the asset.

**Solution:** Have the receiver send a 0-amount asset transfer to themselves before any transfers are attempted.

### Application Not Opted In

```
address ADDRESS has not opted in to application APPID
```

**Cause:** Account trying to access local state without opting in to the application.

**Solution:** The account must send an opt-in transaction (OnComplete.OptIn) before local state can be accessed.

### SDK Connection Errors

```
AlgodHTTPError: Network request error. Received status 401
```

**Cause:** Authentication or connectivity issue with the Algorand node.

**Debug steps:**
1. Check the API token configuration
2. Verify the server URL is correct
3. Ensure the node is running (for LocalNet: `algokit localnet start`)

## How to Proceed

1. **Find your error** in the category references above
2. **Understand the cause** from the explanation
3. **Apply the solution** from the code examples

## References

- [Contract Errors Reference](./troubleshoot-errors-contract.md) - Smart contract and logic errors
- [Transaction Errors Reference](./troubleshoot-errors-transaction.md) - Transaction and account errors
- [Debugging Guide](https://dev.algorand.co/concepts/smart-contracts/debugging/)
- [Error Handling in AlgoKit Utils](https://dev.algorand.co/algokit/utils/typescript/debugging/)
