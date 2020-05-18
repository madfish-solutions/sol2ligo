var contract = artifacts.require("Test_contract")

module.exports = function(deployer) {
  deployer.deploy(contract);
}