//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Erc20Token.sol";

contract Dao {
   
    Erc20Token public immutable token;

    constructor(address _address) {
        token = Erc20Token(_address);
    }

    function addProposal() public {

    }

    function deposit() public {

    }

    function vote() public {
        
    }

    function finish() public {
        
    }
}
