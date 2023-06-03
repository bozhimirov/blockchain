// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Crowdfunding is ERC20, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private distributionId;

    // Data structures
    enum State {
        Fundraising,
        Expired,
        Successful
    }

    struct Distributions {
        uint256 distributionId;
        uint256 timeStamp;
        uint256 amount;
    }

    struct Contributions {
        address user;
        uint256 amount;
        uint256[] distributions;
    }

    // State variables
    uint256 public id;
    string public fundingName;
    uint256 public startTime;
    string public metadata;
    uint256 public fundingGoal; // required to reach at least this much, else everyone gets refund

    Distributions[] public distributions; // An array of 'Distributions' structs

    bool public fundingReached;
    uint256 public balance;
    uint256 public duration;
    mapping(uint256 => mapping(address => uint256)) public withdrawals;
    mapping(address => uint) public contributions;
    address creator;

    //mapping (address => uint[]) public transactions;

    constructor(
        uint256 _id,
        string memory _name,
        string memory _metadata,
        uint256 _fundingGoal,
        uint256 _duration,
        address _creator
    ) ERC20("_name", "") {
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_metadata).length > 0, "Description required");
        require(_fundingGoal != 0, "goal must be > 0");
        require(_duration != 0, "duration must be > 0");

        id = _id;
        fundingName = _name;
        startTime = block.timestamp;
        metadata = _metadata;
        duration = _duration;
        fundingGoal = _fundingGoal;
        transferOwnership(_creator);
        creator = _creator;
        // _mint(address(this), _fundingGoal);
    }

    function mint(uint256 amounts) private {
        _mint(msg.sender, amounts);
    }

    // Event that will be emitted whenever funding will be received
    event FundingReceived(
        address indexed contributor,
        string fundingName,
        uint256 amount,
        uint256 currentTotal,
        uint256 fundingGoal
    );
    // Event that will be emitted whenever the project starter has received the funds
    event RewardDistributed(address indexed creator);
    event CrowdfundingResult(bool, address indexed creator, uint256 amount);

    event ContributorRefunded(address indexed contributor, uint256 amount);
    event ContributorClaimedReward(address indexed contributor, uint256 amount);
    event Track(
        string indexed _function,
        address sender,
        uint256 value,
        bytes data
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
        require(contributions[msg.sender] > 0, "not a contributor");
        _;
    }

    /** @dev Function to fund a certain project.
     */
    function contribute() external payable notCreator {
        require(block.timestamp < startTime + duration, "expired");
        // require(msg.sender != creator, "creator must not contribute");
        require(msg.value > 0, "Value > 0");
        require(
            address(this).balance < (fundingGoal + 1),
            "Exceeding funding goal"
        );

        contributions[msg.sender] += msg.value;
        balance += msg.value;

        emit FundingReceived(
            msg.sender,
            fundingName,
            msg.value,
            fundingGoal - address(this).balance,
            fundingGoal
        );
        // mint(msg.value);
    }

    /** @dev Function to change the project state depending on conditions.
     */
    function checkIfFundingCompleteOrExpired()
        public
        view
        returns (string memory)
    {
        if (address(this).balance == fundingGoal) {
            // emit CrowdfundingResult(true, this.creator, address(this).balance);
            return "successful";
        } else if (block.timestamp > startTime + duration) {
            // emit CrowdfundingResult(false, this.creator, address(this).balance);
            return "expired";
        } else {
            return "fundraising";
        }
    }

    /** @dev Function to give the received funds to project starter.
     */
    function payOut() external isCreator onlyOwner {
        require(msg.sender == creator);
        require(block.timestamp > startTime + duration, "still crowdfunding");
        require(
            address(this).balance == fundingGoal,
            "crowdfunding not successful"
        );
        require(fundingReached == false, "goal not reached");
        uint256 totalRaised = address(this).balance;
        balance = 0;
        fundingReached = true;

        (bool success, ) = payable(owner()).call{value: totalRaised}("");
        require(
            success,
            "Address: unable to send value, recepient may have reverted"
        );
    }

    /** @dev Function to retrieve donated amount when a project expires.
     */
    function getRefund() external payable onlyContributor {
        require(balance < fundingGoal, "Funding goal reached");
        require(block.timestamp > startTime + duration, "still crowdfunding");

        uint256 amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;
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
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            string memory
        )
    {
        string memory state = checkIfFundingCompleteOrExpired();
        return (
            creator,
            msg.sender,
            fundingName,
            metadata,
            address(this).balance,
            fundingGoal,
            state
        );
    }

    function rewardDistribution() external payable isCreator {
        require(msg.value > 0, "Amount must be > 0");
        require(block.timestamp > startTime + duration, "still crowdfunding");
        require(fundingReached == true, "cannot distribute rewards");
        // require(msg.sender == creator);
        uint256 currentDistributionId = distributionId.current();
        distributionId.increment();
        distributions.push(
            Distributions({
                distributionId: currentDistributionId,
                timeStamp: block.timestamp,
                amount: msg.value
            })
        );

        emit RewardDistributed(msg.sender);
    }

    function getUnclaimedDistribution(
        uint numberOfDistribution
    ) external isCreator onlyOwner {
        require(fundingReached == true, "cannot distribute rewards");
        require(
            distributions.length < numberOfDistribution + 1,
            "no such distribution"
        );
        require(
            distributions[numberOfDistribution].timeStamp + 365 * 1 days >
                block.timestamp,
            "wait for a year before get unclaimed"
        );
        uint256 unclaimedAmount = distributions[numberOfDistribution].amount;
        distributions[numberOfDistribution].amount = 0;

        (bool success, ) = payable(owner()).call{value: unclaimedAmount}("");
        require(
            success,
            "Address: unable to send value, recepient may have reverted"
        );
    }

    function withdrawDistributions(
        uint256 numberOfDistribution
    ) external onlyContributor {
        require(
            distributions[numberOfDistribution].timeStamp + 31535999 >
                block.timestamp,
            "claim expired"
        );
        uint256 contribution = contributions[msg.sender];
        uint256 contributorReward;
        uint256 contributionPercentage;
        if (distributions[numberOfDistribution].amount > 0) {
            contributionPercentage = contribution.mul(100).div(fundingGoal);

            contributorReward = (
                distributions[numberOfDistribution]
                    .amount
                    .mul(contributionPercentage)
                    .div(100)
            );
        } else {
            contributorReward = 0;
        }
        withdrawals[numberOfDistribution][msg.sender] = contributorReward;
        if (contributorReward > 0) {
            payable(msg.sender).transfer(contributorReward);
        }

        require(address(this).balance > 0, "no amount for distribution");

        // null withdrawals for user

        emit ContributorClaimedReward(msg.sender, numberOfDistribution);
    }

    fallback() external payable {
        emit Track("fallback()", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Track("receive()", msg.sender, msg.value, "");
    }
}
