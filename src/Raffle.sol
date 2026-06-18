// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle Contract
 * @author Ali
 * @notice This contract is for creating a sample raffle
 */

contract Raffle {
    uint256 private  i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

   function enterRaffle() public {

   }

   function pickWinner() public {

   }
}