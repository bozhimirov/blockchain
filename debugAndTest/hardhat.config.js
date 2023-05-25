require("@nomicfoundation/hardhat-toolbox");

require("./tasks");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    sepolia: {
      url: "http://sepolia.infura.io/v3/<key>",
    },
    // accounts: [privateKey1, privateKey2, privateKey3]
  },
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
