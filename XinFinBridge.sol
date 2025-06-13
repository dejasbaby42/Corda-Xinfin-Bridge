// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XinfinBridge {
    address public admin;
    mapping(bytes32 => bool) public processedTransactions;

    event TransactionRelayed(bytes32 indexed txHash, address indexed relayer, uint256 timestamp);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function relayTransaction(bytes32 txHash) external {
        require(!processedTransactions[txHash], "Transaction already relayed");
        processedTransactions[txHash] = true;
        emit TransactionRelayed(txHash, msg.sender, block.timestamp);
    }

    function isRelayed(bytes32 txHash) external view returns (bool) {
        return processedTransactions[txHash];
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
