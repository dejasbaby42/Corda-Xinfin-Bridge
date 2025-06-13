// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract MultiAssetSwap {
    struct Swap {
        address sender;
        address receiver;
        address token;
        uint256 amount;
        bytes32 hashlock;
        uint256 timelock; // Unix timestamp
        bool withdrawn;
        bool refunded;
        bytes32 preimage;
    }

    mapping(bytes32 => Swap) public swaps;

    event SwapInitiated(
        bytes32 indexed swapId,
        address indexed sender,
        address indexed receiver,
        address token,
        uint256 amount,
        bytes32 hashlock,
        uint256 timelock
    );
    event SwapRedeemed(bytes32 indexed swapId, bytes32 preimage);
    event SwapRefunded(bytes32 indexed swapId);

    function initiateSwap(
        bytes32 swapId,
        address receiver,
        address token,
        uint256 amount,
        bytes32 hashlock,
        uint256 timelock
    ) external {
        require(swaps[swapId].sender == address(0), "Swap already exists");
        require(amount > 0, "Amount must be greater than zero");

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        swaps[swapId] = Swap(
            msg.sender,
            receiver,
            token,
            amount,
            hashlock,
            timelock,
            false,
            false,
            0x0
        );

        emit SwapInitiated(swapId, msg.sender, receiver, token, amount, hashlock, timelock);
    }

    function redeemSwap(bytes32 swapId, bytes32 preimage) external {
        Swap storage swap = swaps[swapId];

        require(swap.receiver == msg.sender, "Not authorized");
        require(!swap.withdrawn, "Already withdrawn");
        require(!swap.refunded, "Already refunded");
        require(block.timestamp < swap.timelock, "Swap expired");
        require(keccak256(abi.encodePacked(preimage)) == swap.hashlock, "Invalid preimage");

        swap.withdrawn = true;
        swap.preimage = preimage;
        IERC20(swap.token).transfer(swap.receiver, swap.amount);

        emit SwapRedeemed(swapId, preimage);
    }

    function refundSwap(bytes32 swapId) external {
        Swap storage swap = swaps[swapId];

        require(swap.sender == msg.sender, "Only sender can refund");
        require(!swap.withdrawn, "Already withdrawn");
        require(!swap.refunded, "Already refunded");
        require(block.timestamp >= swap.timelock, "Timelock not expired");

        swap.refunded = true;
        IERC20(swap.token).transfer(swap.sender, swap.amount);

        emit SwapRefunded(swapId);
    }
}
