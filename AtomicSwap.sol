// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AtomicSwap {
    struct Swap {
        address sender;
        address receiver;
        uint256 amount;
        bytes32 hashlock;
        uint256 timelock; // UNIX timestamp
        bool withdrawn;
        bool refunded;
        bytes32 preimage;
    }

    mapping(bytes32 => Swap) public swaps;

    event Initiated(bytes32 indexed swapID, address indexed sender, address indexed receiver, bytes32 hashlock, uint256 timelock, uint256 amount);
    event Redeemed(bytes32 indexed swapID, bytes32 preimage);
    event Refunded(bytes32 indexed swapID);

    // Create a new swap
    function initiateSwap(bytes32 swapID, address receiver, bytes32 hashlock, uint256 timelock) external payable {
        require(swaps[swapID].sender == address(0), "Swap already exists");
        require(msg.value > 0, "Amount must be greater than 0");

        swaps[swapID] = Swap({
            sender: msg.sender,
            receiver: receiver,
            amount: msg.value,
            hashlock: hashlock,
            timelock: timelock,
            withdrawn: false,
            refunded: false,
            preimage: 0x0
        });

        emit Initiated(swapID, msg.sender, receiver, hashlock, timelock, msg.value);
    }

    // Receiver redeems the funds
    function redeem(bytes32 swapID, bytes32 preimage) external {
        Swap storage s = swaps[swapID];

        require(s.receiver == msg.sender, "Not the receiver");
        require(!s.withdrawn, "Already withdrawn");
        require(!s.refunded, "Already refunded");
        require(block.timestamp < s.timelock, "Timelock expired");
        require(keccak256(abi.encodePacked(preimage)) == s.hashlock, "Invalid preimage");

        s.preimage = preimage;
        s.withdrawn = true;
        payable(s.receiver).transfer(s.amount);

        emit Redeemed(swapID, preimage);
    }

    // Sender refunds after timelock
    function refund(bytes32 swapID) external {
        Swap storage s = swaps[swapID];

        require(s.sender == msg.sender, "Not the sender");
        require(!s.withdrawn, "Already withdrawn");
        require(!s.refunded, "Already refunded");
        require(block.timestamp >= s.timelock, "Timelock not expired");

        s.refunded = true;
        payable(s.sender).transfer(s.amount);

        emit Refunded(swapID);
    }

    function getSwap(bytes32 swapID) external view returns (Swap memory) {
        return swaps[swapID];
    }
}
