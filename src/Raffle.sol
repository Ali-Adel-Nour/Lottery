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

    uint256 private immutable I_ENTRANCE_FEE;
    uint256 private immutable I_INTERVAL;
    address payable [] private sPlayers;
    uint256 private sLastTimeStamp;

    event RaffleEnter(address indexed player);

    VRFCoordinatorV2Interface private immutable COORDINATOR;
    bytes32 private immutable KEY_HASH;
    uint64 private immutable SUBSCRIPTION_ID;
    uint32 private immutable CALLBACK_GAS_LIMIT;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

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
    }

   function enterRaffle() external payable {
        //require(msg.value >= i_entranceFee, "Not enough ETH sent");

         //more readable

        //require(msg.value >= I_ENTRANCE_FEE, Raffle_NotEnoughEth());
        
        //Gas Effiecent
        if (msg.value < I_ENTRANCE_FEE){
            revert Raffle_NotEnoughEth();
        }

     sPlayers.push(payable(msg.sender));

     emit RaffleEnter(msg.sender);
   }

   function pickWinner() external {
        //check to see if enough time has passed
        if (block.timestamp - sLastTimeStamp <= I_INTERVAL) {
            revert Raffle_NotEnoughTime();
        }
        uint256 requestId = COORDINATOR.requestRandomWords(
        KEY_HASH,
        SUBSCRIPTION_ID,
        REQUEST_CONFIRMATIONS,
        CALLBACK_GAS_LIMIT,
        NUM_WORDS
    );
}

   function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // TODO: pick a winner using randomWords
    }

   /* Getter Functions */
   function getEntranceFee() external view returns (uint256) {
        return I_ENTRANCE_FEE;
   }
}