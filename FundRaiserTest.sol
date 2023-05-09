// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract FundRaiser {
    uint256 public totalShares;
    // mapping (address => mapping (address => uint)) public shares;
    mapping(address => uint256) public shares;

    address public owner;
    uint256 public number;

    constructor() {
        owner = msg.sender; 
    }

    // function kill() external {
    //     selfdestruct(payable(owner));
    // }



    enum Options {
        one,
        two,
        three
    }

    error Unauthorized(string reason);

    function addShares(address receiver, uint256 value) external payable {
        require(msg.sender == owner, "Not owner");
        

        totalShares += value;
        // shares[receiver][receiver] += amount;
        shares[receiver] += value;
        
        // if (msg.sender != owner) {
        //     revert Unauthorized("Not Owner");
        // }
    }

    function getShares(address investor) external view returns (uint256, uint256) {
        return (shares[investor], totalShares);
    }

    function whoAmI() public view returns (address) {
        return msg.sender;
    }

    function who() external view returns (address) {
        return address(this);
    }

    function isTrue() public pure returns (bool) {
        // bool here=true;
        // return here;

        uint256 first = 1;
        uint256 second = 2;
        return first != second;
    }

    function getEnum(Options option) external pure returns (Options) {
        return option;
    }

    function increase() external returns (uint256) {
        number++;
        return number;
    }

    function getEther() external pure returns (uint256){
        return 1 ether;
    }

    function getSeconds() external pure returns (uint256) {
        return 12 hours;
    }

    
}
