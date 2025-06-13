# API Relay – XinFin Bridge

This Python Flask service receives Corda transaction hashes and relays them to the XinFin blockchain via the `XinfinBridge.sol` smart contract.

## 🧪 Prerequisites

- Python 3.8+
- Node or Web3 RPC access to XinFin

## 🚀 Setup

```bash
pip install -r requirements.txt
cp .env.example .env  # then fill in your credentials
python relay.py
## 🧪 Prerequisites

- Python 3.8+
- Node or Web3 RPC access to XinFin

## 🚀 Setup

```bash
pip install -r requirements.txt
cp .env.example .env  # then fill in your credentials
python relay.py
```

## 🛰️ API

- `POST /relay`
  - JSON body: `{ "txHash": "0x..." }`
  - Relays the transaction to XinFin

## 🔐 Security

- Uses Web3.py to sign and send on-chain transactions
- Environment variables manage sensitive keys and RPC URLs
```
