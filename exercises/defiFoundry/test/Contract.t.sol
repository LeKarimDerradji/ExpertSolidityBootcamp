// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/DeFi1.sol";
import "../src/Token.sol";

contract User {
    receive() external payable {}
}

contract ContractTest is Test {
    DeFi1 defi;
    Token token;
    User internal alice;
    User internal bob;
    User internal chloe;
    uint256 initialAmount = 1000;
    uint256 blockReward = 5;

    function setUp() public {
        defi = new DeFi1(initialAmount, blockReward);
        // Token was not set propelly before : defi.token.address was passed as the abstraction's parameter
        token = Token(defi.token());
        alice = new User();
        bob = new User();
        chloe = new User();
    }

    function testInitialBalance() public {
        
    }

    function testAddInvestor() public {
        defi.addInvestor(address(alice));
        assert(defi.investors(0) == address(alice));
    }

    function testClaim() public {
        defi.addInvestor(address(bob));
        defi.addInvestor(address(alice));
        defi.addInvestor(address(chloe));
        vm.prank(address(alice));
        // emit Transfer(_from: DeFi1: [0xCe71065D4017F316EC606Fe4422e11eB2c47c246], 
        //_to: User: [0x185a4dc360CE69bDCceE33b3784B0282f7961aea], _value: 0)
        defi.claimTokens();
        token.balanceOf(address(alice));
    }

    function testCorrectPayoutAmount() public {

    }

    function testAddingManyInvestors() public {

    }

    function testAddingManyInvestorsAndClaiming() public {

    }

}
