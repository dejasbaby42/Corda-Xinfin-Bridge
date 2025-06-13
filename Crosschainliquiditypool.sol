// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract CrossChainLiquidityPool {
    address public admin;

    // token → total balance in pool
    mapping(address => uint256) public poolBalances;

    event Deposited(address indexed token, address indexed user, uint256 amount);
    event Withdrawn(address indexed token, address indexed recipient, uint256 amount);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice User deposits bridged tokens to the liquidity pool
    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Cannot deposit zero");
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        poolBalances[token] += amount;
        emit Deposited(token, msg.sender, amount);
    }

    /// @notice Admin-controlled disbursement of liquidity
    function withdraw(address token, address recipient, uint256 amount) external onlyAdmin {
        require(poolBalances[token] >= amount, "Insufficient pool balance");

        poolBalances[token] -= amount;
        require(IERC20(token).transfer(recipient, amount), "Transfer failed");

        emit Withdrawn(token, recipient, amount);
    }

    /// @notice Rotate admin privileges
    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    /// @notice View current balance for a given token
    function getBalance(address token) external view returns (uint256) {
        return poolBalances[token];
    }
}
