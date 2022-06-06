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
        address recepient;
        string data;
        uint256 amount;
        uint256 start;
        string desc;
    }

    Proposal[] proposals;

    constructor(address _chairman, address _token, uint256 _minQuorum, uint256 _duration) {
        chairman = _chairman;
        token = Erc20Token(_token);
        minQuorum = _minQuorum;
        duration = _duration;
    }

    function addProposal(address _recepient, string memory _data, string memory _desc) public {
        require(msg.sender == chairman, "only chairman can add proposals");
        proposals.push(Proposal({recepient: _recepient,data: _data, amount: 0, 
                               start: block.timestamp, desc: _desc}));
    }

    function deposit(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        deposits[msg.sender] += _amount;
    }

    function vote(uint256 _id) public {
        proposals[_id].amount += deposits[msg.sender];
    }

    function finishProposal(uint256 _id) public {
        require(block.timestamp >= proposals[_id].start + duration, "proposal is not over yet");
        if (proposals[_id].amount > minQuorum) {
            callTest(proposals[_id].recepient, proposals[_id].data, proposals[_id].amount);
        }
    }

    function callTest(address _recipient, string memory _signature, uint256 _amount) private {   
        (bool success, ) = _recipient.call(abi.encodeWithSignature(_signature,_amount));
        require(success, "error call func");
    }

}
