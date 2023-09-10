// SPDX-License-Identifier: UNLICENSED
// This contract is not linked to any license
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

pragma solidity ^0.8.13;

// This contract is compiled with Solidity version 0.8.13

// This is a simple MessageBoard contract where users can post and delete messages
contract MessageBoard is ContractMetadata {

    address public deployer;

    constructor() {
        deployer = msg.sender;
    }
    
    // Struct to represent a message, which includes the author's address and the text of the message
    struct Message {
        address author;  
        string text;
    }
    
    // Array to store all messages
    Message[] public messages;
    
    // Address of the contract owner
    address public owner;
    
    // Event to emit when a new message is posted
    event NewMessage(address indexed sender, string message);
    
    // Modifier to require that the sender of the transaction is the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner);
        _;  
    }
    
    // Function to post a new message, takes in the text of the message as input
    function postMessage(string memory _text) public {
        messages.push(Message(msg.sender, _text));
        emit NewMessage(msg.sender, _text);
    }
    
    // Function to get the count of messages
    function getMessagesCount() public view returns (uint256) {
        return messages.length;   
    }
    
    // Function to get the text of a message at a specific index
    function getMessage(uint256 index) public view returns (string memory) {
        require(index < messages.length, "Index out of bounds.");
        return messages[index].text;
    }
    
    // Function to get the author of a message at a specific index
    function getMessageAuthor(uint256 index) public view returns (address) {
        return messages[index].author;
    }
    
    // Function to delete a message at a specific index, can only be called by the owner of the contract
    function deleteMessage(uint256 _index) public onlyOwner {
        // Replace the message at the given index with the last message in the array
        messages[_index] = messages[messages.length - 1];
        // Remove the last message in the array
        messages.pop();
    }
    function _canSetContractURI() internal view virtual override returns (bool){
        return msg.sender == deployer;
    }
}
