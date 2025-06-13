# 🔗 Corda ↔ XinFin Relay Integration Guide

This document outlines how to relay a transaction from a Corda node to the XinFin blockchain using the bridge infrastructure.

---

## 🧱 Workflow Overview

1. **Corda node** initiates a `XinFinTransactionState`.
2. The **RelayXinFinTransactionFlow** finalizes and notarizes the transaction.
3. The **Flask relayer API** (`relay.py`) receives the transaction hash.
4. A **Web3 script** sends the hash to the `XinfinBridge` or `RelayerBridge` smart contract.
5. `TransactionRelayed` event is emitted and can be monitored off-chain.

---

## ⚙️ Step-by-Step Integration

### 1. 🚀 Trigger the Flow on Corda

Call the following via RPC or node shell:

```shell
flow start RelayXinFinTransactionFlow 
  receiver: PartyB, 
  amount: 10000 USD, 
  referenceId: "CDXFN-1234", 
  txHash: SHA256 hash of logical payload
