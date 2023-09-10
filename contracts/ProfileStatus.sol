// SPDX-License-Identifier: UNLICENSED
// This contract is not linked to any license
pragma solidity ^0.8.13;
// This contract is compiled with Solidity version 0.8.13

// Importing ContractMetadata from the thirdweb-dev contracts extension
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

// This contract allows users to create and update their profile status
contract ProfileStatus is ContractMetadata {
    // Address of the contract owner
    address public owner;

    // Constructor function that sets the owner of the contract to the sender of the transaction
    constructor() {
        owner = msg.sender;
    }
    
    // Struct to represent a user's status, which includes the status message and a boolean indicating if the status exists
    struct Status {
        string statusMessage;
        bool exists;
    }

    // Mapping from user addresses to their statuses
    mapping(address => Status) public userStatus;

    // Events to emit when a status is created or updated
    event StatusCreated(address indexed wallet, string status);
    event StatusUpdated(address indexed wallet, string newStatus);

    // Function to create a new status, takes in the initial status message as input
    function createStatus(string memory initialStatus) public {
        // Require that the user does not already have a status
        require(!userStatus[msg.sender].exists, "Status already exists.");

        // Assign the new status to the user
        userStatus[msg.sender] = Status({
            statusMessage: initialStatus,
            exists: true
        });

        // Emit the StatusCreated event
        emit StatusCreated(msg.sender, initialStatus);
    }

    // Function to update an existing status, takes in the new status message as input
    function updateStatus(string memory newStatus) public {
        // Require that the user has a status
        require(userStatus[msg.sender].exists, "Status does not exist.");

        // Update the user's status message
        userStatus[msg.sender].statusMessage = newStatus;

        // Emit the StatusUpdated event
        emit StatusUpdated(msg.sender, newStatus);
    }

    // Function to get a user's status, takes in the user's address as input
    function getStatus(address wallet) public view returns (string memory) {
        // Require that the user has a status
        require(userStatus[wallet].exists, "Status does not exist.");

        // Return the user's status message
        return userStatus[wallet].statusMessage;
    }

    // Function to check if the sender of the transaction can set the contract URI
    function _canSetContractURI() internal view virtual override returns (bool){
        // Only the owner of the contract can set the contract URI
        return msg.sender == owner;
    }
}
