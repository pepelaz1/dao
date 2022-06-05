//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Erc20Token.sol";

contract Dao {
    Erc20Token public immutable token;

    address public immutable chairman;

    uint256 public immutable minQuorum;

    uint256 public immutable duration;

    mapping(address => uint256) deposits;


    struct Proposal {
        string text;
        uint256 amount;
        uint256 start;
    }

    mapping(string => Proposal) proposals;


    constructor(address _chairman, address _token, uint256 _minQuorum, uint256 _duration) {
        chairman = _chairman;
        token = Erc20Token(_token);
        minQuorum = _minQuorum;
        duration = _duration;
    }

    function addProposal(string memory _text, string memory _desc) public {
        require(msg.sender == chairman, "only chairman can add proposals");
        proposals[_desc] = Proposal({text: _text, amount: 0, start: block.timestamp});
    }

    function deposit(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        deposits[msg.sender] += _amount;

    }

    function vote(string memory _desc) public {
        proposals[_desc].amount += deposits[msg.sender];
    }

    function finishProposal(string memory _desc) public {
        require(block.timestamp >= proposals[_desc].start + duration, "proposal is not over yet");
        console.log(proposals[_desc].amount);

    }
}
