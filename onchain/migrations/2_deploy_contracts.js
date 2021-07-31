const Reserve = artifacts.require("Reserve.sol");
const Router = artifacts.require("Router.sol");
const Verifier = artifacts.require("Verifier.sol");

module.exports = async function(deployer) {
    await deployer.deploy(Reserve);
    // Need to update the address once off chain is ready.
    await deployer.deploy(Verifier, Reserve.address)
    await deployer.link(Verifier, Router);
    await deployer.link(Reserve, Router);
    await deployer.deploy(Router, Reserve.address, Verifier.address);
};
