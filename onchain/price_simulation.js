let ethers = require('ethers');
const contract = require("@truffle/contract");
const SimulationProxy = contract(require('./build/contracts/SimulationProxy.json'));
SimulationProxy.setProvider(web3.currentProvider);

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
    let account = (await web3.eth.getAccounts())[1];
    console.log(`Account loaded: ${account}`);
    web3.eth.defaultAccount = account;
    web3.eth.personal.unlockAccount(account);
    // Set up reserve.
    console.log("Setting up initial funding..");
    SimulationProxy.defaults({from: account});
    let instance = await SimulationProxy.deployed();
    console.log("==============================");
    let preTradePrice = await instance.getWETHPrice();
    console.log(`Pre trade eth price: ${preTradePrice.logs[0].args[0].toNumber() / 10**6}`)

    console.log("Injecting 3000 eth to iteraction proxy contract");
    await instance.injectETHToContract({value: ethers.utils.parseEther('3000.0')});
    let balance = await instance.getWETHBalance();
    console.log("Check eth balance: " + web3.utils.fromWei(new web3.utils.BN(balance)));

    console.log("Converting 1000 ETH to USDC...");
    await instance.convertWEthToUSDC(ethers.utils.parseEther('1000.0'));
    balance = await instance.getWETHBalance();
    console.log("Check eth balance: " + web3.utils.fromWei(new web3.utils.BN(balance)));
    let usdc_balance = await instance.getUSDCBalance();
    console.log(`Check USDC balance: ${(usdc_balance.toNumber()) / 10**6}`);
    console.log("=========== set up completed. now start simulation.");


    let swapSimulation = async () => {
        console.log("==============================");
        let preTradePrice = await instance.getWETHPrice();
        console.log(`Pre trade eth price: ${preTradePrice.logs[0].args[0].toNumber() / 10**6}`);
        let rand = 0;
        while (rand == 0) {
            rand = Math.floor(Math.random() * 101) - 50;
        }
        if (rand > 0) {
            console.log(`Buy ${rand} amount of WETH`);
            await instance.convertUSDCToWETHC(ethers.utils.parseEther(`${rand}`));
        } else {
            rand = Math.abs(rand);
            console.log(`Sell ${rand} amount of WETH`);
            await instance.convertWEthToUSDC(ethers.utils.parseEther(`${rand}`));
        }
        let postTradePrice = await instance.getWETHPrice();
        console.log(`Post trade eth price: ${await postTradePrice.logs[0].args[0].toNumber() / 10**6}`);
    };

    setAsyncInterval(swapSimulation, 12000);
};

