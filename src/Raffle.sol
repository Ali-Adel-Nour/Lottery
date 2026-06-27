// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle Contract
 * @author Ali
 * @notice This contract is for creating a sample raffle
 */

import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/vrf/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2 {
   /* Custom Erros*/

    error Raffle_NotEnoughEth();
    error Raffle_NotEnoughTime();
    error Raffle_TransferFailed();
    error Raffle_NotOpen();

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint256 private immutable I_ENTRANCE_FEE;
    uint256 private immutable I_INTERVAL;
    address payable [] private sPlayers;
    uint256 private sLastTimeStamp;

    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed winner);

    VRFCoordinatorV2Interface private immutable COORDINATOR;
    bytes32 private immutable KEY_HASH;
    uint64 private immutable SUBSCRIPTION_ID;
    uint32 private immutable CALLBACK_GAS_LIMIT;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    address private sRecentWinner;
    RaffleState private sRaffleState;

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        I_ENTRANCE_FEE = entranceFee;
        I_INTERVAL = interval;
        sLastTimeStamp = block.timestamp;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        KEY_HASH = keyHash;
        SUBSCRIPTION_ID = subscriptionId;
        CALLBACK_GAS_LIMIT = callbackGasLimit;
        sRaffleState = RaffleState.OPEN;
    }

   function enterRaffle() external payable {
        //require(msg.value >= i_entranceFee, "Not enough ETH sent");

         //more readable

        //require(msg.value >= I_ENTRANCE_FEE, Raffle_NotEnoughEth());
        
        //Gas Effiecent
        if (msg.value < I_ENTRANCE_FEE){
            revert Raffle_NotEnoughEth();
        }

        if (sRaffleState != RaffleState.OPEN) {
            revert Raffle_NotOpen();
        }

     sPlayers.push(payable(msg.sender));

     emit RaffleEnter(msg.sender);
   }

   function pickWinner() external {
        //check to see if enough time has passed
        if (block.timestamp - sLastTimeStamp <= I_INTERVAL) {
            revert Raffle_NotEnoughTime();
        }
        sRaffleState = RaffleState.CALCULATING;
        uint256 requestId = COORDINATOR.requestRandomWords(
        KEY_HASH,
        SUBSCRIPTION_ID,
        REQUEST_CONFIRMATIONS,
        CALLBACK_GAS_LIMIT,
        NUM_WORDS
    );
}

//CEI : Checks, Effects, Interactions

   function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        //Checks 

        // conditional checks are already done in pickWinner function
    
    //Effect Internal Contract State
        uint256 indexOfWinner = randomWords[0] % sPlayers.length;
        address payable recentWinner = sPlayers[indexOfWinner];
         sRecentWinner = recentWinner;
         sRaffleState = RaffleState.OPEN;
         sPlayers = new address payable[](0);
         sLastTimeStamp = block.timestamp;

         //Interactions (External Contract Interactions)
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle_TransferFailed();
        }

        emit WinnerPicked(sRecentWinner);
       
    }

   /* Getter Functions */
   function getEntranceFee() external view returns (uint256) {
        return I_ENTRANCE_FEE;
   }
}