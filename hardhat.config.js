require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      //
    },
    /*  mumbai: {
      url: "https://rpc-mumbai.maticvigil.com", // Mumbai RPC URL
      accounts: [process.env.PRIVATE_KEY_1, process.env.PRIVATE_KEY2], // Private keys
    }, */
  },
};
