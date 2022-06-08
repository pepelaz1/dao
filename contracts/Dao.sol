//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Erc20Token.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Dao is AccessControl {
    bytes32 public constant CHAIRMAN_ROLE = keccak256("CHAIRMAN_ROLE");

    Erc20Token private immutable token;

    uint256 private immutable minQuorum;

    uint256 private immutable duration;

    mapping(address => uint256) private deposits;

    mapping(address => uint256) private lastProposals;
    
    mapping(address => mapping(uint256 => bool)) private voted;

    struct Proposal {
        address targetContract;
        bytes data;
        uint256 amount;
        uint256 start;
        string desc;
    }

    Proposal[] private proposals;

    constructor( address _token, uint256 _minQuorum, uint256 _duration) {
        token = Erc20Token(_token);
        minQuorum = _minQuorum;
        duration = _duration;
         _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addChairman(address _address) onlyRole(DEFAULT_ADMIN_ROLE) public {
        _grantRole(CHAIRMAN_ROLE, _address);
    }

    function addProposal(address _targetContract, bytes memory _data, string memory _desc) onlyRole(CHAIRMAN_ROLE)  public {
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
        require(voted[msg.sender][_id] == false, "already voted");
        proposals[_id].amount += deposits[msg.sender];
        voted[msg.sender][_id] = true;

        if (_id > lastProposals[msg.sender]) {
            lastProposals[msg.sender] = _id;
        }
    }

    function finishProposal(uint256 _id) public {
        require(block.timestamp >= proposals[_id].start + duration, "proposal is not over yet");
        if (proposals[_id].amount > minQuorum) {
            callSignature(proposals[_id].targetContract, proposals[_id].data);
        }
    }

    function withdraw() external {
        require(block.timestamp > proposals[lastProposals[msg.sender]].start + duration, "not all proposals are over");
        token.transfer(msg.sender, deposits[msg.sender]);
        deposits[msg.sender] = 0;
    }

    function callSignature(address _targetContract, bytes memory _signature) private {   
        (bool success, ) = _targetContract.call(_signature);
        require(success, "error call func");
    }
}
