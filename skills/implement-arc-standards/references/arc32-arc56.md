# ARC-32 and ARC-56: Application Specifications

Application specifications describe a smart contract's interface, state schema, and metadata. They enable typed client generation, IDE support, and enhanced developer experience.

## ARC-32 vs ARC-56 Comparison

| Feature | ARC-32 | ARC-56 |
|---------|--------|--------|
| **Status** | Deprecated | Current Standard |
| **ARC-4 methods** | Yes | Yes |
| **State schema** | Yes | Yes |
| **Method hints** | Partial | Full |
| **Named structs** | No | Yes |
| **Default argument values** | Limited | Full support |
| **Source code info** | No | Yes (optional) |
| **Source maps** | No | Yes (optional) |
| **ARC-28 events** | No | Yes |
| **Bare action config** | Yes | Yes |
| **Template variables** | No | Yes |
| **Scratch variables** | No | Yes |

**Recommendation:** Use ARC-56 for all new projects. ARC-32 is maintained for legacy compatibility only.

## Generating App Specs

### From Algorand Python

```bash
# Compile contract - generates both .arc32.json and .arc56.json
puyapy contracts/my_contract.py

# Or via AlgoKit
algokit project run build
```

Output files:
- `MyContract.arc32.json` - Legacy app spec
- `MyContract.arc56.json` - Modern app spec

### From Algorand TypeScript

```bash
# Compile contract
npx puya-ts contracts/my_contract.ts

# Or via AlgoKit
algokit project run build
```

## ARC-56 Contract Structure

```json
{
  "arcs": [4, 22, 28, 56],
  "name": "Calculator",
  "desc": "A simple calculator contract",
  "networks": {
    "mainnet-v1.0": { "appID": 12345 },
    "testnet-v1.0": { "appID": 67890 }
  },
  "structs": {
    "UserInfo": [
      { "name": "name", "type": "string" },
      { "name": "balance", "type": "uint64" }
    ]
  },
  "methods": [...],
  "state": {
    "schema": {
      "global": { "ints": 2, "bytes": 1 },
      "local": { "ints": 1, "bytes": 0 }
    },
    "keys": {
      "global": {
        "counter": {
          "key": "Y291bnRlcg==",
          "keyType": "AVMString",
          "valueType": "uint64"
        }
      },
      "local": {},
      "box": {}
    },
    "maps": {
      "global": {},
      "local": {},
      "box": {
        "users": {
          "keyType": "address",
          "valueType": "UserInfo",
          "prefix": "dXNlcl8="
        }
      }
    }
  },
  "bareActions": {
    "create": ["NoOp"],
    "call": ["NoOp", "OptIn"]
  },
  "events": [...]
}
```

## Method Descriptions

### ARC-56 Method Format

```json
{
  "name": "transfer",
  "desc": "Transfer tokens to another account",
  "args": [
    {
      "name": "receiver",
      "type": "address",
      "desc": "The account to receive tokens"
    },
    {
      "name": "amount",
      "type": "uint64",
      "desc": "The amount to transfer"
    }
  ],
  "returns": {
    "type": "bool",
    "desc": "True if transfer succeeded"
  },
  "actions": {
    "create": [],
    "call": ["NoOp"]
  },
  "readonly": false,
  "events": [
    { "name": "Transfer", "args": [...] }
  ],
  "recommendations": {
    "innerTransactionCount": 1,
    "accounts": [],
    "apps": [],
    "assets": [],
    "boxes": []
  }
}
```

### Action Configuration

The `actions` field specifies when a method can be called:

```json
{
  "actions": {
    "create": ["NoOp", "OptIn"],
    "call": ["NoOp", "OptIn", "CloseOut", "UpdateApplication", "DeleteApplication"]
  }
}
```

- **create**: OnComplete actions allowed when creating the app (appID === 0)
- **call**: OnComplete actions allowed when calling existing app (appID !== 0)

### Default Argument Values

ARC-56 supports specifying default values for method arguments:

```json
{
  "name": "fee",
  "type": "uint64",
  "defaultValue": {
    "source": "literal",
    "data": "AAAAAAAAAGQ=",
    "type": "uint64"
  }
}
```

Sources for default values:
- `literal`: Base64-encoded value
- `global`: Read from global state key
- `local`: Read from sender's local state
- `box`: Read from box storage
- `method`: Call a readonly method to get the value

## Named Structs

ARC-56 supports named structs that map to ABI tuples:

```json
{
  "structs": {
    "UserInfo": [
      { "name": "name", "type": "string" },
      { "name": "balance", "type": "uint64" },
      { "name": "active", "type": "bool" }
    ],
    "TransferRequest": [
      { "name": "from", "type": "address" },
      { "name": "to", "type": "address" },
      { "name": "info", "type": "UserInfo" }
    ]
  }
}
```

In methods, reference structs by name:

```json
{
  "args": [
    { "name": "user", "type": "(string,uint64,bool)", "struct": "UserInfo" }
  ]
}
```

## State Schema

### Schema Definition

```json
{
  "state": {
    "schema": {
      "global": { "ints": 5, "bytes": 3 },
      "local": { "ints": 2, "bytes": 1 }
    }
  }
}
```

These values are used when creating the application.

### Storage Keys

Named storage keys with type information:

```json
{
  "keys": {
    "global": {
      "total_supply": {
        "key": "dG90YWxfc3VwcGx5",
        "keyType": "AVMString",
        "valueType": "uint64",
        "desc": "Total token supply"
      }
    },
    "local": {
      "balance": {
        "key": "YmFsYW5jZQ==",
        "keyType": "AVMString",
        "valueType": "uint64"
      }
    },
    "box": {
      "metadata": {
        "key": "bWV0YQ==",
        "keyType": "AVMString",
        "valueType": "(string,uint64)"
      }
    }
  }
}
```

### Storage Maps

For dynamic key storage (like BoxMap):

```json
{
  "maps": {
    "box": {
      "users": {
        "keyType": "address",
        "valueType": "UserInfo",
        "prefix": "dXNlcl8="
      }
    }
  }
}
```

## Events (ARC-28)

```json
{
  "events": [
    {
      "name": "Transfer",
      "desc": "Emitted when tokens are transferred",
      "args": [
        { "name": "from", "type": "address" },
        { "name": "to", "type": "address" },
        { "name": "amount", "type": "uint64" }
      ]
    }
  ]
}
```

Events are emitted using `arc4.emit()`:

```python
from algopy import arc4

class Transfer(arc4.Struct):
    from_addr: arc4.Address
    to_addr: arc4.Address
    amount: arc4.UInt64

# In contract method
arc4.emit(Transfer(
    from_addr=arc4.Address(sender),
    to_addr=arc4.Address(receiver),
    amount=arc4.UInt64(amount),
))
```

## Using App Specs

### Generate Typed Clients

```bash
# Python client from ARC-56
puyapy-clientgen MyContract.arc56.json

# Or with AlgoKit CLI
algokit generate client -o ./clients MyContract.arc56.json
```

### TypeScript Client Usage

```typescript
import { AlgorandClient } from '@algorandfoundation/algokit-utils'
import { CalculatorFactory } from './clients/Calculator'

const algorand = AlgorandClient.defaultLocalNet()

// Deploy new contract
const factory = algorand.client.getTypedAppFactory(CalculatorFactory)
const { appClient } = await factory.deploy({
  onSchemaBreak: 'replace',
  onUpdate: 'update',
})

// Call methods with full type safety
const result = await appClient.send.add({
  args: { a: 10n, b: 20n }
})
console.log(result.return) // BigInt: 30n

// Read state with typed access
const state = await appClient.state.global.getAll()
console.log(state.counter) // Typed as bigint
```

### Python Client Usage

```python
from algokit_utils import AlgorandClient
from artifacts.calculator_client import CalculatorFactory

algorand = AlgorandClient.default_localnet()

# Deploy new contract
factory = algorand.client.get_typed_app_factory(CalculatorFactory)
app_client, _ = factory.deploy(
    on_schema_break="replace",
    on_update="update",
)

# Call methods with type hints
result = app_client.send.add(a=10, b=20)
print(result.return_value)  # int: 30

# Read state
state = app_client.state.global_state.get_all()
print(state["counter"])  # Typed value
```

### Converting ARC-32 to ARC-56

AlgoKit Utils provides conversion utilities:

```typescript
import { arc32ToArc56 } from '@algorandfoundation/algokit-utils'
import arc32Spec from './MyContract.arc32.json'

const arc56Spec = arc32ToArc56(arc32Spec)
```

```python
from algokit_utils.applications.app_spec import arc32_to_arc56

arc56_spec = arc32_to_arc56(arc32_spec)
```

## Source Information (Optional)

ARC-56 can include source maps for debugging:

```json
{
  "sourceInfo": {
    "approval": {
      "sourceInfo": [
        {
          "pc": [10, 11, 12],
          "errorMessage": "Assertion failed: balance >= amount"
        }
      ],
      "pcOffsetMethod": "cblocks"
    },
    "clear": {
      "sourceInfo": []
    }
  },
  "source": {
    "approval": "I3ByYWdtYSB2ZXJzaW9uIDEwCg...",
    "clear": "I3ByYWdtYSB2ZXJzaW9uIDEwCg..."
  }
}
```

## Template Variables

For contracts with configurable values:

```json
{
  "templateVariables": {
    "ADMIN_ADDRESS": {
      "type": "address",
      "value": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY5HFKQ"
    },
    "MAX_SUPPLY": {
      "type": "uint64"
    }
  }
}
```

## Common Patterns

### Create-Only Method

```python
@arc4.abimethod(create="require")
def initialize(self, admin: arc4.Address) -> None:
    """Can only be called during app creation."""
    self.admin.value = admin.native
```

### Update Method

```python
@arc4.abimethod(allow_actions=["UpdateApplication"])
def update(self) -> None:
    """Called when updating the application."""
    assert Txn.sender == self.admin.value
```

### Delete Method

```python
@arc4.abimethod(allow_actions=["DeleteApplication"])
def delete(self) -> None:
    """Called when deleting the application."""
    assert Txn.sender == self.admin.value
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using ARC-32 for new projects | Missing features | Use ARC-56 instead |
| Missing schema in deployment | App creation fails | Include schema from app spec |
| Wrong action configuration | Method call rejected | Verify `actions` field |
| Struct name mismatch | Client type errors | Ensure struct names match |
| Not regenerating client | Stale types | Regenerate after contract changes |

## References

- [ARC-32 Specification](https://dev.algorand.co/arc-standards/arc-0032/)
- [ARC-56 Specification](https://dev.algorand.co/arc-standards/arc-0056/)
- [AlgoKit Utils TypeScript](https://dev.algorand.co/algokit/utils/typescript/overview/)
- [AlgoKit Utils Python](https://dev.algorand.co/algokit/utils/python/overview/)
