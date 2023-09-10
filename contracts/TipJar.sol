// SPDX-License-Identifier: UNLICENSED
// This contract is not linked to any license
pragma solidity ^0.8.13;
// This contract is compiled with Solidity version 0.8.13

// Importing IERC20 from the OpenZeppelin contracts library and ContractMetadata from the thirdweb-dev contracts extension
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

// This contract allows users to tip a recipient in Ether or ERC20 tokens
contract TipJar is ContractMetadata {
    
    // Address of the contract owner and recipient of the tips
    address public owner;
    address public recipient;
    
    // Minimum amount of a tip in Ether
    uint256 public minimumTip = 0.01 ether;
    
    // Array to store the addresses of the ERC20 tokens that can be tipped
    address[] public tokens;
    
    // Mapping from token addresses to their balances in this contract
    mapping(address => uint256) public tokenBalances;
    // Mapping from token addresses to their approved allowances for this contract
    mapping(address => mapping(address => uint256)) public tokenAllowances;
    
    // Events to emit when a tip is received or withdrawn
    event TipReceived(address indexed tipper, uint256 amount);
    event TipWithdrawn(address indexed recipient, uint256 amount);
    
    // Constructor function that sets the owner and recipient of the contract to the sender of the transaction
    constructor() {
        owner = msg.sender;
        recipient = owner;
    }
    
    // Modifier to require that the sender of the transaction is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
    
    // Function to approve an ERC20 token for tipping, takes in the token address and the amount to approve as inputs
    function approveToken(address token, uint256 amount) public {
        IERC20(token).approve(address(this), amount);
    }
    
    // Function to receive Ether tips
    receive() external payable {
        require(msg.value >= minimumTip, "Tip amount must be at least the minimum.");
    }
    
    // Fallback function to receive Ether tips
    fallback() external payable {
        require(msg.value >= minimumTip, "Tip amount must be at least the minimum.");    
    }
    
    // Function to withdraw all tips, can only be called by the owner of the contract
    function withdrawTips() public onlyOwner {
        // Transfer all Ether balance to the recipient
        payable(recipient).transfer(address(this).balance);
        // Transfer all ERC20 token balances to the recipient
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            IERC20(token).transfer(
                recipient, 
                tokenBalances[token]
            );    
        }
    }

    // Function to tip Ether, emits the TipReceived event
    function tip() public payable {
        require(msg.value >= minimumTip, "Tip amount must be at least the minimum.");
        emit TipReceived(msg.sender, msg.value);
    }
    
    
    // Function to get the Ether balance of the contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // Function to set the recipient of the tips, can only be called by the owner of the contract
    function setRecipient(address _recipient) public onlyOwner {
        recipient = _recipient; 
    }
    
    // Function to set the minimum tip amount, can only be called by the owner of the contract
    function setMinimumTip(uint256 _minimumTip) public onlyOwner {
        minimumTip = _minimumTip;
    }
    
    // Function to check if the contract URI can be set, returns true if the sender is the owner of the contract
    function _canSetContractURI() internal view virtual override returns (bool){
        return msg.sender == owner;
    }
}
