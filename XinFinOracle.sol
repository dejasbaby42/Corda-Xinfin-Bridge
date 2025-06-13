// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XinFinOracle {
    address public oracleAdmin;
    mapping(bytes32 => bool) public verifiedTransactions;

    event TransactionVerified(bytes32 indexed txHash, address indexed verifier, uint256 timestamp);
    event OracleUpdated(address indexed oldOracle, address indexed newOracle);

    modifier onlyOracle() {
        require(msg.sender == oracleAdmin, "Caller is not the oracle");
        _;
    }

    constructor() {
        oracleAdmin = msg.sender;
    }

    /// @notice Verifies a transaction hash relayed from Corda
    function verifyTransaction(bytes32 txHash) external onlyOracle {
        require(!verifiedTransactions[txHash], "Already verified");
        verifiedTransactions[txHash] = true;
        emit TransactionVerified(txHash, msg.sender, block.timestamp);
    }

    /// @notice Returns verification status
    function isVerified(bytes32 txHash) external view returns (bool) {
        return verifiedTransactions[txHash];
    }

    /// @notice Updates the oracle address
    function updateOracle(address newOracle) external onlyOracle {
        require(newOracle != address(0), "Invalid address");
        emit OracleUpdated(oracleAdmin, newOracle);
        oracleAdmin = newOracle;
    }
}
