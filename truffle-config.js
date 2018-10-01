const {mnemonic, infuraKey} = require('../infura/apikeys')
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
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/${infuraKey}`),
      network_id: 3,
      gas: 55e5, // Ropsten has a lower block limit than mainnet
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
// Another network with more advanced options...
// advanced: {
  // port: 8777,             // Custom port
  // network_id: 1342,       // Custom network
  // gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
  // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
  // from: <address>,        // Account to send txs from (default: accounts[0])
  // websockets: true        // Enable EventEmitter interface for web3 (default: false)
// },
