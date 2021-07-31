// local: ganache-cli --fork https://eth-mainnet.alchemyapi.io/v2/XRIpyKHCPhynuCvKgxpoVbnVmFsDQNLi -e 70000
// local: truffle console --network development
// aws: truffle console --network aws
// in truffle console, run this file. that's it.
// - truffle exec ./demo-reserve-setup.js

let ethers = require('ethers');
const contract = require("@truffle/contract");
const Reserve = contract(require('./build/contracts/Reserve.json'));
Reserve.setProvider(web3.currentProvider);

module.exports = async (callback) => {
    console.log("Setting up account..");
    // Unlock account
    let account = (await web3.eth.getAccounts())[0];
    console.log(`Account loaded: ${account}`);
    web3.eth.defaultAccount = account;
    web3.eth.personal.unlockAccount(account);
    // Set up reserve.
    console.log("Setting up reserve..");
    Reserve.defaults({from: account});
    let instance = await Reserve.deployed();
    console.log("Injecting 30000 eth to reserve");
    await instance.injectETHToContract({value: ethers.utils.parseEther('30000.0')});
    let balance = await instance.getWETHBalance();
    console.log("Check eth balance: " + web3.utils.fromWei(new web3.utils.BN(balance)));
    console.log("Converting 20000 ETH to USDC...");
    await instance.convertWEthToUSDC(ethers.utils.parseEther('20000.0'), 0);
    balance = await instance.getWETHBalance();
    console.log("Check eth balance: " + web3.utils.fromWei(new web3.utils.BN(balance)));
    console.log("Done.")
    let usdc_balance = await instance.getUSDCBalance();
    console.log(`Check USDC balance: ${(usdc_balance.toNumber()) / 10**6}`);
    callback();
};

