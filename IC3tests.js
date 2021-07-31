const axios = require('axios')

const HedgingContract = require("../build/contracts/Reserves.json")
const Web3 = require('web3')

// connect to network
const url = '3.239.167.241'
const port = 8545
const web3 = new Web3(`http://${url}:${port}/`)

// connect to web3 provider, use default account for signing

// const new Web3.HttpProvider()

// instantiate local versions of hedging contract

const HCdeployedNetwork = HedgingContract.networks[networkId]
const hedgingcontract = new web3.eth.Contract(
    HedgingContract.abi,
    HCdeployedNetwork.address
)

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