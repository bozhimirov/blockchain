// import { task } from "hardhat/config";

task("deploy", "print deployer (owner) and contract addresses").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const crowdFundingPlatform = await hre.ethers.getContractFactory(
      "CrowdFundingPlatform",
      deployer
    );
    const cfp = await crowdFundingPlatform.deploy();
    await cfp.deployed();

    console.log(
      `Crowd Funding Platform with owner ${deployer.address} deployed to address ${cfp.address}`
    );
  }
);

task("crowdfunding", "print deployer (owner) and contract addresses").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const crowdFundingPlatform = await hre.ethers.getContractFactory(
      "CrowdFundingPlatform",
      deployer
    );
    const cfp = await crowdFundingPlatform.deploy();
    await cfp.deployed();

    await cfp.createCrowdFund("Test1", "test desc", 100, 120);

    const deployedCampaigns = await cfp.returnAllProjects();
    const crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
    const cf = crowdfunding.attach(deployedCampaigns[0]);

    console.log(
      `Crowdfunding with owner ${deployer.address} deployed to ${cf.address}`
    );
  }
);

task("contribute", "contributor, contract addresses and contribution amount")
  .addParam("crowdfunding", "contract address")
  .addParam("amount", "amount to contribute")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const crowdFunding = await hre.ethers.getContractFactory(
      "Crowdfunding",
      deployer
    );
    const cf = crowdFunding.attach(taskArgs.crowdfunding);

    await cf.contribute({ value: taskArgs.amount });

    console.log(
      `User ${deployer.address} contributed ${taskArgs.amount} to Crowdfunding ${cf.address}`
    );
  });
