task("deploy", "deploys contract")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const MarketplaceFactory = await hre.ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const marketplace = await MarketplaceFactory.deploy();

    await marketplace.deployed();

    console.log(
      `Marketplace with owner ${deployer.address} deployed to ${marketplace.address}`
    );

    console.log(taskArgs.account);
  });

task("nft-creation", "create NFT")
  .addParam("marketplace", "The contract's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer, firstUser] = await hre.ethers.getSigners();
    const MarketplaceFactory = await hre.ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );

    // const marketplace = await MarketplaceFactory.attach(taskArgs.marketplace);
    // equals to
    const marketplace = new hre.ethers.Contract(
      taskArgs.marketplace,
      MarketplaceFactory.interface,
      deployer
    );

    const marketplaceFirstUser = marketplace.connect(firstUser);
    const tx = await marketplaceFirstUser.createNFT("treets");
    const receipt = await tx.wait();
    if (receipt.status == 0) {
      throw new Error("Transaction failed");
    }
    console.log(`NFT created form user: ${marketplaceFirstUser.address}`);
  });

task("claim", "claim profit")
  .addParam("marketplace", "The contract's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer, firstUser, secondUser] = await hre.ethers.getSigners();
    const MarketplaceFactory = await hre.ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );

    // const marketplace = await MarketplaceFactory.attach(taskArgs.marketplace);
    // equals to
    const marketplace = new hre.ethers.Contract(
      taskArgs.marketplace,
      MarketplaceFactory.interface,
      deployer
    );

    const tx = await marketplace.approve(taskArgs.marketplace, 0);
    const receipt = await tx.wait();
    if (receipt.status == 0) {
      throw new Error("Transaction failed");
    }
    console.log(`approved`);

    const tx2 = await marketplace.listNFTForSale(taskArgs.marketplace, 0, 1);
    const receipt2 = await tx2.wait();
    if (receipt2.status === 0) {
      throw new Error("Transaction 2 failed");
    }
    console.log(`NFT listed user${msg.sender}`);

    const tx3 = await marketplace.purchaseNFT(
      taskArgs.marketplace,
      0,
      deployer.address,
      { value: 1 }
    );
    const receipt3 = await tx3.wait();
    if (receipt3.status === 0) {
      throw new Error("Transaction 3 failed");
    }
    console.log(`NFT purchased from user${msg.sender}`);

    const tx4 = await marketplace.claimProfit();
    const receipt4 = await tx4.wait();
    if (receipt4.status === 0) {
      throw new Error("Transaction 4 failed");
    }
    console.log(`NFT profit claimed form user ${msg.sender}`);
  });
