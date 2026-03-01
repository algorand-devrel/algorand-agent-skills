# Migrating Algorand TypeScript Beta to 1.0

## Table of Contents

- [Migration Checklist](#migration-checklist)
- [Breaking Changes](#breaking-changes)
  - [Object literals - mutability](#object-literals---add-readonly-or-as-const-if-immutability-needed)
  - [Native arrays - mutability](#native-arrays---add-readonly-or-as-const-if-immutability-needed)
  - [MutableArray → ReferenceArray](#rename-mutablearray-to-referencearray)
  - [copy() → clone()](#replace-xxxcopy-calls-with-clonexxx)
  - [ARC4 numeric types](#remove-n-and-nxm-suffixes-from-arc4-numeric-types)
  - [gtxn/itxn imports](#update-gtxn-and-itxn-imports)
  - [Resource encoding](#update-resource-encoding)
  - [Test file naming](#rename-test-files)
  - [arc4EncodedLength → sizeOf](#rename-arc4encodedlength-to-sizeof)
  - [abiCall signature](#update-abicall-syntax)
  - [interpretAsArc4 → convertBytes](#rename-interpretasarc4-to-convertbytes)
  - [BoxRef → Box\<bytes\>](#replace-boxref-with-boxbytes)
  - [.native property](#replace-native-property)
- [New Features](#new-features)

## Migration Checklist

Work through these changes when migrating from beta to 1.0:

- [ ] **Object literals**: Add `readonly` or `as const` if immutability needed
- [ ] **Native arrays**: Add `readonly` or `as const` if immutability needed
- [ ] **MutableArray → ReferenceArray**: Replace all usages
- [ ] **Copy method**: Replace `.copy()` with `clone()`
- [ ] **ARC4 numeric types**: Remove 'N' and 'NxM' suffixes
- [ ] **gtxn/itxn imports**: Update to namespaced imports
- [ ] **Resource encoding**: Add `resourceEncoding: 'index'` or update implementation
- [ ] **Test files**: Rename from `.(spec|test).ts` to `.algo.(spec|test).ts`
- [ ] **arc4EncodedLength**: Replace with `sizeOf`
- [ ] **abiCall signature**: Update to object parameter syntax
- [ ] **interpretAsArc4**: Replace with `convertBytes`
- [ ] **BoxRef**: Replace with `Box<bytes>`
- [ ] **.native property**: Replace with `.asUint64()` or `.asBigUint()`

## Breaking Changes

### Object literals - add `readonly` or `as const` if immutability needed

Object literals are now mutable by default.

**BEFORE - Beta**

```ts
import { uint64, Uint64 } from '@algorandfoundation/algorand-typescript';

// These are immutable
type Point = { y: uint64; x: uint64 };
const p1: Point = { x: 1, y: 2 };
const p2 = { x: Uint64(1), y: Uint64(2) };
```

**AFTER - 1.0**

```ts
import { uint64, Uint64 } from '@algorandfoundation/algorand-typescript';

// Mutable by default
type Point = { y: uint64; x: uint64 };
const p1: Point = { x: 1, y: 2 };
p1.x = 3; // Now allowed

// For immutability, use readonly or as const
type ImmutablePoint = Readonly<{ y: uint64; x: uint64 }>;
const p2 = { x: Uint64(1), y: Uint64(2) } as const;
```

### Native arrays - add `readonly` or `as const` if immutability needed

Native arrays are now mutable by default.

**BEFORE - Beta**

```ts
import { uint64, Uint64 } from '@algorandfoundation/algorand-typescript';

// Arrays are immutable
const t1: uint64[] = [1, 2, 3];
const t2 = [Uint64(1), Uint64(2), Uint64(3)];
```

**AFTER - 1.0**

```ts
import { uint64, Uint64 } from '@algorandfoundation/algorand-typescript';

// Arrays are mutable
const t1: uint64[] = [1, 2, 3];
t1[0] = 3;
t1.push(4);

// For immutability
const t2: readonly uint64[] = [1, 2, 3];
const t3 = [Uint64(1), Uint64(2), Uint64(3)] as const;
```

### Rename `MutableArray` to `ReferenceArray`

**BEFORE - Beta**

```ts
import { uint64, MutableArray } from '@algorandfoundation/algorand-typescript';

const a = new MutableArray<uint64>();
```

**AFTER - 1.0**

```ts
import { uint64, ReferenceArray } from '@algorandfoundation/algorand-typescript';

const a = new ReferenceArray<uint64>();
```

### Replace `xxx.copy()` calls with `clone(xxx)`

**BEFORE - Beta**

```ts
import { arc4 } from '@algorandfoundation/algorand-typescript';

const a = new arc4.StaticArray<arc4.UintN64, 3>(
  new arc4.UintN64(1),
  new arc4.UintN64(2),
  new arc4.UintN64(3)
);
const b = a.copy();
```

**AFTER - 1.0**

```ts
import { arc4, clone } from '@algorandfoundation/algorand-typescript';

const a = new arc4.StaticArray<arc4.Uint64, 3>(
  new arc4.Uint64(1),
  new arc4.Uint64(2),
  new arc4.Uint64(3)
);
const b = clone(a);
```

### Remove 'N' and 'NxM' suffixes from ARC4 numeric types

**BEFORE - Beta**

```ts
import { arc4 } from '@algorandfoundation/algorand-typescript';

type User = {
  id: arc4.UintN16;
  score: arc4.UFixedNxM<32, 4>;
};

const user = {
  id: new arc4.UintN<16>(1234),
  score: new arc4.UFixedNxM<32, 4>('1.234'),
};
```

**AFTER - 1.0**

```ts
import { arc4 } from '@algorandfoundation/algorand-typescript';

type User = {
  id: arc4.Uint16;
  score: arc4.UFixed<32, 4>;
};

const user = {
  id: new arc4.Uint<16>(1234),
  score: new arc4.UFixed<32, 4>('1.234'),
};
```

### Update `gtxn` and `itxn` imports

**BEFORE - Beta**

```ts
import type { PaymentTxn } from '@algorandfoundation/algorand-typescript/gtxn';

function makePayment(payment: PaymentTxn) {
  // ...
}
```

**AFTER - 1.0**

```ts
import type { gtxn } from '@algorandfoundation/algorand-typescript';

function makePayment(payment: gtxn.PaymentTxn) {
  // ...
}
```

### Update resource encoding

`resourceEncoding: 'index' | 'value'` option added to `@abimethod` with `value` as default.

**BEFORE - Beta**

```ts
test(asset: Asset, app: Application, acc: Account) {
  const assetIdx = op.btoi(Txn.applicationArgs(1));
  assert(asset === Txn.assets(assetIdx));
  // ...
}
```

**AFTER - 1.0 (keeping index behavior)**

```ts
import { abimethod } from '@algorandfoundation/algorand-typescript';

@abimethod({ resourceEncoding: 'index' })
test(asset: Asset, app: Application, acc: Account) {
  const assetIdx = op.btoi(Txn.applicationArgs(1));
  assert(asset === Txn.assets(assetIdx));
  // ...
}
```

**AFTER - 1.0 (using new value encoding)**

```ts
test(asset: Asset, app: Application, acc: Account) {
  const assetId = op.btoi(Txn.applicationArgs(1));
  assert(asset === Asset(assetId)); // Now passed by value
  // ...
}
```

### Rename test files

Rename test files from `.(spec|test).ts` to `.algo.(spec|test).ts` for files that:
- Run in simulated AVM environment
- Import from `algorand-typescript` or `algorand-typescript-testing`

### Rename `arc4EncodedLength` to `sizeOf`

**BEFORE - Beta**

```ts
import { arc4EncodedLength, assert } from '@algorandfoundation/algorand-typescript';

assert(arc4EncodedLength<uint64>() === 8);
```

**AFTER - 1.0**

```ts
import { sizeOf, assert } from '@algorandfoundation/algorand-typescript';

assert(sizeOf<uint64>() === 8);
```

### Update `abiCall` syntax

**BEFORE - Beta**

```ts
arc4.abiCall(Hello.prototype.greet, {
  appId: 1234,
  args: ['abi'],
});
```

**AFTER - 1.0**

```ts
// Option 1: method property
arc4.abiCall({
  method: Hello.prototype.greet,
  appId: app,
  args: ['abi'],
});

// Option 2: type argument (supports type-only imports)
arc4.abiCall<typeof HelloStubbed.prototype.greet>({
  appId: app,
  args: ['stubbed'],
});
```

### Rename `interpretAsArc4` to `convertBytes`

**BEFORE - Beta**

```ts
const x = arc4.interpretAsArc4<arc4.UintN<32>>(someBytes);
const y = arc4.interpretAsArc4<arc4.Byte>(someBytes, 'log');
```

**AFTER - 1.0**

```ts
const x = arc4.convertBytes<arc4.Uint<32>>(someBytes, { strategy: 'validate' });
const y = arc4.convertBytes<arc4.Byte>(someBytes, {
  prefix: 'log',
  strategy: 'unsafe-cast',
});
```

### Replace `BoxRef` with `Box<bytes>`

**BEFORE - Beta**

```ts
import { BoxRef, Bytes } from '@algorandfoundation/algorand-typescript';

const box = BoxRef({ key: 'test_key' });
box.create({ size: 32768 });
box.put(Bytes('FOO'));
box.resize(Uint64(6));
const extracted = box.extract(0, 3);
box.resize(extracted.size);
```

**AFTER - 1.0**

```ts
import { Box, Bytes, bytes } from '@algorandfoundation/algorand-typescript';

const box = Box<bytes>({ key: 'test_key' });
box.create({ size: 32768 });
box.value = Bytes('FOO');
box.resize(Uint64(6));
const extracted = box.extract(Uint64(0), Uint64(3));
box.resize(extracted.length);
```

### Replace `.native` property

**BEFORE - Beta**

```ts
const z = new arc4.UintN8(n);
const z_native = z.native;

const a = new arc4.UintN128(b);
const a_native = a.native;
```

**AFTER - 1.0**

```ts
const z = new arc4.Uint<8>(n);
const z_native = z.asUint64(); // For types ≤64 bits

const a = new arc4.Uint<128>(b);
const a_native = a.asBigUint(); // For types >64 bits
```

## New Features

### Native mutable objects

```ts
type Point = { x: uint64; y: uint64 };
const p: Point = { x: 1, y: 2 };
p.x = 3;
p.y = 4;
```

### Native mutable arrays

```ts
const a: uint64[] = [1, 2, 3];
a[0] = 10;
a.push(4);
```

### FixedArray type

```ts
const x = new FixedArray<uint64, 4>(1, 2, 3, 4);
x[0] = 0;
```

### Fixed-size bytes

```ts
snapshotPublicKey = GlobalState<bytes<32>>();
const fromUtf8 = Bytes('abc', { length: 3 });
```

### Number and bigint const literals

```ts
const x = 123;
const y = x * 500;
const a = 2n ** 128n;
```

### Tuples in storage

```ts
boxA = Box<[string, bytes]>({ key: Bytes('A') });
boxA.value = ['Hello', Bytes('World')];
```

### Composite box map keys

```ts
boxMap = BoxMap<{ a: uint64; b: uint64 }, string>({ keyPrefix: '' });
boxMap({ a: 1, b: 2 }).value = 'test';
```

### Dynamic inner transaction composition

```ts
itxnCompose.begin(payFields);
for (const i of urange(1, addresses.length)) {
  itxnCompose.next({ ...payFields, receiver: addresses[i].bytes });
}
itxnCompose.submit();
```

### `not` expressions in match

```ts
assertMatch(xObj, { x: { not: 3 } }, 'x should not be 3');
```

### `@readonly` decorator

```ts
@readonly
public getPreconditions(signature: bytes<64>): VotingPreconditions {
  // ...
}
```

### `validateEncoding` option

```ts
@abimethod({ validateEncoding: 'args' })
withValidation(value: bytes<32>) {
  return value.length;
}
```
