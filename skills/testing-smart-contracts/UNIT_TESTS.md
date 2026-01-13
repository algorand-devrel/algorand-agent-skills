# Unit Testing Guide

**Only use unit tests if the user explicitly requests them.** Integration tests (E2E) are the default and recommended approach.

## When to use unit tests

- User explicitly says "unit test" or "offline test"
- Testing pure contract logic without network interaction
- Fast iteration during contract development

## File naming

- Unit tests: `contract.algo.spec.ts` (no `.e2e.` in the name)

## Basic Setup

```typescript
import { TestExecutionContext } from '@algorandfoundation/algorand-typescript-testing'
import { describe, expect, it, afterEach } from 'vitest'
import MyContract from './contract.algo'

describe('MyContract unit tests', () => {
  const ctx = new TestExecutionContext()

  afterEach(() => {
    ctx.reset()
  })

  it('should call method directly', () => {
    const contract = ctx.contract.create(MyContract)

    // Call methods directly - no ABI encoding
    const result = contract.myMethod('arg1', 42n)

    expect(result).toBe('expected value')
  })
})
```

## Key Differences from E2E Tests

| Aspect | E2E Tests | Unit Tests |
|--------|-----------|------------|
| **Framework** | `algorandFixture` | `TestExecutionContext` |
| **Network** | LocalNet | Emulated AVM |
| **Contract access** | Via typed client | Direct instance |
| **Method calls** | `client.send.method({ args: {...} })` | `contract.method(arg1, arg2)` |
| **Struct returns** | Tuples `[field1, field2]` | Object properties `result.field1` |
| **File naming** | `*.e2e.spec.ts` | `*.spec.ts` |

## Canonical Example

**Source:** [HelloWorld/contract.algo.spec.ts](https://github.com/algorandfoundation/devportal-code-examples/blob/main/projects/typescript-examples/contracts/HelloWorld/contract.algo.spec.ts)

```typescript
import { TestExecutionContext } from '@algorandfoundation/algorand-typescript-testing'
import { describe, expect, it } from 'vitest'
import HelloWorld from './contract.algo'

describe('HelloWorld unit tests', () => {
  const ctx = new TestExecutionContext()

  it('returns greeting', () => {
    const contract = ctx.contract.create(HelloWorld)

    const result = contract.sayHello('Sally', 'Jones')

    expect(result).toBe('Hello Sally Jones')
  })

  it('returns bananas', () => {
    const contract = ctx.contract.create(HelloWorld)

    const result = contract.sayBananas()

    expect(result).toBe('Bananas')
  })
})
```

## Testing with State

```typescript
import { TestExecutionContext } from '@algorandfoundation/algorand-typescript-testing'
import { Uint64 } from '@algorandfoundation/algorand-typescript'
import { describe, expect, it, afterEach } from 'vitest'
import CounterContract from './contract.algo'

describe('Counter unit tests', () => {
  const ctx = new TestExecutionContext()

  afterEach(() => {
    ctx.reset()
  })

  it('increments counter', () => {
    const contract = ctx.contract.create(CounterContract)

    contract.increment()
    contract.increment()

    // Access state directly on contract instance
    expect(contract.counter.value).toBe(Uint64(2))
  })
})
```

## Testing with Multiple Accounts

```typescript
it('supports multiple accounts', () => {
  const contract = ctx.contract.create(MyContract)

  // Create test accounts
  const account1 = ctx.any.account()
  const account2 = ctx.any.account()

  // Change sender for subsequent calls
  ctx.txn.sender = account1
  contract.doSomething()

  ctx.txn.sender = account2
  contract.doSomethingElse()
})
```

## Testing Boxes

```typescript
it('sets box value', () => {
  const contract = ctx.contract.create(BoxContract)
  const key = Bytes('myKey')
  const value = Bytes('myValue')

  contract.setBox(key, value)

  // Access box via ledger context
  const storedValue = ctx.ledger.getBox(contract, key)
  expect(storedValue).toEqual(value)
})
```

## Documentation

- [TypeScript Unit Testing Guide](https://dev.algorand.co/algokit/unit-testing/typescript/overview)
- [TestExecutionContext API](https://dev.algorand.co/algokit/unit-testing/typescript/concepts)
- [State Management in Tests](https://dev.algorand.co/algokit/unit-testing/typescript/state-management)
