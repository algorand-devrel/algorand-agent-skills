# Migrating TEALScript to Algorand TypeScript 1.0

## Table of Contents

- [Migration Checklist](#migration-checklist)
- [Type Migration Table](#type-migration-table)
- [Migrations](#migrations)
  - [Add explicit imports](#add-explicit-imports)
  - [EventLogger → emit](#replace-eventlogger-with-emit)
  - [Box creation syntax](#update-box-creation-syntax)
  - [Inner transactions](#refactor-inner-transactions)
  - [sendMethodCall → arc4.abiCall](#replace-sendmethodcall-with-arc4abicall)
  - [App creation with compileArc4](#use-arc4compilearc4-for-app-creation)
  - [Static methods → compileArc4](#replace-static-methods-with-compilearc4)
  - [Logic sigs](#update-logic-sigs)
  - [Template variables](#move-template-variables)
  - [Numeric type annotations](#add-explicit-type-annotations)
  - [Typed literals → arc4.Uint](#replace-typed-literals-with-arc4uint)
  - [Type casting](#replace-as-type-casts)
  - [Array/object references](#use-clone-for-copies)

## Migration Checklist

Work through these changes when migrating from TEALScript to Algorand TypeScript 1.0:

- [ ] **Explicit imports**: Replace global namespace with imports from `@algorandfoundation/algorand-typescript`
- [ ] **Event logging**: Replace `EventLogger` with `emit()`
- [ ] **Box creation**: Change `box.create(size)` to `box.create({ size })`
- [ ] **Inner transactions**: Update to use `itxn` namespace methods
- [ ] **Typed method calls**: Replace `sendMethodCall` with `arc4.abiCall`
- [ ] **App creation**: Use `arc4.compileArc4()` before creating apps
- [ ] **Compiled contract access**: Replace static methods with `arc4.compileArc4()` result
- [ ] **Logic sigs**: Rename `logic()` to `program()`, add return statement
- [ ] **Template variables**: Move outside class properties, use `TemplateVar<uint64>('NAME')`
- [ ] **Type annotations**: Add `:uint64` to all arithmetic operations
- [ ] **Numeric types**: Replace `uint256` literals with `arc4.Uint<256>` constructors
- [ ] **Type casting**: Replace `as type` with constructor calls
- [ ] **Array/object copies**: Use `clone()` function

## Type Migration Table

| TEALScript | Algorand TypeScript 1.0 |
|------------|------------------------|
| `EventLogger` | `emit` function |
| `BoxKey` | `Box` |
| `Txn` | `Transaction` |
| `PayTxn` | `PaymentTxn` |
| `AppCallTxn` | `ApplicationCallTxn` |
| `KeyRegTxn` | `KeyRegistrationTxn` |
| `OnCompletion` | `OnCompleteAction` |
| `ecAdd`, `ecMultiply`, etc. | `ElipticCurve.add`, `ElipticCurve.multiply` |
| `GlobalStateKey` | `GlobalState` |
| `LocalStateKey` | `LocalState` |
| `GlobalStateMap` | Not yet supported |
| `LocalStateMap` | Not yet supported |
| `isOptedInToApp`, `isOptedInToAsset` | `isOptedIn` |
| `this.txn` | `Txn` |
| `this.app` | `Global.currentApplicationAddress` |
| `verify...Txn` | `assertMatch` |
| `globals` | `Global` |
| `StaticArray` | `FixedArray` |
| `AppID` | `Application` |
| `AssetID` | `Asset` |
| `Address` | `Account` |
| `throw Error('msg')` | `err('msg')` |

## Migrations

### Add explicit imports

TEALScript injects types into global namespace. Algorand TypeScript requires explicit imports.

**BEFORE - TEALScript**

```ts
import { LogicSig } from '@algorandfoundation/tealscript';

class AppCaller extends LogicSig {
  logic(): void {
    assert(this.txn.applicationID === 1234); // No import needed
  }
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import {
  LogicSig,
  Txn,
  assert,
  uint64,
  TemplateVar,
} from '@algorandfoundation/algorand-typescript';

class AppCaller extends LogicSig {
  program(): boolean {
    assert(Txn.applicationId.id === 1234);
    return true;
  }
}
```

### Replace `EventLogger` with `emit()`

**BEFORE - TEALScript**

```ts
class Swapper {
  swap = new EventLogger<{
    assetA: AssetID;
    assetB: AssetID;
  }>();

  doSwap(a: AssetID, b: AssetID) {
    this.swap.log({ assetA: a, assetB: b });
  }
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { uint64, emit, Contract } from '@algorandfoundation/algorand-typescript';

type Swap = { assetA: uint64; assetB: uint64 };

class Swapper extends Contract {
  doSwap(a: uint64, b: uint64): void {
    emit('swap', { assetA: a, assetB: b } as Swap);
  }
}

// Alternative: infer event name from type
type swap = { assetA: uint64; assetB: uint64 };

class Swapper2 extends Contract {
  doSwap(a: uint64, b: uint64) {
    emit<swap>({ assetA: a, assetB: b });
  }
}
```

### Update box creation syntax

**TEALScript**: `box.create(size)` or `box.create(size?)`

**Algorand TypeScript**: `box.create({ size })` or `box.create(options?: { size?: uint64 })`

Size is auto-determined for fixed-length types in both.

### Refactor inner transactions

#### Sending a single transaction

**BEFORE - TEALScript**

```ts
sendAssetConfig({
  total: 1000,
  assetName: 'AST1',
  unitName: 'unit',
  decimals: 3,
  manager: this.app.address,
  reserve: this.app.address,
});
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { itxn, Global, log } from '@algorandfoundation/algorand-typescript';

const assetParams = itxn.assetConfig({
  total: 1000,
  assetName: 'AST1',
  unitName: 'unit',
  decimals: 3,
  manager: Global.currentApplicationAddress,
  reserve: Global.currentApplicationAddress,
});

const asset_txn = assetParams.submit();
log(asset_txn.createdAsset.id);
```

#### Sending a transaction group

**BEFORE - TEALScript**

```ts
this.pendingGroup.addAssetCreation({
  configAssetTotal: 1000,
  configAssetName: 'AST3',
  configAssetUnitName: 'unit',
  configAssetDecimals: 3,
  configAssetManager: this.app.address,
  configAssetReserve: this.app.address,
});

this.pendingGroup.addAppCall({
  approvalProgram: APPROVE,
  clearStateProgram: APPROVE,
  fee: 0,
});

const appCreateTxn = this.lastInnerGroup[0];
const asset3_txn = this.lastInnerGroup[1];
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { itxn, Global, assert, Bytes } from '@algorandfoundation/algorand-typescript';

const assetParams = itxn.assetConfig({
  total: 1000,
  assetName: 'AST3',
  unitName: 'unit',
  decimals: 3,
  manager: Global.currentApplicationAddress,
  reserve: Global.currentApplicationAddress,
});

const appCreateParams = itxn.applicationCall({
  approvalProgram: APPROVAL_PROGRAM,
  clearStateProgram: CLEAR_STATE_PROGRAM,
  fee: 0,
});

const [appCreateTxn, asset3_txn] = itxn.submitGroup(appCreateParams, assetParams);

assert(appCreateTxn.createdApp, 'app is created');
assert(asset3_txn.assetName === Bytes('AST3'));
```

### Replace `sendMethodCall` with `arc4.abiCall`

**BEFORE - TEALScript**

```ts
const result = sendMethodCall<typeof Hello.prototype.greet>({
  applicationID: app,
  methodArgs: ['algo dev'],
});

assert(result === 'hello algo dev');
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { arc4, assert } from '@algorandfoundation/algorand-typescript';
import type { HelloStubbed } from './HelloWorld.algo';

// Option 1: type argument (supports type-only imports)
const result = arc4.abiCall<typeof HelloStubbed.prototype.greet>({
  appId: 1234,
  args: ['algo dev'],
}).returnValue;

assert(result === 'hello algo dev');

// Option 2: method property
const result2 = arc4.abiCall({
  method: Hello.prototype.greet,
  appId: 1234,
  args: ['algo dev'],
}).returnValue;
```

### Use `arc4.compileArc4()` for app creation

**BEFORE - TEALScript**

```ts
sendMethodCall<typeof Greeter.prototype.createApplication>({
  clearStateProgram: Greeter.clearProgram(),
  approvalProgram: Greeter.approvalProgram(),
  globalNumUint: Greeter.schema.global.numUint,
  methodArgs: ['hello'],
});

const app = this.itxn.createdApplicationId;

const result = sendMethodCall<typeof Greeter.prototype.greet>({
  applicationID: app,
  methodArgs: ['world'],
});
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { Contract, arc4, assert } from '@algorandfoundation/algorand-typescript';
import Greeter from './Greeter.algo';

// First compile the contract
const compiled = arc4.compileArc4(Greeter);

const app = arc4.abiCall({
  method: compiled.call.createApplication,
  args: ['hello'],
  globalNumUint: compiled.globalUints,
}).itxn.createdApp;

const result = arc4.abiCall({
  method: compiled.call.greet,
  args: ['world'],
  appId: app,
}).returnValue;

assert(result === 'hello world');
```

### Replace static methods with `compileArc4()`

**BEFORE - TEALScript**

```ts
// Direct static method access
Greeter.clearProgram();
Greeter.approvalProgram();
Greeter.schema.global.numUint;
```

**AFTER - Algorand TypeScript 1.0**

```ts
// Use compiled object
const compiled = arc4.compileArc4(Greeter);
compiled.clearStateProgram;
compiled.approvalProgram;
compiled.globalUints;
```

### Update logic sigs

**BEFORE - TEALScript**

```ts
class DangerousPaymentLsig extends LogicSig {
  logic(amt: uint64) {
    assert(this.txn.amount === amt);
  }
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { op, LogicSig, Txn } from '@algorandfoundation/algorand-typescript';

class DangerousPaymentLsig extends LogicSig {
  program() {
    const amt = op.btoi(op.arg(0)); // Use op.arg() for arguments
    return Txn.amount === amt; // Must return boolean or uint64
  }
}
```

### Move template variables

**BEFORE - TEALScript**

```ts
class AppCaller extends LogicSig {
  APP_ID = TemplateVar<AppID>();

  logic(): void {
    assert(this.txn.applicationID === this.APP_ID);
  }
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { LogicSig, Txn, TemplateVar, assert, uint64 } from '@algorandfoundation/algorand-typescript';

// Template vars can be outside class
const APP_ID = TemplateVar<uint64>('APP_ID');

class AppCaller extends LogicSig {
  program(): boolean {
    assert(Txn.applicationId.id === APP_ID);
    return true;
  }
}
```

### Add explicit type annotations

TEALScript allows implicit `number` types. Algorand TypeScript requires explicit `uint64`.

**BEFORE - TEALScript**

```ts
add(a: uint64, b: uint64): uint64 {
  const sum = a + b; // Type inferred
  return sum;
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { uint64 } from '@algorandfoundation/algorand-typescript';

add(a: uint64, b: uint64): uint64 {
  const sum: uint64 = a + b; // Type required
  return sum;
}
```

### Replace typed literals with `arc4.Uint` constructors

**BEFORE - TEALScript**

```ts
addOne(n: uint256): uint256 {
  const one: uint256 = 1;
  const sum = n + one;
  return sum;
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { arc4, biguint } from '@algorandfoundation/algorand-typescript';

addOne(n: arc4.Uint<256>): arc4.Uint<256> {
  // Use biguint for intermediate arithmetic to avoid overflow checks
  const one = 1n;
  const sum: biguint = n.asBigUint() + one;
  return new arc4.Uint<256>(sum);
}
```

**Best practice**: Use `biguint` for intermediate values, convert to `arc4.Uint` only when encoding.

### Replace `as` type casts

**BEFORE - TEALScript**

```ts
convertNumber(n: uint64): uint8 {
  return n as uint8;
}
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { uint64, arc4 } from '@algorandfoundation/algorand-typescript';

convertNumber(n: uint64): arc4.Uint<8> {
  return new arc4.Uint<8>(n); // Use constructor
}
```

### Use `clone()` for array and object copies

TEALScript allows mutable references. Algorand TypeScript requires explicit copies.

**BEFORE - TEALScript**

```ts
const a: uint64[] = [1, 2, 3];
const b = a;
b.push(4);
assert(a === b); // Same reference
```

**AFTER - Algorand TypeScript 1.0**

```ts
import { uint64, clone, assertMatch } from '@algorandfoundation/algorand-typescript';

const a: uint64[] = [1, 2, 3];
const b = clone(a); // Explicit copy
b.push(4);

assertMatch(a, [1, 2, 3]);
assertMatch(b, [1, 2, 3, 4]); // Different arrays
```
