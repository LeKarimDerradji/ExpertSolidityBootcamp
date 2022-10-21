//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./Token.sol";

contract DeFi1 {
    uint256 initialAmount;
    address[] public investors;
    mapping(address => bool) private isInvestors;
    uint256 blockReward = 0;
    Token public token;
     /**
     *@dev 
     * Badly coded constructor
     */
    constructor(uint256 _initialAmount, uint256 _blockReward) {
        // Initial amount was never initialized : before initialAmount = _initialAmount
        initialAmount = _initialAmount;
        token = new Token(_initialAmount);
        blockReward = _blockReward;
    }

    /**
     *@notice
     *The function is not guarded by a modifier.
     */
    function addInvestor(address _investor) public {
        investors.push(_investor);
        isInvestors[_investor] = true;
    }

    function claimTokens() public {
        require(isInvestors[msg.sender] == true, "no");
        token.transfer(msg.sender, calculatePayout());
    }

    // Returns 0
    function calculatePayout() public returns (uint256) {
        uint256 payout;
        blockReward = block.number % 1000;
        payout = initialAmount / investors.length;
        payout = payout * blockReward;
        blockReward--;
        return payout;
    }
}
