# Python x402 Facilitator Reference

Detailed API reference for building x402 facilitator services in Python with Algorand (AVM) support.

## FacilitatorAvmSigner Protocol

The `FacilitatorAvmSigner` is a Python Protocol class (structural typing -- no inheritance required). Any class implementing all six methods satisfies the protocol.

**Import:**
```python
from x402.mechanisms.avm.signer import FacilitatorAvmSigner
```

### Method: `get_addresses()`

```python
def get_addresses(self) -> list[str]:
```

Returns all managed fee payer addresses. The facilitator uses these addresses to identify which transactions it is responsible for signing in an atomic group.

- **Returns:** List of 58-character Algorand addresses
- **Typical implementation:** Returns a single-element list with the facilitator's address

### Method: `sign_transaction()`

```python
def sign_transaction(
    self, txn_bytes: bytes, fee_payer: str, network: str,
) -> bytes:
```

Signs a single transaction with the fee payer's private key.

- **Parameters:**
  - `txn_bytes` -- Raw msgpack-encoded unsigned transaction bytes
  - `fee_payer` -- 58-character Algorand address of the fee payer
  - `network` -- CAIP-2 network identifier (e.g., `"algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI="`)
- **Returns:** Raw msgpack-encoded signed transaction bytes
- **Encoding note:** Must convert `txn_bytes` to base64 before calling `msgpack_decode()`, then convert `msgpack_encode()` result back from base64

### Method: `sign_group()`

```python
def sign_group(
    self,
    group_bytes: list[bytes],
    fee_payer: str,
    indexes_to_sign: list[int],
    network: str,
) -> list[bytes]:
```

Signs specified transactions in an atomic group.

- **Parameters:**
  - `group_bytes` -- List of raw msgpack-encoded transaction bytes (mix of signed and unsigned)
  - `fee_payer` -- 58-character Algorand address
  - `indexes_to_sign` -- Indexes of transactions this facilitator should sign
  - `network` -- CAIP-2 network identifier
- **Returns:** Updated list with signed bytes at specified indexes, unchanged bytes elsewhere
- **Typical pattern:** Delegates to `sign_transaction()` for each index

### Method: `simulate_group()`

```python
def simulate_group(
    self, group_bytes: list[bytes], network: str,
) -> None:
```

Simulates a transaction group to verify it would succeed on-chain. Raises an exception if simulation fails.

- **Parameters:**
  - `group_bytes` -- List of raw msgpack-encoded transaction bytes
  - `network` -- CAIP-2 network identifier
- **Returns:** None (raises on failure)
- **Key pattern:** Wrap unsigned `Transaction` objects with `SignedTransaction(txn, None)` and set `allow_empty_signatures=True`
- **Checks:** Iterates `txn-groups` in simulation result for `failure-message`

### Method: `send_group()`

```python
def send_group(
    self, group_bytes: list[bytes], network: str,
) -> str:
```

Sends a fully signed transaction group to the network.

- **Parameters:**
  - `group_bytes` -- List of raw msgpack-encoded signed transaction bytes
  - `network` -- CAIP-2 network identifier
- **Returns:** Transaction ID string
- **Key pattern:** Use `send_raw_transaction(base64.b64encode(b"".join(group_bytes)))` to concatenate and send all transactions efficiently
- **Important:** Do NOT use `send_transactions()` which asserts inputs are NOT `Transaction` type

### Method: `confirm_transaction()`

```python
def confirm_transaction(
    self, txid: str, network: str, rounds: int = 4,
) -> None:
```

Waits for transaction confirmation on the blockchain.

- **Parameters:**
  - `txid` -- Transaction ID returned by `send_group()`
  - `network` -- CAIP-2 network identifier
  - `rounds` -- Maximum number of rounds to wait (default: 4)
- **Returns:** None (raises on timeout)
- **Note:** Algorand has instant finality; once confirmed, the transaction is permanent

---

## register_exact_avm_facilitator

```python
from x402.mechanisms.avm.exact import register_exact_avm_facilitator

register_exact_avm_facilitator(
    facilitator: x402Facilitator,
    signer: FacilitatorAvmSigner,
    networks: list[str] = None,
)
```

Registers the AVM exact payment scheme on a facilitator instance.

- **Parameters:**
  - `facilitator` -- An `x402Facilitator` instance
  - `signer` -- Any object implementing the `FacilitatorAvmSigner` protocol
  - `networks` -- List of CAIP-2 network identifiers to register for. Defaults to `[ALGORAND_TESTNET_CAIP2, ALGORAND_MAINNET_CAIP2]`

---

## ExactAvmFacilitatorScheme

The scheme class registered by `register_exact_avm_facilitator`. It handles:

- **Verification:** Decodes the payment group, validates transaction structure, simulates on-chain
- **Settlement:** Signs the fee payer transaction, sends the atomic group, confirms on-chain
- **Security validation:** Checks for rekey attacks, close-to exploits, blocked transaction types

---

## Multi-Network Facilitator (EVM + SVM + AVM)

A facilitator can support multiple blockchain networks simultaneously:

```python
from x402 import x402Facilitator

# EVM registration
from x402.mechanisms.evm.exact import register_exact_evm_facilitator
# SVM registration
from x402.mechanisms.svm.exact import register_exact_svm_facilitator
# AVM registration
from x402.mechanisms.avm.exact import register_exact_avm_facilitator

facilitator = x402Facilitator()

# Register all networks
register_exact_evm_facilitator(facilitator, evm_signer)
register_exact_svm_facilitator(facilitator, svm_signer)
register_exact_avm_facilitator(facilitator, avm_signer, networks=[ALGORAND_TESTNET_CAIP2])
```

**Signer types by network:**

| Network | Signer Type | Import |
|---------|------------|--------|
| EVM | `FacilitatorWeb3Signer` | `from x402.mechanisms.evm.signer import FacilitatorWeb3Signer` |
| SVM | `FacilitatorKeypairSigner` | `from x402.mechanisms.svm.signer import FacilitatorKeypairSigner` |
| AVM | `FacilitatorAvmSigner` | `from x402.mechanisms.avm.signer import FacilitatorAvmSigner` |

---

## Facilitator Lifecycle Hooks

| Hook | Signature | Description |
|------|-----------|-------------|
| `on_before_verify` | `(payload, requirements) -> None` | Called before payment verification |
| `on_after_verify` | `(payload, requirements, result) -> None` | Called after verification completes |
| `on_before_settle` | `(payload, requirements) -> None` | Called before settlement submission |
| `on_after_settle` | `(payload, requirements, result) -> None` | Called after settlement completes |

---

## Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `AVM_PRIVATE_KEY` | Yes | Base64-encoded 64-byte key (32-byte seed + 32-byte pubkey) | -- |
| `ALGOD_SERVER` | No | Custom Algod node URL | AlgoNode public endpoint |
| `ALGOD_TOKEN` | No | Algod API token | `""` |
| `ALGOD_MAINNET_URL` | No | Mainnet Algod URL | `https://mainnet-api.algonode.cloud` |
| `ALGOD_TESTNET_URL` | No | Testnet Algod URL | `https://testnet-api.algonode.cloud` |

---

## algosdk Encoding Reference (v2.11.1)

The Python `algosdk` has different encoding conventions than the TypeScript version. This is the most common source of bugs:

| Operation | Python algosdk | TypeScript algosdk |
|-----------|---------------|-------------------|
| `msgpack_decode(s)` | Expects **base64 string** | N/A (uses `decodeUnsignedTransaction(Uint8Array)`) |
| `msgpack_encode(obj)` | Returns **base64 string** | N/A (uses `txn.toByte()` returning `Uint8Array`) |
| `Transaction.sign(key)` | Expects **base64 string** key | `signTransaction(txn, Uint8Array)` |
| SDK protocol | Passes **raw msgpack bytes** | Passes **raw `Uint8Array`** |

**Boundary conversion patterns:**

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

## API Endpoints

A standard x402 facilitator exposes three endpoints:

| Endpoint | Method | Description | Request Body |
|----------|--------|-------------|-------------|
| `/supported` | GET | List supported networks | -- |
| `/verify` | POST | Verify a payment payload | `{paymentPayload, paymentRequirements}` |
| `/settle` | POST | Settle a verified payment | `{paymentPayload, paymentRequirements}` |

---

## Installation Commands

```bash
# Minimal facilitator
pip install "x402-avm[avm,fastapi]"

# With uvicorn for production
pip install "x402-avm[avm,fastapi]" uvicorn

# Multi-chain facilitator (EVM + SVM + AVM)
pip install "x402-avm[all,fastapi]"

# Everything
pip install "x402-avm[all]"
```

---

## Testing

```bash
# Start the facilitator
AVM_PRIVATE_KEY="your-key" uvicorn facilitator_service:app --port 4000

# Check supported networks
curl http://localhost:4000/supported

# Verify a payment (with actual payload)
curl -X POST http://localhost:4000/verify \
  -H "Content-Type: application/json" \
  -d '{"paymentPayload": {...}, "paymentRequirements": {...}}'
```

---

## External Resources

- [Facilitator Example Source](https://github.com/GoPlausible/x402-avm/tree/branch-v2-algorand-publish/examples/python/facilitator)
- [x402-avm AVM Documentation](https://github.com/GoPlausible/.github/blob/main/profile/algorand-x402-documentation/)
- [algosdk Python Reference](https://py-algorand-sdk.readthedocs.io/)
- [Algorand Developer Portal](https://developer.algorand.org/)
