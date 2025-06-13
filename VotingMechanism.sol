// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingMechanism {
    address public admin;
    uint256 public proposalCount;

    enum ProposalStatus { Active, Executed, Cancelled }

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 deadline;
        ProposalStatus status;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) private proposals;

    event ProposalCreated(uint256 indexed id, string description, uint256 deadline);
    event Voted(uint256 indexed proposalId, address indexed voter);
    event ProposalExecuted(uint256 indexed proposalId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createProposal(string calldata description, uint256 durationSeconds) external onlyAdmin {
        proposalCount += 1;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = description;
        p.deadline = block.timestamp + durationSeconds;
        p.status = ProposalStatus.Active;

        emit ProposalCreated(p.id, description, p.deadline);
    }

    function vote(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.deadline, "Voting has ended");
        require(p.status == ProposalStatus.Active, "Proposal is not active");
        require(!p.voted[msg.sender], "Already voted");

        p.voted[msg.sender] = true;
        p.voteCount += 1;

        emit Voted(proposalId, msg.sender);
    }

    function executeProposal(uint256 proposalId) external onlyAdmin {
        Proposal storage p = proposals[proposalId];
        require(p.status == ProposalStatus.Active, "Invalid proposal status");
        require(block.timestamp >= p.deadline, "Voting still in progress");

        p.status = ProposalStatus.Executed;
        emit ProposalExecuted(proposalId);
        // You can add execution logic here (e.g., parameter updates, contract calls)
    }

    function getProposal(uint256 proposalId) external view returns (
        uint256 id,
        string memory description,
        uint256 voteCount,
        uint256 deadline,
        ProposalStatus status
    ) {
        Proposal storage p = proposals[proposalId];
        return (p.id, p.description, p.voteCount, p.deadline, p.status);
    }
}
