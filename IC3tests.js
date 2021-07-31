const axios = require('axios')

const HedgingContract = require("./onchain/build/contracts/Reserve.json")
const Router = require("./onchain/build/contracts/Router.json")
const Web3 = require('web3')

// connect to network
const url = '3.239.167.241'
const port = 8545
const web3 = new Web3(`ws://${url}:${port}/`) // https? not connecting

// connect to web3 provider, use default account for signing
async function init() {
    console.log("init is running")
    const networkId =  await web3.eth.net.getId() 

    // const new Web3.HttpProvider()

    // instantiate local versions of hedging contract

    const HCDeployedNetwork = HedgingContract.networks[networkId]
    const hedgingcontract = new web3.eth.Contract(
        HedgingContract.abi,
        HCDeployedNetwork.address
    )

    console.log(['hedging contract address:', hedgingcontract])

    const RouterDeployedNetwork = Router.networks[networkId]
    const router = new web3.eth.Contract(
        Router.abi,
        RouterDeployedNetwork.address
    )

    console.log(['router address:', RouterDeployedNetwork.address])

}

init()

// simulate sequence of API calls // call API with price request (and just assume user accepts any price) (can also send user address)
async function getOptionPrice(expiration, currStockPrice, strike, sigma) {
    let response
    try {
        response = await axios.post('/api/vIC3/request-price', {
            "expiration": expiration,
            "current_stock_price": currStockPrice,
            "strike": strike,
            "sigma": sigma,
        })
    } catch(err) {
        console.log(err)
    }

    return response
}
async function sim() {
    let expiration = 100 // 20000
    let spotPrice = 1000 // 370
    let strikePrice = 1200 // 380
    let sigma = 0.002 // 0.5

    for (let i = 0; i <= 10; i++) {
        await getOptionPrice(expiration, spotPrice, strikePrice, sigma)

        let deltabalance = await hedgingcontract.getWETHBalance()
        console.log(['hedging portfolio balance:', deltabalance])
    }
}