let HDWalletProvider = require("truffle-hdwallet-provider");

API_URL = "https://arb-rinkeby.g.alchemy.com/v2/P1JnmDbHqVDPLjTVu8UeA9AgHM4gXgpY";
API_URL2 = "https://arbitrum-rinkeby.infura.io/v3/0be985387ace4f62b0b0b7c5487a3853";
POLYGON_URL = "https://polygon-mumbai.g.alchemy.com/v2/epOefEZS5JxpbMbFaD7GYSxteAlPl4W-"
PRIVATE_KEY = "4d76a300a44aeda851f474b8bf664c72d4cb180acc60778ff2c84aceb6e7db65";
RINKEBY_URL = "https://eth-rinkeby.alchemyapi.io/v2/0B4lkTIdvHkAZuHgrbkpDHu98FySj8nc"
MNEMONIC = "saddle what reveal island shoe strategy liar solid play impact suffer type";
MNEMONIC2 = "uncle rather arctic fetch sleep ensure very silver consider clown device trend";

module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    aws: {
      host: "3.239.167.241",
      port: 8545,
      network_id: "*"
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC,RINKEBY_URL)
      },
      network_id: "*",
      gas:29900000,      //make sure this gas allocation isn't over 4M, which is the max
    },
  },
  compilers: {
    solc: {
      version: "0.7.6"
    }
  }
};
