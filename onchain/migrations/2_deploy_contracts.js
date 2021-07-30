const Reserve = artifacts.require("Reserve.sol");
module.exports = function(deployer) {
    deployer.deploy(Reserve);
};
