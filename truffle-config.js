const {mnemonic, infuraKey} = require('./infura-key')
const HDWalletProvider = require('truffle-hdwallet-provider')
  /**
   * Usage:
   * 
   * $ truffle test --network <network-name>
   */
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      websockets: true
    },
    kovan: {
      provider: () => new HDWalletProvider(mnemonic, `https://kovan.infura.io/${infuraKey}`),
      network_id: 42,
      gas: 8e6, 
      gasPrice: 20e9
    }
  },
  compilers: {
    solc: {
      version: "0.4.25",
      settings: {
        optimizer: {
          enabled: true
        }
      }
    }
  }
}