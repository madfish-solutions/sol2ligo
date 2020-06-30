var contract = artifacts.require("Migrations")

module.exports = function(deployer) {
  deployer.deploy(contract);
}