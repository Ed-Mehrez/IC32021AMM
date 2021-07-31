const EventsContract = require('../build/contracts/EventsContract.json') // can be Uniswap or can be hedging contract if we define our own event
const HedgingContract = require("../build/contracts/Reserves.json")
const TrackingERC20 = require("../build/contracts/TrackingToken.json")
const Web3 = require('web3')

// production listener should be in Python/C++

async function init() {
    console.log("listener is running")

    // Config

    const web3 = new Web3('ws://127.0.0.1:9650/ext/bc/C/ws') // needs to be Arbitrum
    const networkId =  await web3.eth.net.getId() //12345
    const addresses = await web3.eth.getAccounts()
    console.log(["con data: ", networkId, addresses])

    /* Hedging Contract */

    const HCdeployedNetwork = HedgingContract.networks[networkId]
    const hedgingcontract = new web3.eth.Contract(
        HedgingContract.abi,
        HCdeployedNetwork.address
    )

    /* Events Listener */

    const ECdeployedNetwork = EventsContract.networks[networkId]
    const eventscontract = new web3.eth.Contract(
        EventsContract.abi,
        ECdeployedNetwork.address
    )

    // console.log(eventscontract.events.SwapEvent())

    // response logic
    eventscontract.events.SwapEvent().on('data', async (e) => {
        let dat = e.returnValues
        console.log([dat])

       // let fulfillrequest = await hedgincontract.methods
       //     .fulfill(...)
        
        let gasAmount = await fulfillprice.estimateGas()
        await fulfillrequest.send({ from: addresses[0], gas: gasAmount })
        
    })
}