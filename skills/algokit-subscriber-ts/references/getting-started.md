## Getting started

Before exploring the snippets below, install the library and set up your
environment.

### Install

Install the subscriber package from npm:

```bash
npm install @algorandfoundation/algokit-subscriber
```

**What just happened:** This adds the `@algorandfoundation/algokit-subscriber` package to your
project. It provides `AlgorandSubscriber` for continuous polling and `getSubscribedTransactions` for
stateless one-shot subscription.

### Basic imports

Import the main class, the stateless function, and the most common types:

```typescript
import { AlgorandSubscriber, getSubscribedTransactions } from "@algorandfoundation/algokit-subscriber";
import type {
  AlgorandSubscriberConfig,
  TransactionFilter,
  NamedTransactionFilter,
  SubscribedTransaction,
  TransactionSubscriptionResult,
} from "@algorandfoundation/algokit-subscriber/types/subscription";
```

**What just happened:** `AlgorandSubscriber` is the main class for continuous or one-shot polling.
`getSubscribedTransactions` is a standalone function for stateless polling (no class needed).
The type imports give you the config shape, filter definitions, and the enriched transaction type
returned by the subscriber.

### Prerequisites

The subscriber talks directly to an Algorand node. You need an `AlgodClient`; an `IndexerClient` is
optional (only required when using the `catchup-with-indexer` sync behaviour).

```typescript
import { AlgodClient } from "@algorandfoundation/algokit-utils/algod-client";
import { IndexerClient } from "@algorandfoundation/algokit-utils/indexer-client";

const algod = new AlgodClient({ baseUrl: "http://localhost:4001", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });
// Optional — only needed for catchup-with-indexer sync behaviour
const indexer = new IndexerClient({ baseUrl: "http://localhost:8980", token: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" });
```

**What just happened:** `AlgodClient` connects to an algod node for real-time block data.
`IndexerClient` connects to an indexer for fast historical lookups. For local development, start
[AlgoKit LocalNet](https://github.com/algorandfoundation/algokit-cli) with `algokit localnet start`
to get both services pre-configured at the ports shown above.
