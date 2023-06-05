const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("CharityPlatform", function () {
  let deployer, firstUser, secondUser, thirdUser;

  this.beforeAll(async function () {
    [deployer, firstUser, secondUser, thirdUser] = await ethers.getSigners();
  });

  async function deployPlatformAndCharity() {
    const CharityFactory = await ethers.getContractFactory(
      "CharityPlatform",
      deployer
    );
    const platform = await CharityFactory.connect(deployer).deploy();

    await platform.deployed();

    const platformContracts = CharityFactory.attach(platform.address);

    const newCharity = await platform
      .connect(deployer)
      .createCampaign("name", "data", 2, 1717503415);
    await newCharity.wait();

    const newCharityAddress = (await platformContracts.returnAllProjects())[0];
    const newCharityFactory = await ethers.getContractFactory(
      "Charity",
      deployer
    );
    const NewCharity = newCharityFactory
      .connect(deployer)
      .attach(newCharityAddress);
    return { NewCharity, newCharityAddress };
  }

  describe("Donation", function () {
    it("Reverts if sender is creator", async function () {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      await expect(
        NewCharity.connect(deployer).donate(newCharityAddress, { value: 1 })
      ).to.be.revertedWith("user is owner");
    });

    it("Reverts if campaign is not active", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );

      await network.provider.send("evm_increaseTime", [1717503500]);
      await network.provider.send("evm_mine");

      await expect(
        NewCharity.connect(firstUser).donate(newCharityAddress, { value: 1 })
      ).to.be.revertedWith("expired");
    });

    it("Reverts if value is 0", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );

      await expect(
        NewCharity.connect(firstUser).donate(newCharityAddress, { value: 0 })
      ).to.be.revertedWith("Value > 0");
    });

    it("Reverts if value is greater than goal", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );

      await expect(
        NewCharity.connect(firstUser).donate(newCharityAddress, { value: 10 })
      ).to.be.revertedWith("Exceeding funding goal");
    });

    it("Reverts if wrong address", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const wrongAddress = "0xd9145cce52d386f254917e481eb44e9943f39138";

      await expect(
        NewCharity.connect(firstUser).donate(wrongAddress, { value: 1 })
      ).to.be.revertedWith("connected to wrong campaign");
    });

    it("Donation success", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });

      const balance = await NewCharity.balance();

      expect(balance).to.equal(donationValue);
    });

    it("Refund contribution emits Event", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });
      await expect(
        NewCharity.connect(firstUser).donate(newCharityAddress, {
          value: donationValue,
        })
      )
        .to.emit(NewCharity, "FundingReceived")
        .withArgs(
          firstUser.address,
          NewCharity.name,
          donationValue
          // NewCharity.fundingGoal,
          // NewCharity.fundingGoal - (await address(NewCharity).balance)
        );
    });
  });

  describe("Successful Campaign Funds Release", function () {
    it("Reverts if sender is not creator", async function () {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });
      NewCharity.connect(secondUser).donate(newCharityAddress, {
        value: donationValue,
      });
      await expect(
        NewCharity.connect(firstUser).payOut(
          newCharityAddress,
          deployer.address
        )
      ).to.be.revertedWith("user is not creator");
    });

    it("Reverts if sender is not owner of campaign", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });
      NewCharity.connect(secondUser).donate(newCharityAddress, {
        value: donationValue,
      });

      const wrongAddress = "0xd9145cce52d386f254917e481eb44e9943f39138";
      await expect(
        NewCharity.connect(deployer).payOut(wrongAddress, deployer.address)
      ).to.be.revertedWith("connected to wrong campaign");
    });

    it("Reverts if campaign not successful", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });

      await network.provider.send("evm_increaseTime", [1717503500]);
      await network.provider.send("evm_mine");

      await expect(
        NewCharity.connect(deployer).payOut(newCharityAddress, deployer.address)
      ).to.be.revertedWith("campaign not successful");
    });

    it("payout success", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });
      NewCharity.connect(secondUser).donate(newCharityAddress, {
        value: donationValue,
      });

      const oldBalance = await NewCharity.balance();
      NewCharity.connect(deployer).payOut(newCharityAddress, deployer.address);

      const balance = await NewCharity.balance();

      expect(balance).to.equal("0");
      expect(oldBalance).to.equal(await NewCharity.fundingGoal());
    });

    it("payout emits Event", async () => {
      const { NewCharity, newCharityAddress } = await loadFixture(
        deployPlatformAndCharity
      );
      const donationValue = 1;
      NewCharity.connect(firstUser).donate(newCharityAddress, {
        value: donationValue,
      });
      NewCharity.connect(secondUser).donate(newCharityAddress, {
        value: donationValue,
      });

      const totalRaised = await NewCharity.balance();

      await expect(
        NewCharity.connect(deployer).payOut(newCharityAddress, deployer.address)
      )
        .to.emit(NewCharity, "CreatorTransferedDonations")
        .withArgs(deployer.address, totalRaised, deployer.address);
    });
  });
});
