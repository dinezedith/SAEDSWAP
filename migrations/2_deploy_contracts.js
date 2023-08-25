
//import artifacts for contracts
var swapSAED = artifacts.require("SAEDSwap")
var SAEDInstance = artifacts.require("SAED");
var SUSDInstance = artifacts.require("SUSD");
var USDTInstance = artifacts.require("USDT");


module.exports = async function(deployer) {

    let accounts = await web3.eth.getAccounts();
    //deployment of token contracts
    await deployer.deploy(SAEDInstance, accounts[0]);
    await deployer.deploy(SUSDInstance, accounts[0]);
    await deployer.deploy(USDTInstance, accounts[0]);

    //creating instance for deployed token contracts
    var SAED = await SAEDInstance.deployed();
    var SUSD = await SUSDInstance.deployed();
    var USDT = await USDTInstance.deployed();

    // swap contract deployment
    await deployer.deploy(swapSAED, SAED.address, SUSD.address, USDT.address);
};
