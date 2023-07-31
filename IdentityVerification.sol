// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityVerification {
    struct IdentityRecord {
        uint256 userId;
        address userAddress;
        string fullName;
        string documentURI; // Link to user's identity document (e.g., IPFS hash)
        uint256 attestationCount;
        mapping(address => bool) hasAttested; // Track whether an address has attested this identity
    }

    mapping(address => IdentityRecord) public identityRecords;
    uint256 public userIdCounter;

    struct Attestation {
        uint256 userId;
        address attester;
        uint256 attestationType;
        uint256 timestamp;
    }

    Attestation[] public attestations;
    uint256 public attestationTypeCount;

    event IdentityRequested(uint256 userId, address userAddress, string fullName);
    event Attested(uint256 userId, address indexed attester, uint256 attestationType);

    modifier onlyUser() {
        require(identityRecords[msg.sender].userAddress == msg.sender, "You are not registered");
        _;
    }

    modifier onlyAttester() {
        require(isAttester(msg.sender), "You are not an authorized attester");
        _;
    }

    function requestIdentityVerification(string memory _fullName, string memory _documentURI) public {
        require(bytes(_fullName).length > 0 && bytes(_documentURI).length > 0, "Invalid identity data");
        userIdCounter++;
        identityRecords[msg.sender] = IdentityRecord({
            userId: userIdCounter,
            userAddress: msg.sender,
            fullName: _fullName,
            documentURI: _documentURI,
            attestationCount: 0
        });
        emit IdentityRequested(userIdCounter, msg.sender, _fullName);
    }

    function attestIdentity(address _userAddress, uint256 _attestationType) public onlyAttester {
        require(_userAddress != address(0), "Invalid user address");
        require(identityRecords[_userAddress].userAddress == _userAddress, "User not registered");
        require(_attestationType < attestationTypeCount, "Invalid attestation type");

        IdentityRecord storage userRecord = identityRecords[_userAddress];
        require(!userRecord.hasAttested[msg.sender], "You have already attested this identity");

        userRecord.hasAttested[msg.sender] = true;
        userRecord.attestationCount++;
        attestations.push(Attestation({
            userId: userRecord.userId,
            attester: msg.sender,
            attestationType: _attestationType,
            timestamp: block.timestamp
        }));

        emit Attested(userRecord.userId, msg.sender, _attestationType);
    }

    function isAttester(address _address) public view returns (bool) {
        // Implement logic to check if an address is an authorized attester
        // (e.g., based on role management or specific rules).
        return true; // Placeholder, you should modify this based on your implementation
    }

    function getIdentityRecord(address _userAddress) public view returns (
        uint256 userId,
        string memory fullName,
        string memory documentURI,
        uint256 attestationCount
    ) {
        IdentityRecord storage userRecord = identityRecords[_userAddress];
        return (
            userRecord.userId,
            userRecord.fullName,
            userRecord.documentURI,
            userRecord.attestationCount
        );
    }
}

