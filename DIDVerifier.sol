// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDVerifier {
    address public admin;

    // Maps user address to the hash of their DID Document (stored off-chain)
    mapping(address => bytes32) public didRegistry;

    event DIDRegistered(address indexed user, bytes32 didHash);
    event DIDRevoked(address indexed user);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a user's DID hash
    function registerDID(bytes32 didHash) external {
        require(didRegistry[msg.sender] == bytes32(0), "DID already registered");
        didRegistry[msg.sender] = didHash;
        emit DIDRegistered(msg.sender, didHash);
    }

    /// @notice Verify a user's DID hash matches expected
    function verifyDID(address user, bytes32 expectedHash) external view returns (bool) {
        return didRegistry
