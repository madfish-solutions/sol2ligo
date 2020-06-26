const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = 'gesture rather obey video awake genuine patient base soon parrot upset lounge';

module.exports = {
  networks: {
    development: {
      provider: new HDWalletProvider(mnemonic, 'http://localhost:7545', 0, 10),
      host: '127.0.0.1',
      port: 7545,
      network_id: 5777,
      gas: 6721975,
      gasPrice: 20000000000,
      confirmations: 0,
      timeoutBlocks: 50,
      skipDryRun: true,
    }
  },
  compilers: {
    solc: {
      version: '0.5.11',
    },
  }
};
