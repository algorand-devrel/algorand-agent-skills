## Balance changes

The `balance_changes` field on `TransactionFilter` matches transactions that
produce specific balance effects. The `balance_changes` property on
`SubscribedTransaction` exposes the computed balance changes for each matched
transaction.

All examples below assume the imports from `references/getting-started.md`
and an `algod` client already configured.

### Filter by Algo balance changes

Use `asset_id=0` to match transactions that move Algos. Combine with `role`
and `min_absolute_amount` to narrow results:

```python
from algokit_subscriber import BalanceChangeFilter, BalanceChangeRole, TransactionFilter

filter_ = TransactionFilter(
    balance_changes=[
        BalanceChangeFilter(
            asset_id=0,
            role=BalanceChangeRole.Sender,
            min_absolute_amount=1_000_000,  # at least 1 Algo
        ),
    ],
)
```

**What just happened:** `asset_id=0` targets Algo balance changes (asset ID 0
represents Algos). `role=BalanceChangeRole.Sender` restricts to changes where
the account is the sender. `min_absolute_amount=1_000_000` requires the absolute
value of the change to be at least 1 Algo (1,000,000 microAlgos). All fields
within a single balance change entry are AND-ed.

### Filter by ASA balance changes

Use a specific `asset_id` to match transactions that move a particular ASA:

```python
from algokit_subscriber import BalanceChangeFilter, BalanceChangeRole, TransactionFilter

filter_ = TransactionFilter(
    balance_changes=[
        BalanceChangeFilter(
            asset_id=31566704,  # USDC on MainNet
            role=BalanceChangeRole.Receiver,
        ),
    ],
)
```

**What just happened:** `asset_id=31566704` targets balance changes for USDC.
`role=BalanceChangeRole.Receiver` restricts to the receiving side of the
transfer. The `asset_id` field also accepts a list of `int` values to match
any of several assets.

### Filter by address and role

Combine `address` and `role` to match transactions where a specific account
participates in a particular way:

```python
from algokit_subscriber import BalanceChangeFilter, BalanceChangeRole, TransactionFilter

filter_ = TransactionFilter(
    balance_changes=[
        BalanceChangeFilter(
            address="ALICE_ADDRESS...",
            role=[BalanceChangeRole.Sender, BalanceChangeRole.CloseTo],
        ),
    ],
)
```

**What just happened:** `address` filters to balance changes affecting a specific
account. `role` accepts a single `BalanceChangeRole` or a list — when a list is
given, any of the listed roles satisfies the condition. This example matches
transactions where Alice is either the sender or the close-to recipient.
`address` also accepts a list of strings to match any of several accounts.

### Filter by amount range

Use `min_amount`, `max_amount`, `min_absolute_amount`, and `max_absolute_amount` to
match balance changes within a specific value range:

```python
filter_ = TransactionFilter(
    balance_changes=[
        BalanceChangeFilter(
            asset_id=0,
            min_amount=-10_000_000,  # outflow of at most 10 Algos
            max_amount=-1_000_000,   # outflow of at least 1 Algo
        ),
    ],
)

# Using absolute amounts to match regardless of direction
absolute_filter = TransactionFilter(
    balance_changes=[
        BalanceChangeFilter(
            asset_id=31566704,
            min_absolute_amount=1000,
            max_absolute_amount=10000,
        ),
    ],
)
```

**What just happened:** `min_amount` and `max_amount` filter on the signed balance
change value — negative values represent outflows (sender side), positive values
represent inflows (receiver side). `min_absolute_amount` and `max_absolute_amount`
filter on `abs()` of the balance change, matching regardless of direction.
All amount fields accept `int` or `float`. Units are microAlgos for Algo
balance changes or the asset's smallest divisible unit for ASAs.

### Inspect balance changes on a transaction

The `balance_changes` list on `SubscribedTransaction` contains one entry per
address/asset combination affected by the transaction:

```python
def handle_transaction(txn: SubscribedTransaction, event_name: str) -> None:
    for change in txn.balance_changes:
        print(f"Address: {change.address}")
        print(f"Asset ID: {change.asset_id}")     # 0 for Algos
        print(f"Amount: {change.amount}")          # signed int
        print(f"Roles: {[r.value for r in change.roles]}")

subscriber.on("my-filter", handle_transaction)
```

**What just happened:** Each `BalanceChange` in the list has four fields:
`address` (the affected account), `asset_id` (the asset ID as `int`, with `0`
for Algos), `amount` (the signed change in smallest divisible unit or
microAlgos), and `roles` (a list of `BalanceChangeRole` values describing why
the account was affected). A single transaction can produce multiple balance
changes — for example, a payment creates entries for both sender and receiver.

### BalanceChangeRole values

The `BalanceChangeRole` enum defines how an account participates in a
transaction's balance effects:

```python
from algokit_subscriber import BalanceChangeRole

# All available roles:
BalanceChangeRole.Sender         # Account sent a transaction (asset outflow and/or fee spending)
BalanceChangeRole.Receiver       # Account received a transaction
BalanceChangeRole.CloseTo        # Account had an asset amount closed to it
BalanceChangeRole.AssetCreator   # Account created an asset and holds the full supply
BalanceChangeRole.AssetDestroyer # Account destroyed an asset (amount is always 0)
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
  circulation. A balance change with this role always has an `amount` of `0`
  and uses the asset manager address.
