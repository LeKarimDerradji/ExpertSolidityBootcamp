// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Scope {
    uint256 public count = 10;

    function increment(uint256 num) public {
        // Modify state of the count variable from within
        // the assembly segment
        assembly {
            sstore(num, count.slot)
            return(sload(count.slot), 32)
        }
    }
}
