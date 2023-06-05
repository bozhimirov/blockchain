import { ethers } from "hardhat";

async function main() {
  const CharityPlatform = await ethers.getContractFactory("CharityPlatform");
  await CharityPlatform.deploy();

  await CharityPlatform.deployed();

  console.log(`Charity Platform deployed to ${CharityPlatform.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
