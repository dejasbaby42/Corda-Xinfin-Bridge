```markdown
# 🛰️ Event Monitoring – Corda ↔ XinFin Bridge

This branch contains Python utilities for real-time monitoring of smart contract events on the XinFin network. These listeners are used to track cross-chain activity relayed from Corda, confirm bridge operations, and support indexing for dashboards or automated workflows.

---

## 📁 Included Files

| File | Description |
|------|-------------|
| `monitor.py` | Listens for `TransactionRelayed` events and logs them to console. |
| `abi/XinfinBridge.json` | ABI for the `XinfinBridge.sol` smart contract. |
| `utils/decoder.py` | *(Optional)* Utility functions for parsing or formatting events. |
| `.env.example` | Environment variable template for configuration. |
| `requirements.txt` | Required Python packages. |

---

## ⚙️ Setup

### 1. Install dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure environment
Create a `.env` file based on `.env.example`:
```env
XDC_RPC=https://erpc.xinfin.network
CONTRACT_ADDRESS=0xYourContractAddressHere
START_BLOCK=latest
POLL_INTERVAL=10
```

### 3. Start monitoring
```bash
python monitor.py
```

---

## 📡 Tracked Events

Currently listening for:

- `TransactionRelayed(txHash, relayer, timestamp)`  
Emitted by `XinfinBridge.sol` when a transaction is successfully relayed from Corda to XinFin.

Support for other events (e.g. `SwapInitiated`, `VerifiedTransaction`) can be added by extending the ABI and listener logic.

---

## 💡 Coming Soon

- Webhook integrations (Discord, Slack, REST API)
- SQLite logging for audit history
- Multichain contract listeners

---
