const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("CrowdFundingPlatform", function () {
  let deployer, firstUser, secondUser, thirdUser;

  this.beforeAll(async function () {
    [deployer, firstUser, secondUser, thirdUser] = await ethers.getSigners();
  });

  async function deployPlatformAndCrowdfunding() {
    const PlatformFactory = await ethers.getContractFactory(
      "CrowdFundingPlatform",
      deployer
    );
    const platform = await PlatformFactory.connect(deployer).deploy();

    await platform.deployed();

    const platformContracts = PlatformFactory.attach(platform.address);

    const newCrowdfunding = await platform
      .connect(deployer)
      .createCrowdFund("name", "data", 2, 2);
    await newCrowdfunding.wait();

    const newCrowdFundingAddress = (
      await platformContracts.returnAllProjects()
    )[0];
    const NewCrowdfundFactory = await ethers.getContractFactory(
      "Crowdfunding",
      deployer
    );
    const newCrowdFund = NewCrowdfundFactory.connect(deployer).attach(
      newCrowdFundingAddress
    );
    return { newCrowdFund, newCrowdFundingAddress };
  }

  async function deployPlatformAndCrowdfundingFinished() {
    const PlatformFactory = await ethers.getContractFactory(
      "CrowdFundingPlatform",
      deployer
    );
    const platform = await PlatformFactory.connect(deployer).deploy();

    await platform.deployed();

    const platformContracts = PlatformFactory.connect(deployer).attach(
      platform.address
    );
    const duration = 10;
    const newCrowdfunding = await platform
      .connect(deployer)
      .createCrowdFund("name", "data", duration, 2);
    await newCrowdfunding.wait();

    const newCrowdFundingAddress = (
      await platformContracts.connect(deployer).returnAllProjects()
    )[0];
    const NewCrowdfundFactory = await ethers.getContractFactory(
      "Crowdfunding",
      deployer
    );
    const newCrowdFund = NewCrowdfundFactory.connect(deployer).attach(
      newCrowdFundingAddress
    );

    await newCrowdFund.connect(firstUser).contribute({ value: 1 });

    await newCrowdFund.connect(secondUser).contribute({ value: 1 });

    return { newCrowdFund, newCrowdFundingAddress, PlatformFactory };
  }

  describe("Refund", function () {
    it("Reverts if sender is not contributor", async function () {
      const { newCrowdFund } = await loadFixture(deployPlatformAndCrowdfunding);
      await expect(newCrowdFund.getRefund()).to.be.revertedWith(
        "not a contributor"
      );
    });

    it("Reverts if campaign is active", async () => {
      const { newCrowdFund, newCrowdFundingAddress } = await loadFixture(
        deployPlatformAndCrowdfunding
      );
      const balance = await ethers.provider.getBalance(newCrowdFundingAddress);
      await newCrowdFund.connect(firstUser).contribute({ value: 1 });

      await expect(
        newCrowdFund.connect(firstUser).getRefund()
      ).to.be.revertedWith("still crowdfunding");
    });

    it("Reverts if Funding goal reached", async () => {
      const { newCrowdFund } = await loadFixture(deployPlatformAndCrowdfunding);

      await newCrowdFund.connect(firstUser).contribute({ value: 2 });

      await expect(
        newCrowdFund.connect(firstUser).getRefund()
      ).to.be.revertedWith("Funding goal reached");
    });

    it("Refund success", async () => {
      const { newCrowdFund } = await loadFixture(deployPlatformAndCrowdfunding);

      const balance = ethers.utils.formatEther(await newCrowdFund.balance());
      await newCrowdFund.connect(firstUser).contribute({ value: 1 });
      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      await newCrowdFund.connect(firstUser).getRefund();
      const newBalance = ethers.utils.formatEther(await newCrowdFund.balance());

      expect(balance).to.equal(newBalance);
    });

    it("Refund contribution emits Event", async () => {
      const { newCrowdFund } = await loadFixture(deployPlatformAndCrowdfunding);

      const contribution = 1;
      await newCrowdFund.connect(firstUser).contribute({ value: contribution });
      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      await expect(newCrowdFund.connect(firstUser).getRefund())
        .to.emit(newCrowdFund, "ContributorRefunded")
        .withArgs(firstUser.address, contribution);
    });
  });

  describe("rewardDistribution", function () {
    it("Reverts if sender is not creator", async function () {
      const { newCrowdFund } = await loadFixture(
        deployPlatformAndCrowdfundingFinished
      );

      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      newCrowdFund.connect(deployer).payOut();
      await expect(
        newCrowdFund.connect(firstUser).rewardDistribution({ value: 10 })
      ).to.be.revertedWith("user is not creator");
    });

    it("Reverts if amount is 0", async () => {
      const { newCrowdFund, newCrowdFundingAddress, PlatformFactory } =
        await loadFixture(deployPlatformAndCrowdfundingFinished);
      const balance = ethers.utils.formatEther(await newCrowdFund.balance());

      newCrowdFund.connect(deployer).payOut();

      await expect(
        newCrowdFund.connect(deployer).rewardDistribution({ value: 0 })
      ).to.be.revertedWith("Amount must be > 0");
    });

    it("Success", async () => {
      const { newCrowdFund, newCrowdFundingAddress } = await loadFixture(
        deployPlatformAndCrowdfundingFinished
      );
      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");

      newCrowdFund.connect(deployer).payOut();
      const distribution = 10;
      await newCrowdFund.connect(deployer).rewardDistribution({ value: 10 });
      const balance = await ethers.provider.getBalance(newCrowdFundingAddress);

      expect(balance).to.equal(distribution);
    });

    it("rewardDistribution emits Event", async () => {
      const { newCrowdFund, newCrowdFundingAddress } = await loadFixture(
        deployPlatformAndCrowdfundingFinished
      );

      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      newCrowdFund.connect(deployer).payOut();

      const contribution = 10;
      await expect(newCrowdFund.rewardDistribution({ value: contribution }))
        .to.emit(newCrowdFund, "RewardDistributed")
        .withArgs(deployer.address);
    });
  });

  describe("withdrawDistribution", function () {
    it("Reverts if  not contributor", async function () {
      const { newCrowdFund } = await loadFixture(
        deployPlatformAndCrowdfundingFinished
      );

      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      newCrowdFund.connect(deployer).payOut();
      newCrowdFund.connect(deployer).rewardDistribution({ value: 10 });
      await expect(
        newCrowdFund.connect(thirdUser).withdrawDistributions(0)
      ).to.be.revertedWith("not a contributor");
    });

    it("Reverts if a year passed", async () => {
      const { newCrowdFund, newCrowdFundingAddress, PlatformFactory } =
        await loadFixture(deployPlatformAndCrowdfundingFinished);

      numberOfDistribution = 0;
      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      await newCrowdFund.connect(deployer).payOut();
      await newCrowdFund.connect(deployer).rewardDistribution({ value: 10 });
      await network.provider.send("evm_increaseTime", [31536500]);
      await network.provider.send("evm_mine");
      await expect(
        newCrowdFund
          .connect(firstUser)
          .withdrawDistributions(numberOfDistribution)
      ).to.be.revertedWith("claim expired");
    });

    it("Success", async () => {
      const { newCrowdFund, newCrowdFundingAddress } = await loadFixture(
        deployPlatformAndCrowdfundingFinished
      );
      expectedDistributedAmount = 5;
      numberOfDistribution = 0;
      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      await newCrowdFund.connect(deployer).payOut();
      await newCrowdFund.connect(deployer).rewardDistribution({ value: 10 });
      await newCrowdFund
        .connect(firstUser)
        .withdrawDistributions(numberOfDistribution);
      const balance = await ethers.provider.getBalance(newCrowdFundingAddress);

      expect(balance).to.equal(expectedDistributedAmount);
    });

    it("Refund contribution emits Event", async () => {
      const { newCrowdFund, newCrowdFundingAddress } = await loadFixture(
        deployPlatformAndCrowdfundingFinished
      );
      expectedDistributedAmount = 5;
      numberOfDistribution = 0;

      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");
      newCrowdFund.connect(deployer).payOut();
      newCrowdFund.connect(deployer).rewardDistribution({ value: 10 });
      await expect(newCrowdFund.connect(firstUser).withdrawDistributions(0))
        .to.emit(newCrowdFund, "ContributorClaimedReward")
        .withArgs(firstUser.address, numberOfDistribution);
    });
  });
});
