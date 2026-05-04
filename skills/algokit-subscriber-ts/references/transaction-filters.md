## Transaction filters

A `TransactionFilter` specifies which transactions to match during a
subscription poll. All fields within a single filter are AND-ed together;
use multiple `NamedTransactionFilter` entries to OR across different criteria.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Filter by transaction type

Use the `type` field with one or more `TransactionType` enum values to match
only specific transaction kinds:

```typescript
import { TransactionType } from "@algorandfoundation/algokit-utils/transact";

const filter: TransactionFilter = {
  type: TransactionType.Payment,
};

// Match multiple types at once
const multiTypeFilter: TransactionFilter = {
  type: [TransactionType.Payment, TransactionType.AssetTransfer],
};
```

**What just happened:** The `type` field accepts a single `TransactionType` or
an array. Available values are `Payment` (`"pay"`), `KeyRegistration`
(`"keyreg"`), `AssetConfig` (`"acfg"`), `AssetTransfer` (`"axfer"`),
`AssetFreeze` (`"afrz"`), `AppCall` (`"appl"`), `StateProof` (`"stpf"`), and
`Heartbeat` (`"hb"`). When an array is provided, a transaction matching any of
the listed types satisfies this field.

### Filter by sender or receiver

Use `sender` and/or `receiver` to match transactions involving specific
addresses:

```typescript
const filter: TransactionFilter = {
  sender: "SENDERADDRESS...",
};

// Match any of several senders
const multiSenderFilter: TransactionFilter = {
  sender: ["ALICE_ADDRESS...", "BOB_ADDRESS..."],
};

// Match by receiver
const receiverFilter: TransactionFilter = {
  receiver: "RECEIVERADDRESS...",
};

// Combine sender and receiver (AND semantics)
const bothFilter: TransactionFilter = {
  sender: "ALICE_ADDRESS...",
  receiver: "BOB_ADDRESS...",
};
```

**What just happened:** `sender` and `receiver` each accept a single address
string or an array of addresses. When an array is given, a transaction matching
any address in the array satisfies that field. When both `sender` and `receiver`
are specified, both conditions must be true (AND semantics).

### Filter by note prefix

Use `notePrefix` to match transactions whose note field starts with the given
string:

```typescript
const filter: TransactionFilter = {
  notePrefix: "arc200/transfer",
};
```

**What just happened:** The `notePrefix` field is a plain string. The subscriber
checks whether the transaction's note (decoded as a string) starts with this
value. This is useful for matching ARC or application-specific note conventions.

### Filter by app ID

Use `appId` to match transactions that call a specific application, and
`appCreate` to match application creation transactions:

```typescript
const filter: TransactionFilter = {
  appId: 123456789n,
};

// Match calls to any of several apps
const multiAppFilter: TransactionFilter = {
  appId: [123456789n, 987654321n],
};

// Match only app creation transactions
const appCreateFilter: TransactionFilter = {
  appCreate: true,
};
```

**What just happened:** `appId` accepts a single `bigint` or an array of
`bigint` values. A transaction calling any of the listed app IDs satisfies this
field. `appCreate` is a boolean — when `true`, only transactions that create a
new application are matched. These can be combined: `appId` with `appCreate`
would not typically be used together since a creation transaction does not yet
have an app ID at the point of submission.

### Filter by asset ID

Use `assetId` to match transactions involving a specific asset, and
`assetCreate` to match asset creation transactions:

```typescript
const filter: TransactionFilter = {
  assetId: 31566704n, // USDC on MainNet
};

// Match transfers of multiple assets
const multiAssetFilter: TransactionFilter = {
  type: TransactionType.AssetTransfer,
  assetId: [31566704n, 312769n],
};

// Match only asset creation transactions
const assetCreateFilter: TransactionFilter = {
  assetCreate: true,
};
```

**What just happened:** `assetId` accepts a single `bigint` or an array of
`bigint` values. A transaction involving any of the listed asset IDs satisfies
this field. `assetCreate` is a boolean — when `true`, only transactions that
create a new asset are matched. Combining `assetId` with `type:
TransactionType.AssetTransfer` narrows results to transfers of those specific
assets.

### Filter by amount range

Use `minAmount` and/or `maxAmount` to match transactions within a specific
value range:

```typescript
// Match payments of at least 1 Algo (1_000_000 microAlgos)
const largePayments: TransactionFilter = {
  type: TransactionType.Payment,
  minAmount: 1_000_000,
};

// Match small asset transfers (0–100 decimal units)
const smallTransfers: TransactionFilter = {
  type: TransactionType.AssetTransfer,
  assetId: 31566704n,
  maxAmount: 100,
};

// Match payments in a specific range
const rangeFilter: TransactionFilter = {
  type: TransactionType.Payment,
  minAmount: 1_000_000,
  maxAmount: 10_000_000,
};
```

**What just happened:** `minAmount` and `maxAmount` accept `number` or `bigint`.
For payment transactions the unit is microAlgos; for asset transfers it is the
asset's decimal units. When both are specified, the transaction amount must fall
within the inclusive range [minAmount, maxAmount].

### Filter by ABI method signature

Use `methodSignature` to match application calls that invoke specific ARC-4
methods:

```typescript
const filter: TransactionFilter = {
  type: TransactionType.AppCall,
  methodSignature: "transfer(address,address,uint64)void",
};

// Match any of several methods
const multiMethodFilter: TransactionFilter = {
  type: TransactionType.AppCall,
  appId: 123456789n,
  methodSignature: [
    "transfer(address,address,uint64)void",
    "approve(address,uint64)void",
  ],
};
```

**What just happened:** `methodSignature` accepts a single ARC-4 method
signature string or an array. The subscriber computes the 4-byte method selector
from each signature and checks whether the first app argument matches. When an
array is given, matching any selector satisfies this field.

### Filter by app call on-complete

Use `appOnComplete` to match application calls with a specific on-completion
action:

```typescript
import { ApplicationOnComplete } from "@algorandfoundation/algokit-utils/indexer";

const filter: TransactionFilter = {
  type: TransactionType.AppCall,
  appOnComplete: ApplicationOnComplete.optin,
};

// Match opt-in or close-out
const multiOnCompleteFilter: TransactionFilter = {
  type: TransactionType.AppCall,
  appOnComplete: [ApplicationOnComplete.optin, ApplicationOnComplete.closeout],
};
```

**What just happened:** `appOnComplete` accepts a single
`ApplicationOnComplete` value or an array. Available values are `noop`,
`optin`, `closeout`, `clear`, `update`, and `delete`. When an array is given,
a transaction with any of the listed on-complete values satisfies this field.

### Filter by ARC-28 events

Use `arc28Events` to match application calls that emit specific ARC-28 events.
The event definitions must also be provided via the top-level `arc28Events`
subscription config:

```typescript
const filter: TransactionFilter = {
  type: TransactionType.AppCall,
  arc28Events: [{ groupName: "my-app", eventName: "Transfer" }],
};
```

**What just happened:** `arc28Events` accepts an array of
`{ groupName: string; eventName: string }` objects. Each object identifies an
ARC-28 event by group and name. A transaction matches if it emits at least one
of the listed events. Note: the corresponding event definitions must be passed
in to the subscription config via the top-level `arc28Events` parameter so the
subscriber knows how to decode logs.

### Filter by balance changes

Use `balanceChanges` to match transactions that produce specific balance change
effects:

```typescript
import { BalanceChangeRole } from "@algorandfoundation/algokit-subscriber/types/subscription";

const filter: TransactionFilter = {
  balanceChanges: [
    {
      assetId: 31566704n,
      role: BalanceChangeRole.Receiver,
      address: "RECEIVERADDRESS...",
      minAbsoluteAmount: 1000,
    },
  ],
};
```

**What just happened:** `balanceChanges` accepts an array of balance change
criteria. Each entry can specify `assetId` (`bigint | bigint[]`), `role`
(`BalanceChangeRole | BalanceChangeRole[]`), `address` (`string | string[]`),
`minAbsoluteAmount` / `maxAbsoluteAmount` (`number | bigint`), and `minAmount`
/ `maxAmount` (`number | bigint`). A transaction matches if any of its balance
changes satisfies at least one entry in the array (OR across entries, AND within
an entry). The `minAbsoluteAmount` / `maxAbsoluteAmount` fields compare against
the absolute value of the balance change amount, while `minAmount` / `maxAmount`
compare against the signed value.

### Filter with custom predicates

Use `appCallArgumentsMatch` to filter by arbitrary app call argument inspection,
or `customFilter` as a catch-all predicate:

```typescript
// Match app calls where the second argument is a specific address
const argFilter: TransactionFilter = {
  type: TransactionType.AppCall,
  appCallArgumentsMatch: (args) =>
    !!args && args.length > 1 && Buffer.from(args[1]).toString() === "TARGETADDRESS...",
};

// Catch-all custom filter
const customFilter: TransactionFilter = {
  customFilter: (txn) => txn.fee > 10_000,
};
```

**What just happened:** `appCallArgumentsMatch` accepts a predicate function
`(appCallArguments?: readonly Uint8Array[]) => boolean` that receives the raw
app call arguments. `customFilter` accepts a predicate
`(transaction: SubscribedTransaction) => boolean` that receives the full
transaction. Both are AND-ed with other fields in the same filter.

### Combine multiple filter fields

All fields within a single `TransactionFilter` are AND-ed — a transaction must
satisfy every specified field to match:

```typescript
// Match USDC transfers of at least 1000 units sent by a specific address
const combinedFilter: TransactionFilter = {
  type: TransactionType.AssetTransfer,
  sender: "ALICE_ADDRESS...",
  assetId: 31566704n,
  minAmount: 1000,
};
```

**What just happened:** This filter requires all four conditions to be true
simultaneously: the transaction must be an asset transfer, sent by the
specified address, involving asset 31566704, and transferring at least 1000
decimal units. If any single condition fails, the transaction is not matched.

### Use multiple named filters

Wrap filters in `NamedTransactionFilter` entries to OR across different
criteria. Each matched transaction reports which filter(s) it matched via the
`filtersMatched` field:

```typescript
import { AlgorandSubscriber } from "@algorandfoundation/algokit-subscriber";

const subscriber = new AlgorandSubscriber(
  {
    filters: [
      {
        name: "large-payments",
        filter: {
          type: TransactionType.Payment,
          minAmount: 10_000_000,
        },
      },
      {
        name: "usdc-transfers",
        filter: {
          type: TransactionType.AssetTransfer,
          assetId: 31566704n,
        },
      },
    ],
    syncBehaviour: "skip-sync-newest",
    watermarkPersistence: {
      get: async () => 0n,
      set: async () => {},
    },
  },
  algod,
);

// Each filter triggers its own event stream
subscriber.on("large-payments", async (txn) => {
  console.log(`Large payment: ${txn.id}`);
});

subscriber.on("usdc-transfers", async (txn) => {
  console.log(`USDC transfer: ${txn.id}, matched: ${txn.filtersMatched}`);
});
```

**What just happened:** The `filters` array contains multiple
`NamedTransactionFilter` entries. A transaction is included in results if it
matches any filter (OR semantics across filters). Each matching transaction
carries a `filtersMatched` string array listing the names of all filters it
satisfied — a single transaction can match multiple named filters. Use
`subscriber.on(filterName, handler)` to handle each filter's matches
independently.
