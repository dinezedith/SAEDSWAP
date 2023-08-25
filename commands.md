let SAED = await SAED.deployed()

let SUSD = await SUSD.deployed()

let USDT = await USDT.deployed()

let SWAP = await SAEDSwap.deployed()

SAED.transfer(SWAP.address, 100000000)

SUSD.transfer(SWAP.address, 100000000)

USDT.transfer(SWAP.address, 100000000)

SUSD.transfer(accounts[1], 100000000)

SUSD.approve(SWAP.address, 100000000, {from: accounts[1]})

SWAP.swapToken([2, 10000000], {from: accounts[1]})

let SAED_bal = SAED.balanceOf(accounts[1])

SAED_bal = parseInt(bal)/10**6