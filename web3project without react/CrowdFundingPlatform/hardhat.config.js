require("@nomicfoundation/hardhat-toolbox");
require("./tasks");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/E4AQD--63pu3qBGZFotdy7hEEhhj-348",
      accounts: [
        "c6706990f581deda2c46a057b738ab3d04cefebe1737ad3e479847131730f9ef",
      ],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "4YZTFDABGRX1BTHTNNTJISUBST6DA7XXJ4",
  },
};
