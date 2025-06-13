from flask import Flask, request, jsonify
from web3 import Web3
import os

app = Flask(__name__)

# Load environment variables
XDC_RPC = os.getenv("XDC_RPC")  # e.g., "https://erpc.xinfin.network"
PRIVATE_KEY = os.getenv("PRIVATE_KEY")  # Wallet private key (bridge operator)
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")  # Address of XinfinBridge contract
CHAIN_ID = int(os.getenv("CHAIN_ID", "50"))  # XinFin Mainnet is 50

# ABI fragment for relay function
CONTRACT_ABI = [
    {
        "inputs": [{"internalType": "bytes32", "name": "txHash", "type": "bytes32"}],
        "name": "relayTransaction",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

web3 = Web3(Web3.HTTPProvider(XDC_RPC))
account = web3.eth.account.from_key(PRIVATE_KEY)
bridge = web3.eth.contract(address=Web3.to_checksum_address(CONTRACT_ADDRESS), abi=CONTRACT_ABI)

@app.route("/relay", methods=["POST"])
def relay_transaction():
    data = request.get_json()
    tx_hash = data.get("txHash")

    if not tx_hash:
        return jsonify({"error": "txHash is required"}), 400

    try:
        nonce = web3.eth.get_transaction_count(account.address)
        txn = bridge.functions.relayTransaction(tx_hash).build_transaction({
            'chainId': CHAIN_ID,
            'gas': 200000,
            'gasPrice': web3.to_wei('1', 'gwei'),
            'nonce': nonce
        })

        signed_txn = web3.eth.account.sign_transaction(txn, private_key=PRIVATE_KEY)
        tx_hash_sent = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

        return jsonify({"message": "Transaction relayed", "hash": tx_hash_sent.hex()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
