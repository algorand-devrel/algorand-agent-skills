# Python x402 Facilitator Examples

## FacilitatorAvmSigner Protocol

```python
from x402.mechanisms.avm.signer import FacilitatorAvmSigner

# Protocol definition:
class FacilitatorAvmSigner(Protocol):
    def get_addresses(self) -> list[str]:
        """Get all managed fee payer addresses."""
        ...

    def sign_transaction(
        self, txn_bytes: bytes, fee_payer: str, network: str,
    ) -> bytes:
        """Sign a single transaction with the fee payer's key."""
        ...

    def sign_group(
        self,
        group_bytes: list[bytes],
        fee_payer: str,
        indexes_to_sign: list[int],
        network: str,
    ) -> list[bytes]:
        """Sign specified transactions in a group."""
        ...

    def simulate_group(
        self, group_bytes: list[bytes], network: str,
    ) -> None:
        """Simulate a transaction group (raises on failure)."""
        ...

    def send_group(
        self, group_bytes: list[bytes], network: str,
    ) -> str:
        """Send a transaction group, returns txid."""
        ...

    def confirm_transaction(
        self, txid: str, network: str, rounds: int = 4,
    ) -> None:
        """Wait for transaction confirmation."""
        ...
```

---

## AlgorandFacilitatorSigner Implementation

```python
import base64
from x402.mechanisms.avm.signer import FacilitatorAvmSigner
from x402.mechanisms.avm.constants import (
    ALGORAND_TESTNET_CAIP2,
    ALGORAND_MAINNET_CAIP2,
    NETWORK_CONFIGS,
)
from algosdk import encoding, transaction
from algosdk.v2client import algod


class AlgorandFacilitatorSigner:
    """
    Production FacilitatorAvmSigner implementation.

    Key encoding notes (algosdk v2.11.1):
    - msgpack_decode(s) expects base64 string, NOT raw bytes
    - msgpack_encode(obj) returns base64 string, NOT raw bytes
    - Transaction.sign(pk) expects base64 string private key
    - SDK protocol passes raw msgpack bytes between methods
    - Boundary: msgpack_decode(base64.b64encode(raw).decode()) for decode
    - Boundary: base64.b64decode(msgpack_encode(obj)) for encode
    """

    def __init__(self, private_key_b64: str, algod_url: str = "", algod_token: str = ""):
        self._secret_key = base64.b64decode(private_key_b64)
        self._address = encoding.encode_address(self._secret_key[32:])
        self._signing_key = base64.b64encode(self._secret_key).decode()

        # Create algod clients per network
        self._clients: dict[str, algod.AlgodClient] = {}
        if algod_url:
            self._default_client = algod.AlgodClient(algod_token, algod_url)
        else:
            self._default_client = None

    def _get_client(self, network: str) -> algod.AlgodClient:
        if network not in self._clients:
            if self._default_client:
                self._clients[network] = self._default_client
            else:
                config = NETWORK_CONFIGS.get(network, {})
                url = config.get("algod_url", "https://testnet-api.algonode.cloud")
                self._clients[network] = algod.AlgodClient("", url)
        return self._clients[network]

    def get_addresses(self) -> list[str]:
        return [self._address]

    def sign_transaction(
        self, txn_bytes: bytes, fee_payer: str, network: str,
    ) -> bytes:
        """Sign a single transaction."""
        b64_txn = base64.b64encode(txn_bytes).decode("utf-8")
        txn_obj = encoding.msgpack_decode(b64_txn)
        signed = txn_obj.sign(self._signing_key)
        return base64.b64decode(encoding.msgpack_encode(signed))

    def sign_group(
        self,
        group_bytes: list[bytes],
        fee_payer: str,
        indexes_to_sign: list[int],
        network: str,
    ) -> list[bytes]:
        """Sign specified transactions in a group."""
        result = list(group_bytes)
        for i in indexes_to_sign:
            result[i] = self.sign_transaction(group_bytes[i], fee_payer, network)
        return result

    def simulate_group(self, group_bytes: list[bytes], network: str) -> None:
        """Simulate a transaction group.

        Key pattern: wrap unsigned transactions with SignedTransaction(txn, None)
        and use allow_empty_signatures=True.
        """
        client = self._get_client(network)
        stxns = []
        for txn_bytes in group_bytes:
            b64 = base64.b64encode(txn_bytes).decode("utf-8")
            obj = encoding.msgpack_decode(b64)
            if isinstance(obj, transaction.SignedTransaction):
                stxns.append(obj)
            elif isinstance(obj, transaction.Transaction):
                stxns.append(transaction.SignedTransaction(obj, None))
            else:
                stxns.append(obj)

        request = transaction.SimulateRequest(
            txn_groups=[
                transaction.SimulateRequestTransactionGroup(txns=stxns)
            ],
            allow_empty_signatures=True,
        )
        result = client.simulate_raw_transactions(request)

        for group in result.get("txn-groups", []):
            if group.get("failure-message"):
                raise Exception(
                    f"Simulation failed: {group['failure-message']}"
                )

    def send_group(self, group_bytes: list[bytes], network: str) -> str:
        """Send a transaction group.

        Key pattern: use send_raw_transaction(base64.b64encode(b''.join(group_bytes)))
        to avoid decode/re-encode overhead.
        """
        client = self._get_client(network)
        raw = base64.b64encode(b"".join(group_bytes))
        return client.send_raw_transaction(raw)

    def confirm_transaction(
        self, txid: str, network: str, rounds: int = 4,
    ) -> None:
        """Wait for transaction confirmation."""
        client = self._get_client(network)
        transaction.wait_for_confirmation(client, txid, rounds)


# Usage:
import os

signer = AlgorandFacilitatorSigner(
    private_key_b64=os.environ["AVM_PRIVATE_KEY"],
    algod_url="https://testnet-api.algonode.cloud",
)
print(f"Fee payer addresses: {signer.get_addresses()}")
```

---

## Facilitator Registration

```python
from x402 import x402Facilitator
from x402.mechanisms.avm.exact import register_exact_avm_facilitator
from x402.mechanisms.avm import ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2

facilitator = x402Facilitator()

# Single network
register_exact_avm_facilitator(
    facilitator, signer, networks=[ALGORAND_TESTNET_CAIP2]
)

# Multiple networks
register_exact_avm_facilitator(
    facilitator, signer, networks=[ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2]
)
```

---

## Complete FastAPI Facilitator Service

```python
# facilitator_service.py
import os
import base64
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from x402 import x402Facilitator
from x402.mechanisms.avm.exact import register_exact_avm_facilitator
from x402.mechanisms.avm import ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2
from x402.mechanisms.avm.constants import NETWORK_CONFIGS
from algosdk import encoding, transaction
from algosdk.v2client import algod

app = FastAPI(title="x402-avm Facilitator Service")

# Build signer
SECRET_KEY = base64.b64decode(os.environ["AVM_PRIVATE_KEY"])
ADDRESS = encoding.encode_address(SECRET_KEY[32:])
SIGNING_KEY = base64.b64encode(SECRET_KEY).decode()


class FacilitatorSigner:
    def __init__(self):
        self._clients: dict[str, algod.AlgodClient] = {}

    def _client(self, network: str) -> algod.AlgodClient:
        if network not in self._clients:
            config = NETWORK_CONFIGS.get(network, {})
            url = config.get("algod_url", "https://testnet-api.algonode.cloud")
            self._clients[network] = algod.AlgodClient("", url)
        return self._clients[network]

    def get_addresses(self) -> list[str]:
        return [ADDRESS]

    def sign_transaction(self, txn_bytes: bytes, fee_payer: str, network: str) -> bytes:
        b64 = base64.b64encode(txn_bytes).decode()
        txn_obj = encoding.msgpack_decode(b64)
        signed = txn_obj.sign(SIGNING_KEY)
        return base64.b64decode(encoding.msgpack_encode(signed))

    def sign_group(self, group_bytes, fee_payer, indexes, network):
        result = list(group_bytes)
        for i in indexes:
            result[i] = self.sign_transaction(group_bytes[i], fee_payer, network)
        return result

    def simulate_group(self, group_bytes, network):
        client = self._client(network)
        stxns = []
        for txn_bytes in group_bytes:
            b64 = base64.b64encode(txn_bytes).decode()
            obj = encoding.msgpack_decode(b64)
            if isinstance(obj, transaction.SignedTransaction):
                stxns.append(obj)
            else:
                stxns.append(transaction.SignedTransaction(obj, None))
        req = transaction.SimulateRequest(
            txn_groups=[transaction.SimulateRequestTransactionGroup(txns=stxns)],
            allow_empty_signatures=True,
        )
        result = client.simulate_raw_transactions(req)
        for group in result.get("txn-groups", []):
            if group.get("failure-message"):
                raise Exception(f"Simulation failed: {group['failure-message']}")

    def send_group(self, group_bytes, network):
        client = self._client(network)
        return client.send_raw_transaction(
            base64.b64encode(b"".join(group_bytes))
        )

    def confirm_transaction(self, txid, network, rounds=4):
        client = self._client(network)
        transaction.wait_for_confirmation(client, txid, rounds)


# Initialize facilitator
signer = FacilitatorSigner()
facilitator = x402Facilitator()
register_exact_avm_facilitator(
    facilitator,
    signer,
    networks=[ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2],
)


@app.get("/supported")
async def supported():
    return facilitator.get_supported_networks()


@app.post("/verify")
async def verify(request: Request):
    body = await request.json()
    try:
        result = await facilitator.verify(
            body["paymentPayload"], body["paymentRequirements"]
        )
        return result
    except Exception as e:
        return JSONResponse(
            status_code=400, content={"error": str(e)}
        )


@app.post("/settle")
async def settle(request: Request):
    body = await request.json()
    try:
        result = await facilitator.settle(
            body["paymentPayload"], body["paymentRequirements"]
        )
        return result
    except Exception as e:
        return JSONResponse(
            status_code=400, content={"error": str(e)}
        )


@app.on_event("startup")
async def startup():
    print(f"Facilitator service started")
    print(f"Fee payer address: {ADDRESS}")
    print(f"Networks: Testnet + Mainnet")


# Run: uvicorn facilitator_service:app --port 4000
```

---

## algosdk Encoding Boundary Patterns

```python
import base64
from algosdk import encoding

# Raw bytes -> algosdk object (DECODE)
raw_bytes: bytes = ...
b64_string = base64.b64encode(raw_bytes).decode("utf-8")
txn_obj = encoding.msgpack_decode(b64_string)

# algosdk object -> raw bytes (ENCODE)
b64_string = encoding.msgpack_encode(txn_obj)
raw_bytes = base64.b64decode(b64_string)
```

---

## Inline FacilitatorSigner (Minimal)

```python
import os
import base64
from algosdk import encoding, transaction
from algosdk.v2client import algod

SECRET = base64.b64decode(os.environ["AVM_PRIVATE_KEY"])
ADDR = encoding.encode_address(SECRET[32:])
KEY = base64.b64encode(SECRET).decode()
CLIENT = algod.AlgodClient("", "https://testnet-api.algonode.cloud")


class MinimalSigner:
    def get_addresses(self):
        return [ADDR]

    def sign_transaction(self, txn_bytes, fee_payer, network):
        obj = encoding.msgpack_decode(base64.b64encode(txn_bytes).decode())
        return base64.b64decode(encoding.msgpack_encode(obj.sign(KEY)))

    def sign_group(self, group_bytes, fee_payer, indexes, network):
        r = list(group_bytes)
        for i in indexes:
            r[i] = self.sign_transaction(group_bytes[i], fee_payer, network)
        return r

    def simulate_group(self, group_bytes, network):
        stxns = []
        for b in group_bytes:
            obj = encoding.msgpack_decode(base64.b64encode(b).decode())
            stxns.append(
                obj if isinstance(obj, transaction.SignedTransaction)
                else transaction.SignedTransaction(obj, None)
            )
        req = transaction.SimulateRequest(
            txn_groups=[transaction.SimulateRequestTransactionGroup(txns=stxns)],
            allow_empty_signatures=True,
        )
        res = CLIENT.simulate_raw_transactions(req)
        for g in res.get("txn-groups", []):
            if g.get("failure-message"):
                raise Exception(g["failure-message"])

    def send_group(self, group_bytes, network):
        return CLIENT.send_raw_transaction(base64.b64encode(b"".join(group_bytes)))

    def confirm_transaction(self, txid, network, rounds=4):
        transaction.wait_for_confirmation(CLIENT, txid, rounds)
```
