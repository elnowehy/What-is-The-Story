"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.processTokenClaims = void 0;
const ethers_1 = require("ethers");
const contractABI_json_1 = __importDefault(require("./contractABI.json"));
const index_1 = require("./index");
// Replace hardcoded values with environment variables
const contractAddress = process.env.CONTRACT_ADDRESS || "";
if (!contractAddress) {
    throw new Error("Contract Address not found in environment variables");
}
const privateKey = process.env.PRIVATE_KEY || "";
if (!privateKey) {
    throw new Error("Private key not found in environment variables");
}
const rpcUrl = process.env.RPC_URL || "";
if (!rpcUrl) {
    throw new Error("RPC URL not found in environment variables");
}
// Initialize the provider and wallet with environment variables
const provider = new ethers_1.ethers.JsonRpcProvider(rpcUrl);
const wallet = new ethers_1.ethers.Wallet(privateKey, provider);
const processTokenClaims = (userId, amount) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c;
    try {
        const userDoc = yield index_1.db.collection('User').doc(userId).get();
        if (!userDoc.exists) {
            throw new Error('User not found');
        }
        const userWalletAddress = (_b = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.ethWallet) !== null && _b !== void 0 ? _b : "";
        if (!userWalletAddress) {
            throw new Error("User wallet address is undefined");
        }
        const contract = new ethers_1.ethers.Contract(contractAddress, contractABI_json_1.default, wallet);
        // Calculate the amount to transfer (assuming amount is in the correct unit)
        const transferAmount = ethers_1.ethers.parseUnits(amount.toString(), 'ether');
        // Estimate gas limit for the transfer
        const estimateGasLimit = yield contract.transfer.estimateGas(userWalletAddress, transferAmount);
        const defaultGasPrice = ethers_1.ethers.parseUnits("30", "gwei");
        const estimatedGasFeeWei = defaultGasPrice * estimateGasLimit;
        const estimatedGasFee = ethers_1.ethers.formatEther(estimatedGasFeeWei);
        // Check if the user has enough gas balance
        const userGasBalanceDoc = yield index_1.db.collection('Tokens_Balance').doc(userId).get();
        if (!userGasBalanceDoc.exists) {
            throw new Error('User gas balance not found');
        }
        let userGasBalance = (_c = userGasBalanceDoc.data()) === null || _c === void 0 ? void 0 : _c.userGasBalance;
        if (userGasBalance < estimatedGasFee) {
            throw new Error(`not enough gas balance: ${userGasBalance} Required: ${estimatedGasFee}`);
        }
        console.log(`userGasBalance: ${userGasBalance}, estimatedGasFee: ${estimatedGasFee}`);
        // Call transfer function of your smart contract
        const tx = yield contract.transfer(userWalletAddress, transferAmount);
        const receipt = yield tx.wait();
        console.log("receipt: ", receipt);
        console.log("gas used", Number(receipt.gasUsed));
        // Deduct actual gas fee
        const actualGasFeeWei = Number(receipt.gasUsed) * Number(receipt.gasPrice);
        const actualGasFee = Number(ethers_1.ethers.formatEther(actualGasFeeWei.toString()));
        console.log("actual gas fee: ", actualGasFee);
        userGasBalance -= Number(actualGasFee);
        console.log("userGasBalance: ", userGasBalance);
        yield index_1.db.collection('Tokens_Balance').doc(userId).update({ userGasBalance });
        console.log(`Tokens transferred to ${userWalletAddress}: ${amount}`);
    }
    catch (error) {
        console.error("Claim processing failed: ", error);
    }
});
exports.processTokenClaims = processTokenClaims;
// Add further logic as needed
