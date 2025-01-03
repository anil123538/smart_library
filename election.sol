// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract election{
    address public manager;
    struct candidate{
        string name;
        uint votecount;
    }
    candidate[] public candidates;
    mapping(address=>bool) public voters;
    uint public deadline;

    constructor(uint _deadline){
        manager=msg.sender;
        deadline=block.timestamp +_deadline;
    }
    modifier OnlyManager(){
        require(msg.sender==manager,"you cant acess to this");
        _;
    }
    function addcandidate(string memory _name)public OnlyManager{
        require(block.timestamp<=deadline,"deadline is finished");
        candidates.push(candidate(_name,0));


    }
    function vote(uint _candidateindex)public{
        require(block.timestamp<=deadline,"your voting time is expired");
        require(!voters[msg.sender],"you have already voted");
        require(_candidateindex<candidates.length,"No candidates to vote");
        voters[msg.sender]=true;
        candidates[_candidateindex].votecount++;


    }
    function getvotecount(uint _candidateindex)public view returns(uint){
        require(_candidateindex<candidates.length,"No candidate available");
        return candidates[_candidateindex].votecount;
    }

    function getname(uint _candidateindex)public view returns(string memory){
        require(_candidateindex<candidates.length,"No candidates available");
        return candidates[_candidateindex].name;

    }
}