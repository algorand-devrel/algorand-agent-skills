# AlgoKit Utils (TypeScript)

AlgoKit Utils for TypeScript is the primary library for building Algorand applications in TypeScript/JavaScript. It provides a high-level, ergonomic interface via the `AlgorandClient` class, which is the single entry point for interacting with the Algorand network -- sending transactions, managing accounts, deploying smart contracts, and more.

## Installation

```bash
npm install @algorandfoundation/algokit-utils
```

## Quick Start

### 1. Create an AlgorandClient

```typescript
import { AlgorandClient } from '@algorandfoundation/algokit-utils'

// Connect to LocalNet (development)
const algorand = AlgorandClient.defaultLocalNet()

// Connect to TestNet
const algorand = AlgorandClient.testNet()

// Connect to MainNet
const algorand = AlgorandClient.mainNet()

// From environment variables (recommended for production)
const algorand = AlgorandClient.fromEnvironment()
```

### 2. Get and Register an Account

```typescript
// Get a random account (testing)
const account = algorand.account.random()

// From environment variable (e.g. DEPLOYER_MNEMONIC)
const deployer = await algorand.account.fromEnvironment('DEPLOYER')

// Register the signer so transactions are automatically signed
algorand.setSignerFromAccount(account)
```

### 3. Send a Transaction

```typescript
import { algo } from '@algorandfoundation/algokit-utils'

const result = await algorand.send.payment({
  sender: account.addr,
  receiver: 'RECEIVERADDRESS',
  amount: algo(1),
})
```

## Key Rules

1. **Always use `AlgorandClient`** as the single entry point. Do not instantiate lower-level SDK clients directly.
2. **Use `AlgorandClient.fromEnvironment()`** for production deployments and CI/CD pipelines.
3. **Register signers** with `algorand.setSignerFromAccount(account)` before sending transactions so signing is handled automatically.
4. **Use the `algo()` and `microAlgo()` helpers** for amounts instead of raw numbers to avoid unit conversion errors.

## Reference

For the full AlgorandClient API covering client creation, account management, transaction sending, app calls, transaction groups, amount helpers, testing fixtures, and common patterns:

[AlgorandClient Reference](./use-algokit-utils-reference.md)

## External Links

- [AlgoKit Utils TS Overview](https://dev.algorand.co/algokit/utils/typescript/overview/)
- [AlgorandClient API Reference](https://dev.algorand.co/reference/algokit-utils-ts/api/classes/types_algorand_clientalgorandclient/)
- [Transaction Composer](https://dev.algorand.co/algokit/utils/typescript/transaction-composer/)
- [Account Management](https://dev.algorand.co/algokit/utils/typescript/account/)
