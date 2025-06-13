// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionTracker {
    address public admin;

    event TransactionRelayed(
        bytes32 indexed txHash,
        address indexed relayer,
        uint256 timestamp,
        string originChain,
        string destinationChain
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Called by bridge relayer/oracle when a transaction is successfully bridged
    function trackTransaction(
        bytes32 txHash,
        string calldata originChain,
        string calldata destinationChain
    ) external onlyAdmin {
        emit TransactionRelayed(txHash, msg.sender, block.timestamp, originChain, destinationChain);
    }

    /// @notice Update admin in case of key rotation
    function setAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }
}
