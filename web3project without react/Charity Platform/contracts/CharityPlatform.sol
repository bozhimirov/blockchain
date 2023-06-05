// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "./NewCharity.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Contract for Creating PLatform where users can create donation campaigns
///@author Stanislav Bozhimirov
///@notice This is a basic contract for donation campaign creation

contract CharityPlatform {
    using Counters for Counters.Counter;

    Counters.Counter private charityId;
    ///@notice create struct of campaign details
    struct campaignDetails {
        uint256 id;
        string name;
        string description;
        uint256 fundingGoal;
        uint256 deadline;
    }
    /// @notice create mapping with campaign info with address to details of campaign
    mapping(address => campaignDetails) public campaignInfo;
    address[] public campaigns;

    event newCharityRaised(address indexed eventAddr);

    function createCampaign(
        string memory _name,
        string memory _metadata,
        uint256 _fundingGoal,
        uint256 _deadline,
        address _token
    ) external {
        uint256 newCharityId = charityId.current();
        charityId.increment();
        ///@notice create new Charity campaign
        Charity newCharity = new Charity(
            newCharityId,
            _name,
            _metadata,
            _fundingGoal,
            _deadline,
            msg.sender,
            _token
        );

        string memory name = _name;
        string memory description = _metadata;
        uint256 fundingGoal = _fundingGoal;
        uint256 deadline = _deadline;

        ///@notice set campaign details using our campaignDetails mapping
        campaignInfo[address(newCharity)].id = newCharityId;
        campaignInfo[address(newCharity)].name = name;
        campaignInfo[address(newCharity)].description = description;
        campaignInfo[address(newCharity)].fundingGoal = fundingGoal;
        campaignInfo[address(newCharity)].deadline = deadline;
        /// add address of the new campaign to campaigns list
        campaigns.push(address(newCharity));
        /// emit event when new campaign created
        emit newCharityRaised(address(newCharity));
    }

    /** @dev Function to get all projects' contract addresses.
     * @return A list of all projects' contract addreses
     */
    function returnAllProjects() external view returns (address[] memory) {
        return campaigns;
    }

    /** @dev Function to get  projects' contract info.
     * @return A tuple of  projects' contract info.
     */
    function returnInfoForProject(
        address campaign
    )
        external
        view
        returns (uint256, string memory, string memory, uint256, uint256)
    {
        return (
            campaignInfo[campaign].id,
            campaignInfo[campaign].name,
            campaignInfo[campaign].description,
            campaignInfo[campaign].fundingGoal,
            campaignInfo[campaign].deadline
        );
    }
}
