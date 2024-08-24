require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.API_KEY}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
  }
  },
  etherscan: {
    apiKey: '1AT3KKRJAWAJSKGCMRW1HAN2T4EA9387B7', 
  },
};
