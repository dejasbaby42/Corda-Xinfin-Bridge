# 🌐 API Endpoints – XinFin Bridge Relay

This document describes the RESTful APIs provided by the bridge backend, typically deployed via `relay.py` or a web3 gateway. These endpoints enable secure cross-chain submission, encrypted metadata anchoring, and real-time integrations.

---

## 🔁 `/relay`

Submit a transaction hash from Corda for on-chain anchoring.

**POST** `/relay`

### Request Body
```json
{
  "txHash": "0xabcdef123456..."  // 32-byte hex string
}
