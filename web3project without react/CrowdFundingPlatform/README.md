Crowdfunding Platform
I tried to create a Solidity smart contract named "CrowdfundingPlatform" that implements a decentralized
crowdfunding platform.

1. Project Structure
   Create a Hardhat project as an environment for the involved contract.
2. Smart Contract Functionality
   ● Project Creation
   Allow users to create crowdfunding campaigns with a unique identifier, project name, description, funding
   goal (funds that must be collected), and duration.
   ● Contribution Mechanism
   Enable users to contribute funds in ETH to support projects they are interested in.
   Contributions can’t be more than the funding goal.
   ● Release of Funds
   The smart contract should hold contributed funds during the campaign duration and release them to the
   project creator upon reaching the funding goal.
   ● Refund
   Allow users to collect back the contributed funds in case the funding goal is not reached.
   ● Basic Reward Distribution
   Implement a reward mechanism where the contributed funds are distributed proportionally to the project
   backers based on their contribution amount.
   Example: The campaign creator distributes 100 ETH to the contract. Every supporter can claim their part of
   the reward which is proportional to their contribution. Let’s say I’ve contributed 20 ETH and the total funds
   collected are 200 ETH, then I own 10% of the crowdfunding pool. So, I will receive 10 ETH from the
   distributed reward. Then the campaign creator distributes 50 ETH, and I can claim 5 ETH. Every distribution
   must be claimed separately.
   ● The shares must be kept by inheriting the ERC-20 standard. It allows users to be able to transfer their
   shares (buy/sell). Every campaign must be a separate ERC-20 token.
3. General Requirements
   ● Smart Contracts is implemented using the Hardhat Development Environment
   ● Smart Contracts is written in Solidity.
   ● The application have Access Control functionality.
   ● Smart contracts is based on OpenZeppelin contracts.
   ● Unit tests for 100% of the Reward Distribution and Refund functionalities logic is implemented.
   ● Alchemy provider is used for interaction with the blockchain.
   ● Deployment task is implemented
   ● Interaction tasks are implemented for the Project Creation and Contribution mechanism
   functionalities
4. Other requirements
   ● Proper Licensing information is added
   ● Deployed and Verified the Smart Contracts on the Sepolia Ethereum Testnet network.
   ● Applied error handling and data validation to avoid crashes when invalid data is entered
   ● I tried to demonstrate use of programming concepts - Smart Contracts Security, Gas Optimization, and Design
   Patterns
