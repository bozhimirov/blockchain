// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "./NewCrowdFund.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CrowdFundingPlatform {
    using Counters for Counters.Counter;

    Counters.Counter private campaignId;

    address[] public crowdfundings;

    event newCrowdFundevent(address eventAddr);

    function createCrowdFund(
        string memory _name,
        string memory _metadata,
        uint256 _fundingGoal,
        uint256 _duration
    ) external {
        uint256 newCampaignId = campaignId.current();
        campaignId.increment();

        Crowdfunding newCrowdfunding = new Crowdfunding(
            newCampaignId,
            _name,
            _metadata,
            _duration,
            _fundingGoal
        );

        crowdfundings.push(address(newCrowdfunding));
        emit newCrowdFundevent(address(newCrowdfunding));
    }

    /** @dev Function to get all projects' contract addresses.
     * @return A list of all projects' contract addreses
     */
    function returnAllProjects() external view returns (address[] memory) {
        return crowdfundings;
    }
}
