task("deploy", "print deployer (owner) and contract addresses").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const charityPlatform = await hre.ethers.getContractFactory(
      "CharityPlatform",
      deployer
    );
    const cp = await charityPlatform.deploy();
    await cp.deployed();

    console.log(
      `Charity Platform with owner ${deployer.address} deployed to address ${cp.address}`
    );
  }
);

task(
  "charityCreation",
  "print deployer (owner) and contract addresses"
).setAction(async (taskArgs, hre) => {
  const [deployer] = await hre.ethers.getSigners();

  const charityPlatform = await hre.ethers.getContractFactory(
    "CharityPlatform",
    deployer
  );
  const cp = await charityPlatform.deploy();
  await cp.deployed();

  await cp.createCampaign("TestName", "test desc", 100, 1720089809);

  const deployedCampaigns = await cp.returnAllProjects();
  const charityFactory = await hre.ethers.getContractFactory("CharityPlatform");
  const cf = charityFactory.attach(deployedCampaigns[0]);

  console.log(
    `Crowdfunding with owner ${deployer.address} deployed to ${cf.address}`
  );
});
