// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PrivacyEnhancedBridge {
    address public admin;

    // Mapping of hashed tx IDs to encrypted data (off-chain encrypted)
    mapping(bytes32 => bytes) private encryptedPayloads;

    event TransactionStored(bytes32 indexed txHash, address indexed sender);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Stores encrypted transaction data indexed by txHash
    function storeEncryptedPayload(bytes32 txHash, bytes calldata encryptedData) external onlyAdmin {
        require(encryptedPayloads[txHash].length == 0, "Already stored");
        encryptedPayloads[txHash] = encryptedData;
        emit TransactionStored(txHash, msg.sender);
    }

    /// @notice Retrieves encrypted data for a given txHash
    function getEncryptedPayload(bytes32 txHash) external view returns (bytes memory) {
        return encryptedPayloads[txHash];
    }

    /// @notice Admin can be changed if needed
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
