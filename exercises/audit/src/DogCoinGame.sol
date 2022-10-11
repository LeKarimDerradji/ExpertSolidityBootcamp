// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DogCoinGame  {
    uint256 public currentPrize;
    uint256 public numberPlayers;
    address payable[] public players;
    address payable[] public winners;

    event startPayout();

    function addPlayer(address payable _player) public payable {
        if (msg.value == 1) {
            players.push(_player);
        }
        numberPlayers++;
        if (numberPlayers > 200) {
            emit startPayout();
        }
    }

    function addWinner(address payable _winner) public {
        winners.push(_winner);
    }

    function payout() public {
        if (address(this).balance == 100) {
            uint256 amountToPay = winners.length / 100;
            payWinners(amountToPay);
        }
    }
     /**
     *@notice
     * DogCoinGame.payWinners(uint256) (src/DogCoinGame.sol#33-37) sends eth to arbitrary user
     * Dangerous calls:
     *  - winners[i].send(_amount) (
     */
    function payWinners(uint256 _amount) public {
        for (uint256 i = 0; i <= winners.length; i++) {
            winners[i].send(_amount);
        }
    }
}