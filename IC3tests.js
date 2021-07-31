const HedgingContract = require("../build/contracts/Reserves.json")
const Web3 = require('web3')

// connect to network

const url = '3.239.167.241'
const port = 8545
const web3 = new Web3(`http://${url}:${port}`)

// connect to web3 provider, use default account for signing

// const new Web3.HttpProvider()

// instantiate local versions of hedging contract

const HCdeployedNetwork = HedgingContract.networks[networkId]
const hedgingcontract = new web3.eth.Contract(
    HedgingContract.abi,
    HCdeployedNetwork.address
)

// simulate sequence of API calls // call API with price request (and just assume user accepts any price) (can also send user address)

let xhr = new XMLHttpRequest()
xhr.open("GET", 'http://127.0.0.1:6500/api/vIC3')

async function sim() {

    for (let i=0; i <= 10; i++) {

        let data = {
            expiration: 20000, 
            spotprice: 1000, // + normrand(0, 10)
            strikeprice: 1200,
            // type: "call",
            sigma: 0.002 // + normrand(0.0001, 0.0001)
            // address: web3.eth.accounts[0]
        }

        xhr.send(data)

        await new Promise((resolve) => setTimeout(resolve, 1000)) // pause to wait for api call to process

        let deltabalance = await hedgingcontract.getWETHBalance()
        console.log(['hedging portfolio balance:', deltabalance])
    }
}

