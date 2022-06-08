//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Erc20Token.sol";

contract Dao {
    Erc20Token private immutable token;

    address private immutable chairman;

    uint256 private immutable minQuorum;

    uint256 private immutable duration;

    mapping(address => uint256) private deposits;

    uint256 private proposalsFinished;
    
    mapping(address => uint256) private voted;

    struct Proposal {
        address targetContract;
        bytes data;
        uint256 amount;
        uint256 start;
        string desc;
    }

    Proposal[] private proposals;

    constructor(address _chairman, address _token, uint256 _minQuorum, uint256 _duration) {
        chairman = _chairman;
        token = Erc20Token(_token);
        minQuorum = _minQuorum;
        duration = _duration;
    }

    function addProposal(address _targetContract, bytes memory _data, string memory _desc) public {
        require(msg.sender == chairman, "only chairman can add proposals");
        proposals.push(Proposal({
            targetContract: _targetContract,
            data: _data, 
            amount: 0,
            start: block.timestamp,
            desc: _desc
        }));
    }

    function deposit(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        deposits[msg.sender] += _amount;
    }

    function vote(uint256 _id) public {
        require(voted[msg.sender] & (1 << _id) == 0, "already voted");
        proposals[_id].amount += deposits[msg.sender];
        voted[msg.sender] |= (1 << _id);
    }

    function finishProposal(uint256 _id) public {
        require(block.timestamp >= proposals[_id].start + duration, "proposal is not over yet");
        if (proposals[_id].amount > minQuorum) {
            callTest(proposals[_id].targetContract, proposals[_id].data, proposals[_id].amount);
        }
        proposalsFinished |= (1 << _id);
    }

    function withdraw() external {
        require(voted[msg.sender] & proposalsFinished == voted[msg.sender], "not all proposals are over");
        token.transfer(msg.sender, deposits[msg.sender]);
        deposits[msg.sender] = 0;
    }

    function callTest(address _targetContract, bytes memory _signature, uint256 _amount) private {   
        (bool success, ) = _targetContract.call{value: _amount}(
                                _signature
                            );
        require(success, "error call func");
    }
}
