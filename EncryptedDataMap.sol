// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EncryptedDataMap {
    address public admin;

    mapping(bytes32 => bytes) private encryptedRecords;

    event EncryptedRecordStored(bytes32 indexed keyHash, address indexed sender);
    event EncryptedRecordUpdated(bytes32 indexed keyHash, address indexed sender);
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function storeEncrypted(bytes32 keyHash, bytes calldata encryptedPayload) external onlyAdmin {
        require(encryptedRecords[keyHash].length == 0, "Record already exists");
        encryptedRecords[keyHash] = encryptedPayload;
        emit EncryptedRecordStored(keyHash, msg.sender);
    }

    function updateEncrypted(bytes32 keyHash, bytes calldata newEncryptedPayload) external onlyAdmin {
        require(encryptedRecords[keyHash].length != 0, "Record does not exist");
        encryptedRecords[keyHash] = newEncryptedPayload;
        emit EncryptedRecordUpdated(keyHash, msg.sender);
    }

    function fetchEncrypted(bytes32 keyHash) external view returns (bytes memory) {
        return encryptedRecords[keyHash];
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin");
        emit AdminUpdated(admin, newAdmin);
        admin = newAdmin;
    }
}
