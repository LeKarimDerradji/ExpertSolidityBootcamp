//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./Token.sol";

contract DeFi1 {
    uint256 initialAmount = 0;
    address[] public investors;
    mapping(address => bool) private isInvestors;
    uint256 blockReward = 0;
    Token public token;

    constructor(uint256 _initialAmount, uint256 _blockReward) {
        initialAmount = initialAmount;
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

    // Throws an ari
    function calculatePayout() public returns (uint256) {
        uint256 payout = 10;
        blockReward = block.number % 1000;
        payout = initialAmount / investors.length;
        payout = payout * blockReward;
        blockReward--;
        return 100;
    }
}
