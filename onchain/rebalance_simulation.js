let ethers = require('ethers');
const contract = require("@truffle/contract");
const Reserve = contract(require('./build/contracts/Reserve.json'));
const Router = contract(require('./build/contracts/Router.json'));
Reserve.setProvider(web3.currentProvider);
Router.setProvider(web3.currentProvider);

const asyncIntervals = [];

const runAsyncInterval = async (cb, interval, intervalIndex) => {
    await cb();
    if (asyncIntervals[intervalIndex]) {
        setTimeout(() => runAsyncInterval(cb, interval, intervalIndex), interval);
    }
};

const setAsyncInterval = (cb, interval) => {
    if (cb && typeof cb === "function") {
        const intervalIndex = asyncIntervals.length;
        asyncIntervals.push(true);
        runAsyncInterval(cb, interval, intervalIndex);
        return intervalIndex;
    } else {
        throw new Error('Callback must be a function');
    }
};

const clearAsyncInterval = (intervalIndex) => {
    if (asyncIntervals[intervalIndex]) {
        asyncIntervals[intervalIndex] = false;
    }
};

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
    console.log("Injecting 20 eth to reserve");
    await instance.injectETHToContract({value: ethers.utils.parseEther('20.0')});
    let balance = await instance.getWETHBalance();
    console.log("Check eth balance: " + web3.utils.fromWei(new web3.utils.BN(balance)));
    console.log("Converting 1000 ETH to USDC...");
    await instance.convertWEthToUSDC(ethers.utils.parseEther('10.0'), 0);
    balance = await instance.getWETHBalance();
    console.log("Check eth balance: " + web3.utils.fromWei(new web3.utils.BN(balance)));
    let usdc_balance = await instance.getUSDCBalance();
    console.log(`Check USDC balance: ${(usdc_balance.toNumber()) / 10**6}`);


    let router = await Router.deployed();
    Router.defaults({from: account});

    let rebalanceSimulation = async () => {
        console.log("==============================");
        balance = await instance.getWETHBalance();
        balanceInNumber = await web3.utils.fromWei(new web3.utils.BN(balance))
        console.log(`Before rebalance, reserve balance: ${balanceInNumber}`);

        let rand = 0;
        while (rand == 0) {
            rand = Math.random() * 2 - 1;
        }

        console.log(`Rebalance delta is ${rand}`);
        await router.rebalance(ethers.utils.parseEther(`${rand}`), 1);

        balance = await instance.getWETHBalance();
        balanceInNumber = await web3.utils.fromWei(new web3.utils.BN(balance))
        console.log(`Post rebalance, reserve balance: ${balanceInNumber}`);
    };
    setAsyncInterval(rebalanceSimulation, 8000);
};

