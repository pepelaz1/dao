//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Test {
    function sample() external payable {
        console.log(msg.value);
    }
}