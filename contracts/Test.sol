//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Test {
    function sample(uint256 _value) public view {
        console.log(_value);
    }
}