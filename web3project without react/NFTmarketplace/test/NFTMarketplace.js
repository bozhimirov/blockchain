const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  let marketplaceFirstUser, deployer, firstUser, secondUser;

  this.beforeAll(async function () {
    [deployer, firstUser, secondUser] = await ethers.getSigners();
    const { marketplace } = await loadFixture(deployAndMint);
    marketplaceFirstUser = getFirstUserMarketplace(marketplace, firstUser);
  });

  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAndMint() {
    // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    // const ONE_GWEI = 1_000_000_000;

    // const lockedAmount = ONE_GWEI;
    // const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using t he first signer/account by default

    const MarketplaceFactory = await ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const marketplace = await MarketplaceFactory.deploy();

    const _marketplaceFirstUser = marketplace.connect(firstUser);

    await _marketplaceFirstUser.createNFT("tTest");

    return { marketplace, marketplaceFirstUser, deployer, firstUser };
  }

  async function list() {
    const { marketplace } = await loadFixture(deployAndMint);
    const price = ethers.utils.parseEther("1");
    await marketplaceFirstUser.approve(marketplace.address, 0);
    await marketplaceFirstUser.listNFTForSale(marketplace.address, 0, price);

    return { marketplace };
  }

  describe("Listing", function () {
    it("Should revert if price == 0", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      // console.log("here");
      // expect(false).to.be.true; only one expect in test case

      await expect(
        marketplace.listNFTForSale(marketplace.address, 0, 0)
      ).to.be.revertedWith("price must be greater than 0");
    });

    it("Should revert if already listed", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      const price = ethers.utils.parseEther("1");

      await marketplaceFirstUser.approve(marketplace.address, 0);

      await marketplaceFirstUser.listNFTForSale(marketplace.address, 0, price);

      await expect(
        marketplaceFirstUser.listNFTForSale(marketplace.address, 0, price)
      ).to.be.revertedWith("NFT is already listed for sale");
    });

    it("Should succeed", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      const price = ethers.utils.parseEther("1");

      await marketplaceFirstUser.approve(marketplace.address, 0);

      await expect(
        marketplaceFirstUser.listNFTForSale(marketplace.address, 0, price)
      )
        .to.emit(marketplaceFirstUser, "NFTListed")
        .withArgs(marketplace.address, 0, price);
    });

    it("Should change the owner of nft", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      const price = ethers.utils.parseEther("1");

      await marketplaceFirstUser.approve(marketplace.address, 0);

      await marketplaceFirstUser.listNFTForSale(marketplace.address, 0, price);

      expect(await marketplace.ownerOf(0)).to.equal(marketplace.address);
    });
  });

  describe("Purchase", function () {
    it("Should revert when not listed", async function () {
      const { marketplace } = await loadFixture(deployAndMint);

      await expect(
        marketplace.purchaseNFT(marketplace.address, 0, secondUser.address)
      ).to.be.revertedWith("NFT is not listed for sale");
    });

    it("Should revert when value is less than price", async function () {
      const wrongPrice = ethers.utils.parseEther("0.1");
      const { marketplace } = await loadFixture(list);

      await expect(
        marketplace.purchaseNFT(marketplace.address, 0, secondUser.address, {
          value: wrongPrice,
        })
      ).to.be.revertedWith("Incorrect price");
    });

    it("Should succeed", async function () {
      const { marketplace } = await loadFixture(list);
      const price = ethers.utils.parseEther("1");

      await marketplace.purchaseNFT(
        marketplace.address,
        0,
        secondUser.address,
        {
          value: price,
        }
      );

      expect(
        (await marketplace.nftSales(marketplace.address, 0)).price
      ).to.equal(0);
      expect(await marketplace.ownerOf(0)).to.equal(secondUser.address);
    });

    describe("claim", async function () {
      it("Should succeed", async function () {
        const { marketplace } = await loadFixture(list);
        const price = ethers.utils.parseEther("1");

        const marketplaceFirstUser = marketplace.connect(firstUser);
        const tx3 = await marketplaceFirstUser.purchaseNFT(
          marketplace.address,
          0,
          firstUser.address,
          {
            value: price,
          }
        );
        const tx4 = await marketplaceFirstUser.claimProfit();
        const receipt4 = await tx4.wait();
        if (receipt4.status == 0) {
          throw new Error("Transaction 4 failed");
        }
      });
    });
  });
});
function getFirstUserMarketplace(marketplace, firstUser) {
  return marketplace.connect(firstUser);
}
