// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./FundRaiser.sol"; 

contract Math {
    function sum(uint256 a, uint256 b) internal pure returns(uint256) {
        return a + b;        
    }
}


contract Voting is Math{

    struct Vote {
        address shareholder; 
        uint256 shares;
        uint256 timestamp;
    }

    FundRaiser fundraiser;
     
    uint256 public startTime;
    uint256 public endTime;
    Vote[] public votes;

    uint256 positive;
    uint256 negative; 

    event NewVote(address indexed shareholder, uint256 shares);

    constructor(uint256 start, uint256 end, address  _fundraiser) {
        require(start < end, "Invalid period");
        startTime = start;
        endTime = end;
        fundraiser = FundRaiser(_fundraiser);
    }

    function vote(bool position) external {

        (uint256 shares, ) = fundraiser.getShares(msg.sender);
        votes.push(
            Vote({
                shareholder: msg.sender,
                shares: shares, 
                timestamp: block.timestamp
            })
        );  
        if(position == true){
            positive = sum(positive, shares);
        } else {
            negative = sum(negative, shares);
        }
        
        
        emit NewVote(msg.sender, shares );
    }

}