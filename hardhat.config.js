require('dotenv').config();
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
// require("@nomiclabs/hardhat-truffle5");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545",
    },
    hardhat: {
      forking: {
        url: process.env.ALCHEMY_MAINNET_RPC_URL
      },
    },
    localtwo: {
      url: "http://127.0.0.1:8545"
    }
  },
  solidity: "0.7.5",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000
    }
  },
  mocha: {
    timeout: 600000
  }
};

