## Getting started

Before exploring the snippets below, install the library and set up your
environment.

### Install

Install the subscriber package from PyPI (requires Python 3.12+):

```bash
pip install algokit-subscriber
```

**What just happened:** This adds the `algokit-subscriber` package to your
project. It provides `AlgorandSubscriber` for continuous polling and `get_subscribed_transactions` for
stateless one-shot subscription.

### Basic imports

Import the main class, the stateless function, and the most common types:

```python
from algokit_subscriber import (
    AlgorandSubscriber,
    get_subscribed_transactions,
    AlgorandSubscriberConfig,
    TransactionFilter,
    NamedTransactionFilter,
    SubscribedTransaction,
    TransactionSubscriptionResult,
)
```

**What just happened:** `AlgorandSubscriber` is the main class for continuous or one-shot polling.
`get_subscribed_transactions` is a standalone function for stateless polling (no class needed).
The type imports give you the config shape, filter definitions, and the enriched transaction type
returned by the subscriber.

### Prerequisites

The subscriber talks directly to an Algorand node. You need an `AlgodClient`; an `IndexerClient` is
optional (only required when using the `catchup-with-indexer` sync behaviour). The easiest way to
obtain both is via `AlgorandClient` from `algokit-utils` v5:

```python
from algokit_utils import AlgorandClient

algorand = AlgorandClient.default_localnet()
algod = algorand.client.algod
# Optional — only needed for catchup-with-indexer sync behaviour
indexer = algorand.client.indexer
```

**What just happened:** `AlgorandClient.default_localnet()` returns a client pre-wired to the
default LocalNet algod, indexer, and KMD ports. `algorand.client.algod` is an `AlgodClient`
(from `algokit_algod_client`) for real-time block data; `algorand.client.indexer` is an
`IndexerClient` (from `algokit_indexer_client`) for fast historical lookups. Use
`AlgorandClient.testnet()` / `AlgorandClient.mainnet()` for the public networks, or
`AlgorandClient.from_config(...)` to point at a custom node. For local development, start
[AlgoKit LocalNet](https://github.com/algorandfoundation/algokit-cli) with `algokit localnet start`
first.
