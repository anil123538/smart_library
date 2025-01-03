// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;
 contract crowdfund{

    mapping(address=> uint) public contributors;
    address public manager;
    uint public target;
    uint public deadline;
    uint public noofcontributors;
    uint public  mincontributions;
    uint public raisedamount;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noofvoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public  requests;
    uint public numRequest;

    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp + _deadline;
        mincontributions=100 wei;
        manager=msg.sender;

    }
    function sendeth() public payable {
        require(block.timestamp<= deadline,"The deadline has passed for this funding");
        require(msg.value < mincontributions,"You must pay minimum of 100 wei to participate");
        if(contributors[msg.sender]==0){
            noofcontributors++;

        }
        contributors[msg.sender]+=msg.value;
        raisedamount+=msg.value;
    }
    function getbalance()public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedamount<target,"You are not eligible to get refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;



    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can acess the function");
        _;
    }

    function createRequest(string memory _description,address payable  _recipient,uint _value)public onlyManager{
        Request storage newrequest=requests[numRequest];
        numRequest++;
        newrequest.description=_description;
        newrequest.recipient=_recipient;
        newrequest.value=_value;
        newrequest.completed=false;
        newrequest.noofvoters=0;
    }
    function voterequest(uint _requestNo)public {
        require(contributors[msg.sender]>0,"You must be the contributor to request for voting");
        Request storage thisrequest=requests[_requestNo];
        require(thisrequest.voters[msg.sender]==false,"You have already voted ");
        thisrequest.voters[msg.sender]=true;
        thisrequest.noofvoters++;
    }

    function makepayment(uint _requestNo)public onlyManager{
        require(raisedamount>=target);
        Request storage thisrequest=requests[_requestNo];
        require(thisrequest.completed=false,"The request has been already completed");
        require(thisrequest.noofvoters>noofcontributors/2,"Majority doesnot support for the request");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed=true;


    }
 }