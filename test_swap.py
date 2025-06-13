from web3 import Web3
import os, time

# Load environment variables
w3 = Web3(Web3.HTTPProvider(os.getenv("XDC_RPC")))
contract = w3.eth.contract(
    address=Web3.to_checksum_address(os.getenv("SWAP_CONTRACT_ADDRESS")),
    abi=[...]  # Insert ABI for MultiAssetSwap
)

def check_swap(swap_id):
    is_withdrawn = contract.functions.swaps(swap_id).call()[6]
    print(f"Swap Withdrawn: {is_withdrawn}")

# Trigger a test swap or simulate status checks
