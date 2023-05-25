const { task } = require("hardhat/config");

// task("accounts", "prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();
//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

task("accounts", "prints the list of accounts")
  .addParam("acc", "account number")
  .setAction(async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
    // for (const account of accounts) {
    //   console.log(account.address);
    // }

    for (let i = 0; i < Number(taskArgs.acc); i++) {
      console.log(accounts[i].address);
    }
  });
