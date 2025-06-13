from web3 import Web3
import os
import time
from dotenv import load_dotenv

load_dotenv()

XDC_RPC = os.getenv("XDC_RPC")  # e.g., "https://erpc.xinfin.network"
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")  # Contract emitting events
START_BLOCK = int(os.getenv("START_BLOCK", "latest"))

# ABI fragment for events
CONTRACT_ABI = [
    {
        "anonymous": False,
        "inputs": [
            {"indexed": True, "internalType": "bytes32", "name": "txHash", "type": "bytes32"},
            {"indexed": True, "internalType": "address", "name": "relayer", "type": "address"},
            {"indexed": False, "internalType": "uint256", "name": "timestamp", "type": "uint256"}
        ],
        "name": "TransactionRelayed",
        "type": "event"
    }
]

web3 = Web3(Web3.HTTPProvider(XDC_RPC))
contract = web3.eth.contract(address=Web3.to_checksum_address(CONTRACT_ADDRESS), abi=CONTRACT_ABI)

def handle_event(event):
    tx_hash = event["args"]["txHash"].hex()
    relayer = event["args"]["relayer"]
    timestamp = event["args"]["timestamp"]
    print(f"🛰️  TransactionRelayed detected:\n  Hash: {tx_hash}\n  Relayer: {relayer}\n  Time: {timestamp}")

def monitor_events():
    print("⏳ Listening for TransactionRelayed events...")
    latest_block = web3.eth.block_number
    while True:
        try:
            for event in contract.events.TransactionRelayed.create_filter(fromBlock=latest_block).get_new_entries():
                handle_event(event)
            time.sleep(10)
        except Exception as e:
            print(f"⚠️  Error: {str(e)}")
            time.sleep(15)

if __name__ == "__main__":
    monitor_events()
