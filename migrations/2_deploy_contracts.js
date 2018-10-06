const contracts = [
  artifacts.require("CryptoTicker.sol"),
  artifacts.require("RandomDatasource.sol"),
  artifacts.require("PortlandTemperature.sol")
]

module.exports = deployer => 
  contracts.map(contract => deployer.deploy(contract))
