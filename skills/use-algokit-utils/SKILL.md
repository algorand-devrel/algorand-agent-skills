---
name: use-algokit-utils
description: AlgoKit Utils library for interacting with the Algorand blockchain. Use when sending transactions, managing accounts, working with assets, or deploying smart contracts from application code (not from within smart contracts).
---

# AlgoKit Utils

Use AlgoKit Utils to interact with the Algorand blockchain from TypeScript or Python applications.

## When to use this skill

Use this skill when the user wants to:

- Connect to Algorand networks (LocalNet, TestNet, MainNet)
- Send payments or transfer assets
- Create and manage Algorand accounts
- Deploy or interact with smart contracts from client code
- Compose transaction groups

**Strong triggers:**

- "How do I connect to Algorand?"
- "Send a payment transaction"
- "Create an account"
- "Deploy my contract"
- "Get an AlgorandClient"

**NOT for:**

- Writing smart contract code (use `build-smart-contracts` skill)
- Inner transactions from within contracts (use `build-smart-contracts/python/transactions.md`)

## Overview / Core Workflow

1. Create an `AlgorandClient` instance
2. Get or create accounts for signing
3. Send transactions using `algorand.send.*` methods
4. Or compose groups using `algorand.newGroup()`

## How to proceed

1. **Initialize AlgorandClient:**

   TypeScript:
   ```typescript
   import { AlgorandClient } from '@algorandfoundation/algokit-utils'

   const algorand = AlgorandClient.fromEnvironment()
   // Or: AlgorandClient.defaultLocalNet()
   // Or: AlgorandClient.testNet()
   // Or: AlgorandClient.mainNet()
   ```

   Python:
   ```python
   from algokit_utils import AlgorandClient

   algorand = AlgorandClient.from_environment()
   # Or: AlgorandClient.default_localnet()
   # Or: AlgorandClient.testnet()
   # Or: AlgorandClient.mainnet()
   ```

2. **Get accounts:**

   TypeScript:
   ```typescript
   const account = await algorand.account.fromEnvironment('DEPLOYER')
   ```

   Python:
   ```python
   account = algorand.account.from_environment("DEPLOYER")
   ```

3. **Send transactions:**

   TypeScript:
   ```typescript
   await algorand.send.payment({
     sender: account.addr,
     receiver: 'RECEIVERADDRESS',
     amount: algo(1),
   })
   ```

   Python:
   ```python
   algorand.send.payment(PaymentParams(
     sender=account.address,
     receiver="RECEIVERADDRESS",
     amount=AlgoAmount(algo=1),
   ))
   ```

## Important Rules / Guidelines

- **Use AlgorandClient** — It's the main entry point; avoid deprecated function-based APIs
- **Default to fromEnvironment()** — Works locally and in production via env vars
- **Register signers** — Use `algorand.account` to get accounts; signers are auto-registered
- **Use algo() helper** — For TypeScript, use `algo(1)` instead of raw microAlgos

## Common Variations / Edge Cases

| Scenario | Approach |
|----------|----------|
| LocalNet development | `AlgorandClient.defaultLocalNet()` |
| TestNet/MainNet | `AlgorandClient.testNet()` or `.mainNet()` |
| Custom node | `AlgorandClient.fromConfig({ algodConfig: {...} })` |
| Deploy contract | Use typed app client factory (see app-client docs) |
| Transaction groups | `algorand.newGroup().addPayment(...).addAssetOptIn(...).send()` |

## References / Further Reading

- [TypeScript AlgorandClient](./typescript/algorand-client.md)
- [Python AlgorandClient](./python/algorand-client.md)
- [AlgoKit Utils TS Docs](https://dev.algorand.co/algokit/utils/typescript/overview/)
- [AlgoKit Utils Python Docs](https://dev.algorand.co/algokit/utils/python/overview/)
