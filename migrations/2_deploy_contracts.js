const contracts = [
  // artifacts.require("RandomURLExample.sol"),
  // artifacts.require("RandomDataSourceExample.sol"),
  artifacts.require("RandomComputationExample.sol")
]

module.exports = deployer => {
  // const gasPrice  = 2e10
  // const amountETH = 1e17
  contracts.map(contract => deployer.deploy(contract))
}
