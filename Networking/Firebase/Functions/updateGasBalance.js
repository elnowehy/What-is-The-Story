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
exports.updateUserGasBalance = exports.fetchTransactions = void 0;
const node_fetch_1 = __importDefault(require("node-fetch"));
const ethers_1 = require("ethers");
const index_1 = require("./index");
const polygonScanApiKey = process.env.POLYSCAN_API_KEY || "";
if (!polygonScanApiKey) {
    throw new Error("Scan API Key not found in environment variables");
}
const platformWalletAddress = process.env.PLATFORM_WALLET_ADDRESS || "";
if (!platformWalletAddress) {
    throw new Error("Platform Wallet Address not found in environment variables");
}
// Function to fetch new deposit transactions
function fetchTransactions(userWalletAddress, lastProcessedBlockNumber) {
    return __awaiter(this, void 0, void 0, function* () {
        const url = `https://api-testnet.polygonscan.com/api?module=account&action=txlist&address=${userWalletAddress}&startblock=${lastProcessedBlockNumber}&endblock=99999999&sort=asc&apikey=${polygonScanApiKey}`;
        console.log(url);
        try {
            const response = yield (0, node_fetch_1.default)(url);
            const data = yield response.json();
            console.log(data);
            if (data.status !== '1' || data.message !== 'OK') {
                throw new Error('Failed to fetch transactions from PolygonScan');
            }
            const deposits = data.result.filter((tx) => tx.to.toLowerCase() === platformWalletAddress.toLowerCase()).map((tx) => ({
                hash: tx.hash,
                // amount: ethers.formatUnits(tx.value, 'ether'),
                amount: tx.value,
                blockNumber: parseInt(tx.blockNumber, 10)
            }));
            console.log("deposits:", deposits);
            return deposits;
        }
        catch (error) {
            console.error('Error fetching transactions:', error);
            return [];
        }
    });
}
exports.fetchTransactions = fetchTransactions;
// Function to update user's gas balance
function updateUserGasBalance(userId, userWalletAddress) {
    var _a, _b, _c, _d;
    return __awaiter(this, void 0, void 0, function* () {
        console.log("these are the arguments user id and userWalletAddress", userId, userWalletAddress);
        const userDoc = yield index_1.db.collection('Tokens_Balance').doc(userId).get();
        // const lastProcessedBlockNumber: number = userDoc.exists && userDoc.data().lastProcessedBlockNumber ? userDoc.data().lastProcessedBlockNumber : 0;
        const lastProcessedBlockNumber = userDoc.exists
            ? ((_b = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.lastProcessedBlockNumber) !== null && _b !== void 0 ? _b : 0)
            : 0;
        // Initialize current gas balance to 0 if it doesn't exist
        const currentGasBalance = userDoc.exists && ((_c = userDoc.data()) === null || _c === void 0 ? void 0 : _c.gas)
            ? (_d = userDoc.data()) === null || _d === void 0 ? void 0 : _d.gas
            : 0;
        const newDeposits = yield fetchTransactions(userWalletAddress, lastProcessedBlockNumber);
        if (newDeposits.length > 0) {
            //      const totalNewDeposits: number = newDeposits.reduce((sum: number, tx: Deposit) => sum + parseFloat(tx.amount), 0);
            // Ensure that 'tx.amount' is in MATIC units
            const totalNewDeposits = newDeposits.reduce((sum, tx) => sum + parseFloat(ethers_1.ethers.formatEther(tx.amount)), 0);
            const latestBlockNumber = newDeposits[newDeposits.length - 1].blockNumber;
            // Update the user's gas balance and last processed block number
            const newGasBalance = currentGasBalance + totalNewDeposits;
            yield index_1.db.collection('Tokens_Balance').doc(userId).update({
                userGasBalance: newGasBalance,
                lastProcessedBlockNumber: latestBlockNumber
            });
        }
    });
}
exports.updateUserGasBalance = updateUserGasBalance;
// Usage example
//const userId: string = 'USER_ID'; // Replace with actual user ID
//const userWalletAddress: string = 'USER_WALLET_ADDRESS'; // Replace with actual user wallet address
//updateUserGasBalance(userId, userWalletAddress)
//    .then(() => console.log('User gas balance updated'))
//    .catch((error: any) => console.error('Error:', error));
