// SPDX-License-Identifier: UNLICENSED
// This contract is not linked to any license
pragma solidity ^0.8.13;

import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

// This contract is compiled with Solidity version 0.8.13

// This is a simple CoinFlip contract where players can flip a coin and get a result of heads or tails
contract CoinFlip is ContractMetadata {

      address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    // Enum to represent two sides of a coin
    enum CoinSide { HEADS, TAILS }
    // Enum to represent the result of a coin flip
    enum FlipResult { WIN, LOSE }

    // Event to emit the result of a coin flip
    event Result(address indexed player, CoinSide chosenSide, FlipResult result);

    // Variables to track the total number of wins and losses
    uint256 public winCount;
    uint256 public lossCount;
    
    // Maps to track the number of wins and losses for each player
    mapping(address => uint256) public playerWinCount;
    mapping(address => uint256) public playerLossCount;
    
    // Maps to track the best streak for each player and overall
    mapping(address => uint256) public playerBestStreak;
    uint256 public bestStreak;

    // Function to flip a coin, takes in the chosen side as input
    function flipCoin(CoinSide chosenSide) public {
        // Generate a random number between 0 and 1
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 2;

        // Convert the random number to a coin side
        CoinSide result = CoinSide(randomNumber);

        // Determine if the player has won or lost based on their chosen side and the result of the coin flip
        FlipResult flipResult = (chosenSide == result) ? FlipResult.WIN : FlipResult.LOSE;

        // Emit the result of the coin flip
        emit Result(msg.sender, chosenSide, flipResult);
        
        // Update win and loss counts based on the result of the coin flip
        if (flipResult == FlipResult.WIN) {
            winCount++;
            playerWinCount[msg.sender]++;
            updateStreaks(true);   
        } else {
            lossCount++;     
            playerLossCount[msg.sender]++;     
            updateStreaks(false);
        }
    }
    
    // Function to get the overall win-loss ratio
    function getWinLossRatio() public view returns (uint256, uint256) {
        return (winCount, lossCount); 
    }

    // Function to get a specific player's win-loss ratio
    function getPlayerWinLossRatio(address player) public view returns (uint256, uint256) {
        return (playerWinCount[player], playerLossCount[player]);
    }
    
    // Function to get the current best streak
    function getCurrentStreak() public view returns (uint256) {
        return bestStreak;
    }
    
    // Function to get a specific player's best streak
    function getPlayerBestStreak(address player) public view returns (uint256) {
        return playerBestStreak[player];    
    }
    
    // Helper function to return the maximum of two numbers
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    // Function to update the streaks based on the result of a coin flip
    function updateStreaks(bool isWin) internal {
        if (isWin) {
            // If the player won, increment the current streak
            bestStreak = bestStreak + 1;    
        } else {
            // If the player lost, reset the current streak to 1
            bestStreak = 1;    
        }
        // Update the player's best streak if their current streak is higher
        playerBestStreak[msg.sender] = max(playerBestStreak[msg.sender], bestStreak);
    }

     function _canSetContractURI() internal view virtual override returns (bool){
        return msg.sender == deployer;
    }
}
