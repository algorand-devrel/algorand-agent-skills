## Balance changes

The `balanceChanges` field on `TransactionFilter` matches transactions that
produce specific balance effects. The `balanceChanges` property on
`SubscribedTransaction` exposes the computed balance changes for each matched
transaction.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Filter by Algo balance changes

Use `assetId: 0n` to match transactions that move Algos. Combine with `role`
and `minAbsoluteAmount` to narrow results:

```typescript
import { BalanceChangeRole } from "@algorandfoundation/algokit-subscriber";

const filter: TransactionFilter = {
  balanceChanges: [
    {
      assetId: 0n,
      role: BalanceChangeRole.Sender,
      minAbsoluteAmount: 1_000_000, // at least 1 Algo
    },
  ],
};
```

**What just happened:** `assetId: 0n` targets Algo balance changes (asset ID 0
represents Algos). `role: BalanceChangeRole.Sender` restricts to changes where
the account is the sender. `minAbsoluteAmount: 1_000_000` requires the absolute
value of the change to be at least 1 Algo (1,000,000 microAlgos). All fields
within a single balance change entry are AND-ed.

### Filter by ASA balance changes

Use a specific `assetId` to match transactions that move a particular ASA:

```typescript
import { BalanceChangeRole } from "@algorandfoundation/algokit-subscriber";

const filter: TransactionFilter = {
  balanceChanges: [
    {
      assetId: 31566704n, // USDC on MainNet
      role: BalanceChangeRole.Receiver,
    },
  ],
};
```

**What just happened:** `assetId: 31566704n` targets balance changes for USDC.
`role: BalanceChangeRole.Receiver` restricts to the receiving side of the
transfer. The `assetId` field also accepts an array of `bigint` values to match
any of several assets.

### Filter by address and role

Combine `address` and `role` to match transactions where a specific account
participates in a particular way:

```typescript
import { BalanceChangeRole } from "@algorandfoundation/algokit-subscriber";

const filter: TransactionFilter = {
  balanceChanges: [
    {
      address: "ALICE_ADDRESS...",
      role: [BalanceChangeRole.Sender, BalanceChangeRole.CloseTo],
    },
  ],
};
```

**What just happened:** `address` filters to balance changes affecting a specific
account. `role` accepts a single `BalanceChangeRole` or an array — when an array
is given, any of the listed roles satisfies the condition. This example matches
transactions where Alice is either the sender or the close-to recipient.
`address` also accepts an array of strings to match any of several accounts.

### Filter by amount range

Use `minAmount`, `maxAmount`, `minAbsoluteAmount`, and `maxAbsoluteAmount` to
match balance changes within a specific value range:

```typescript
const filter: TransactionFilter = {
  balanceChanges: [
    {
      assetId: 0n,
      minAmount: -10_000_000, // outflow of at most 10 Algos
      maxAmount: -1_000_000,  // outflow of at least 1 Algo
    },
  ],
};

// Using absolute amounts to match regardless of direction
const absoluteFilter: TransactionFilter = {
  balanceChanges: [
    {
      assetId: 31566704n,
      minAbsoluteAmount: 1000,
      maxAbsoluteAmount: 10000,
    },
  ],
};
```

**What just happened:** `minAmount` and `maxAmount` filter on the signed balance
change value — negative values represent outflows (sender side), positive values
represent inflows (receiver side). `minAbsoluteAmount` and `maxAbsoluteAmount`
filter on `Math.abs()` of the balance change, matching regardless of direction.
All amount fields accept `number` or `bigint`. Units are microAlgos for Algo
balance changes or the asset's smallest divisible unit for ASAs.

### Inspect balance changes on a transaction

The `balanceChanges` array on `SubscribedTransaction` contains one entry per
address/asset combination affected by the transaction:

```typescript
subscriber.on("my-filter", async (txn) => {
  if (txn.balanceChanges) {
    for (const change of txn.balanceChanges) {
      console.log(`Address: ${change.address}`);
      console.log(`Asset ID: ${change.assetId}`);   // 0n for Algos
      console.log(`Amount: ${change.amount}`);       // signed bigint
      console.log(`Roles: ${change.roles.join(", ")}`);
    }
  }
});
```

**What just happened:** Each `BalanceChange` in the array has four fields:
`address` (the affected account), `assetId` (the asset ID as `bigint`, with `0n`
for Algos), `amount` (the signed change in smallest divisible unit or
microAlgos), and `roles` (an array of `BalanceChangeRole` values describing why
the account was affected). A single transaction can produce multiple balance
changes — for example, a payment creates entries for both sender and receiver.

### BalanceChangeRole values

The `BalanceChangeRole` enum defines how an account participates in a
transaction's balance effects:

```typescript
import { BalanceChangeRole } from "@algorandfoundation/algokit-subscriber";

// All available roles:
BalanceChangeRole.Sender         // Account sent a transaction (asset outflow and/or fee spending)
BalanceChangeRole.Receiver       // Account received a transaction
BalanceChangeRole.CloseTo        // Account had an asset amount closed to it
BalanceChangeRole.AssetCreator   // Account created an asset and holds the full supply
BalanceChangeRole.AssetDestroyer // Account destroyed an asset (amount is always 0)
```

**What just happened:** Each role indicates why a balance changed:
- **Sender** — the account sent the transaction, resulting in an asset outflow
  and/or fee deduction (for Algo, asset ID `0`).
- **Receiver** — the account received assets or Algos from the transaction.
- **CloseTo** — the account received the remaining balance when an asset or Algo
  account was closed (via close-remainder-to or asset-close-to).
- **AssetCreator** — the account created a new ASA and holds the full initial
  supply.
- **AssetDestroyer** — the account destroyed an ASA, removing the supply from
  circulation. A balance change with this role always has an `amount` of `0n`
  and uses the asset manager address.
