// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle Contract
 * @author Ali
 * @notice This contract is for creating a sample raffle
 */


contract Raffle {
   /* Custom Erros*/

    error Raffle_NotEnoughEth();

    uint256 private immutable I_ENTRANCE_FEE;

    constructor(uint256 entranceFee) {
        I_ENTRANCE_FEE = entranceFee;
    }

   function enterRaffle() public payable {
        //require(msg.value >= i_entranceFee, "Not enough ETH sent");

         //more readable

        //require(msg.value >= I_ENTRANCE_FEE, Raffle_NotEnoughEth());
        
        //Gas Effiecent
        if (msg.value < I_ENTRANCE_FEE){
            revert Raffle_NotEnoughEth();
        }

       

   }

   function pickWinner() public {

   }

   /* Getter Functions */
   function getEntranceFee() external view returns (uint256) {
        return I_ENTRANCE_FEE;
   }
}