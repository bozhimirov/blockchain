// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "./Token.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Contract for Creating New Charity campaign
///@author Stanislav Bozhimirov
///@notice This is a basic contract for charity campaign

contract Charity is ERC20, Ownable {
    ///@dev useing SafeMath for calculating percentages
    using SafeMath for uint256;
    ///@ useing Counters for incrementing numbers
    using Counters for Counters.Counter;

    Counters.Counter private distributionId;

    /// Data structures
    enum State {
        Fundraising,
        Expired,
        Successful
    }

    /// State variables

    DonationToken token; ///declare the contract variable

    uint256 public id;
    string public fundingName;
    uint256 public startTime;
    string public metadata;
    uint256 public fundingGoal; // required to reach at least this much, else everyone gets refund
    uint256 public balance;
    uint256 public deadline;
    mapping(address => uint) public donations; /// mapping for donations addresses to amount they have donated
    address creator;
    uint256 totalRaised;
    /// token uri with predefined json info uploaded to api
    ///@dev can be replaced with different json details
    string tokenURI =
        "https://api.jsonbin.io/v3/b/647ced758e4aa6225ea93684?meta=false";

    constructor(
        uint256 _id,
        string memory _name,
        string memory _metadata,
        uint256 _fundingGoal,
        uint256 _deadline,
        address _creator,
        address _token
    ) ERC20("_name", "") {
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_metadata).length > 0, "Description required");
        require(_fundingGoal != 0, "goal must be > 0");
        require(_deadline != 0, "deadline must be in the future");
        /// when constructor is called make instance of token
        token = DonationToken(_token);
        id = _id;
        fundingName = _name;
        metadata = _metadata;
        deadline = _deadline;
        fundingGoal = _fundingGoal;
        ///transfering ownership to user that calls the function
        ///@param set authomatically with msg.sender argument when function is called
        transferOwnership(_creator);
        creator = _creator;
    }

    /// Event that will be emitted whenever funding will be received
    event FundingReceived(
        address indexed contributor,
        string fundingName,
        uint256 amount
        // uint256 currentTotal,
        // uint256 fundingGoal
    );
    /// Event that will be emitted when contriburot is refunded
    event ContributorRefunded(address indexed contributor, uint256 amount);
    /// Event that will be emitted when owner takes the collected donations
    event CreatorTransferedDonations(
        address indexed creator,
        uint256 amount,
        address receiver
    );

    // Modifier to check if the function caller is the project creator
    modifier isCreator() {
        require(msg.sender == owner(), "user is not creator");
        _;
    }

    // Modifier to check if the function caller is the project creator
    modifier notCreator() {
        require(msg.sender != owner(), "user is owner");
        _;
    }

    // Modifier to check if the function caller has been contributor
    modifier onlyContributor() {
        require(donations[msg.sender] > 0, "not a contributor");
        _;
    }

    /** @dev Function to fund a certain project
     */
    function donate(address campaign) external payable notCreator {
        require(block.timestamp < deadline, "expired");
        require(msg.value > 0, "Value > 0");
        require(address(this) == campaign, "connected to wrong campaign");
        require(
            address(this).balance < (fundingGoal + 1),
            "Exceeding funding goal"
        );

        donations[msg.sender] += msg.value;
        balance += msg.value;
        /// mint one token after successful donation
        token.safeMint(msg.sender, tokenURI);

        emit FundingReceived(msg.sender, fundingName, msg.value);
    }

    /** @dev Function to change the project state depending on conditions.
     */
    function checkIfCampaignCompleteOrExpired()
        internal
        view
        returns (string memory)
    {
        if (address(this).balance == fundingGoal) {
            // emit CrowdfundingResult(true, this.creator, address(this).balance);
            return "successful";
        } else if (block.timestamp > deadline) {
            // emit CrowdfundingResult(false, this.creator, address(this).balance);
            return "expired";
        } else {
            return "can donate";
        }
    }

    /** @dev Function to give the received funds to project starter.
     */
    function payOut(
        address campaign,
        address whereToTransferFunds
    ) external isCreator onlyOwner {
        require(address(this) == campaign, "connected to wrong campaign");
        require(
            address(campaign).balance == fundingGoal,
            "campaign not successful"
        );

        totalRaised = address(campaign).balance;
        balance = 0;

        (bool success, ) = payable(whereToTransferFunds).call{
            value: totalRaised
        }("");
        require(
            success,
            "Address: unable to send value, recepient may have reverted"
        );
        emit CreatorTransferedDonations(
            msg.sender,
            totalRaised,
            whereToTransferFunds
        );
    }

    /** @dev Function to retrieve donated amount when a project expires.
     */
    function Refund() external payable onlyContributor {
        require(balance < fundingGoal, "Funding goal reached");
        require(block.timestamp > deadline, "still collecting donations");

        uint256 amountToRefund = donations[msg.sender];
        donations[msg.sender] = 0;
        balance -= amountToRefund;

        (bool success, ) = payable(msg.sender).call{value: amountToRefund}("");
        require(
            success,
            "Address: unable to send value, recepient may have reverted"
        );

        emit ContributorRefunded(msg.sender, amountToRefund);
    }

    /** @dev Function to get specific information about the project.
     * @return Returns all the project's details
     */
    function getDetails()
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            string memory,
            uint256
        )
    {
        string memory state = checkIfCampaignCompleteOrExpired();
        return (
            creator,
            fundingName,
            metadata,
            address(this).balance,
            fundingGoal,
            state,
            totalRaised
        );
    }

    // fallback() external payable {
    //     emit Track("fallback()", msg.sender, msg.value, msg.data);
    // }

    // receive() external payable {
    //     emit Track("receive()", msg.sender, msg.value, "");
    // }
}
