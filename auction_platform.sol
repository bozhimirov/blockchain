// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract AuctionPlatform {
    uint256 public ID;
    uint256 startTime;
    uint256 durationAuction;
        
    mapping(address => uint256) public availableToWithdrawal;

    struct AuctionID {
        uint256 id;
        address owner;
        uint256 start;
        uint256 duration;
        string name;
        string description;
        uint256 initialPrice;
        uint256 highestBid;
        bool isFinalized;
        address sender;
    }
    
    AuctionID[] public auctions;

    event NewAuction(
        uint256 id,
        uint256 starting,
        uint256 duration,
        string name,
        string details,
        uint256 price
    );

    event NewHighestBid(
        address user,
        uint256 highestBid
    );

    function createAuction(
        uint256 start,
        uint256 duration,
        string memory itemName,
        string memory itemDescription,
        uint256 startingPrice
    ) public {
        require(0 < duration, "Invalid period!");
        require(start > block.timestamp, "Start time must be in the future!");
        ID ++;
        auctions.push(
            AuctionID({
                id: ID,
                owner: msg.sender, 
                start: start,
                duration: duration,
                name: itemName,
                description: itemDescription,
                initialPrice: startingPrice,
                highestBid: startingPrice,
                isFinalized: false,
                sender: msg.sender
            })
        );  
        emit NewAuction( ID, start, duration, itemName, itemDescription, startingPrice);
    }

    modifier notOwner(uint256 auctionId) {
        address ownerAddress = auctions[auctionId].owner;
        address selfAddress = msg.sender;

        require(ownerAddress != selfAddress, "Owner cannot bid");
        _;
    }

    modifier onlyActiveAuction(uint256 auctionId) {
        uint endTime = auctions[auctionId].start + auctions[auctionId].duration;
        uint currentTime = block.timestamp;
        if (currentTime > endTime || currentTime < auctions[auctionId].start) {
            auctions[auctionId].isFinalized = true;
        } else {
            auctions[auctionId].isFinalized = false;
        }
        require(auctions[auctionId].isFinalized == false, "The auction is not active!");
        
        _; //here is func logic code after the check//
    }


    function placeBid(uint256 auctionId) public payable onlyActiveAuction(auctionId) notOwner(auctionId){
        uint lastHidhest = auctions[auctionId].highestBid;

        if (msg.value > lastHidhest) {
            auctions[auctionId].highestBid = msg.value;
            auctions[auctionId].sender = msg.sender;

            availableToWithdrawal[msg.sender] += msg.value ;
            
            emit NewHighestBid(msg.sender, msg.value);
        }
    }

    function finalizeBid(uint256 auctionId) public payable {
        uint endTime = auctions[auctionId].start + auctions[auctionId].duration;
        uint currentTime = block.timestamp;
        if (currentTime > endTime) {
            auctions[auctionId].isFinalized = true;
        } else {
            auctions[auctionId].isFinalized = false;
        }
        require(auctions[auctionId].isFinalized == true, "The auction is not finalized yet!");
        require(auctions[auctionId].highestBid != auctions[auctionId].initialPrice, "Nobody placed a bid!");
        uint bidToPay = auctions[auctionId].highestBid;
        address receiver = auctions[auctionId].owner;
        payable(receiver).transfer(bidToPay);

    }

    function withdraw() public payable {
        payable(msg.sender).transfer(availableToWithdrawal[msg.sender]);
    } 
    
    // function startTimeForNewAuction() external view returns (uint256){
    //     return (block.timestamp + 30);
    // }
    
    // function checkActive(uint256 auctionId) public returns (string memory){
    //     uint endTime = auctions[auctionId].start + auctions[auctionId].duration;
    //     uint currentTime = block.timestamp;
    //     if (currentTime > endTime || currentTime < auctions[auctionId].start) {
    //         auctions[auctionId].isFinalized = true;
    //         return "auction inactive";
    //     } else {
    //         auctions[auctionId].isFinalized = false;
    //         return "auction active";
    //     }
    // }

    // function getBalance(address user) public view returns (uint256){
    //     return address(user).balance;
    // }

    // function checkAuctions(uint256 id) public view returns(uint256, bool){
    //     return ( auctions[id].highestBid, auctions[id].isFinalized);

    // }

}
