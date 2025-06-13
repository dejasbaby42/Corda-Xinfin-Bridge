// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RelayerBridge {
    address public admin;

    mapping(address => bool) public authorizedRelayers;
    mapping(bytes32 => bool) public processedTransactions;

    event RelayerAdded(address relayer);
    event RelayerRemoved(address relayer);
    event TransactionRelayed(bytes32 indexed txHash, address indexed relayer, uint256 timestamp);
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not admin");
        _;
    }

    modifier onlyRelayer() {
        require(authorizedRelayers[msg.sender], "Caller is not a relayer");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addRelayer(address relayer) external onlyAdmin {
        require(relayer != address(0), "Invalid address");
        authorizedRelayers[relayer] = true;
        emit RelayerAdded(relayer);
    }

    function removeRelayer(address relayer) external onlyAdmin {
        require(authorizedRelayers[relayer], "Relayer not registered");
        authorizedRelayers[relayer] = false;
        emit RelayerRemoved(relayer);
    }

    function relayTransaction(bytes32 txHash) external onlyRelayer {
        require(!processedTransactions[txHash], "Transaction already relayed");

        processedTransactions[txHash] = true;

        emit TransactionRelayed(txHash, msg.sender, block.timestamp);
    }

    function hasRelayed(bytes32 txHash) external view returns (bool) {
        return processedTransactions[txHash];
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin");
        emit AdminUpdated(admin, newAdmin);
        admin = newAdmin;
    }
}
