const EventsContract = require('../build/contracts/EventsContract.json') // can be Uniswap or can be hedging contract if we define our own event
const HedgingContract = require("../build/contracts/Reserves.json")
const TrackingERC20 = require("../build/contracts/TrackingToken.json")
const Web3 = require('web3')



// connect to web3 provider, use default account for signing

// instantiate local versions of contracts

// smart contract direct interaction pre-approve stablecoin spending for proxy spending (need router contract?)

// simulate sequence of API calls

// call API with price request (and just assume user accepts any price) (can also send user address)