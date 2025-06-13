// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BatchedTransactionProcessor {
    address public admin;

    struct TransferRequest {
        address token;
        address from;
        address to;
        uint256 amount;
    }

    event BatchExecuted(uint256 batchId, uint256 totalTransfers, uint256 timestamp);
    event TransferFailed(uint256 index, address from, address to, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Executes a batch of ERC-20 token transfers
    function executeBatch(uint256 batchId, TransferRequest[] calldata batch) external onlyAdmin {
        uint256 count = batch.length;
        require(count > 0, "Empty batch");

        for (uint256 i = 0; i < count; i++) {
            TransferRequest calldata t = batch[i];
            bool success = IERC20(t.token).transferFrom(t.from, t.to, t.amount);

            if (!success) {
                emit TransferFailed(i, t.from, t.to, t.amount);
            }
        }

        emit BatchExecuted(batchId, count, block.timestamp);
    }

    /// @notice Allows the current admin to update the admin address
    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }
}
