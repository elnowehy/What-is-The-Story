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
exports.updateUserBalances = exports.fetchTransactions = void 0;
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
// Replace hardcoded values with environment variables
const contractAddress = process.env.CONTRACT_ADDRESS || "";
if (!contractAddress) {
    throw new Error("Contract Address not found in environment variables");
}
// function to extract the amount from the "input" field
function parseUnclaimedTokens(input) {
    console.log(`Parsing input data: ${input}`);
    // Assuming ERC-20 transfer, which starts with '0xa9059cbb'
    const methodId = input.slice(0, 10);
    // and assuming token decimals is 18
    console.log(`Method Identifier: ${methodId}`);
    if (input.startsWith('0xa9059cbb')) {
        const amountHex = '0x' + input.slice(74, 138); // Extract the amount part of the input
        console.log(`Extracted hex amount: ${amountHex}`);
        const amountInEther = ethers_1.ethers.formatEther(amountHex);
        console.log(`Parsed amount in ether: ${amountInEther}`);
        return amountInEther; // Convert to a decimal string with 18 decimals
    }
    return '0'; // Default to '0' if no tokens transferred
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
            const deposits = data.result
                .filter((tx) => tx.to.toLowerCase() === platformWalletAddress.toLowerCase() ||
                tx.to.toLowerCase() === contractAddress.toLowerCase())
                .map((tx) => {
                console.log(`Transaction Value: ${tx.value}, input: ${tx.input}`);
                const unclaimed = tx.value === '0' ? parseUnclaimedTokens(tx.input) : '0';
                return {
                    hash: tx.hash,
                    // amount: ethers.formatUnits(tx.value, 'ether'),
                    gas: ethers_1.ethers.formatEther(tx.value),
                    unclaimed: unclaimed,
                    blockNumber: parseInt(tx.blockNumber, 10)
                };
            });
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
function updateUserBalances(userId, userWalletAddress) {
    var _a, _b, _c, _d, _e, _f;
    return __awaiter(this, void 0, void 0, function* () {
        console.log("these are the arguments user id and userWalletAddress", userId, userWalletAddress);
        const userDoc = yield index_1.db.collection('Tokens_Balance').doc(userId).get();
        const lastProcessedBlockNumber = userDoc.exists
            ? ((_b = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.lastProcessedBlockNumber) !== null && _b !== void 0 ? _b : 0)
            : 0;
        // Initialize current gas balance to 0 if it doesn't exist
        const currentGasBalance = userDoc.exists && ((_c = userDoc.data()) === null || _c === void 0 ? void 0 : _c.gas)
            ? (_d = userDoc.data()) === null || _d === void 0 ? void 0 : _d.gas
            : 0;
        const currentUnclaimedBalance = userDoc.exists && ((_e = userDoc.data()) === null || _e === void 0 ? void 0 : _e.unclaimed)
            ? (_f = userDoc.data()) === null || _f === void 0 ? void 0 : _f.unclaimed
            : 0;
        const newDeposits = yield fetchTransactions(userWalletAddress, lastProcessedBlockNumber);
        if (newDeposits.length > 0) {
            // Ensure that 'tx.gas' is in MATIC units
            const totalNewGas = newDeposits.reduce((sum, tx) => sum + parseFloat(tx.gas), 0);
            const totalNewUnclaimed = newDeposits.reduce((sum, tx) => sum + parseFloat(tx.unclaimed), 0);
            const latestBlockNumber = newDeposits[newDeposits.length - 1].blockNumber;
            yield index_1.db.collection('Tokens_Balance').doc(userId).update({
                gas: currentGasBalance + totalNewGas,
                unclaimed: currentUnclaimedBalance + totalNewUnclaimed,
                lastProcessedBlockNumber: latestBlockNumber
            });
        }
    });
}
exports.updateUserBalances = updateUserBalances;
// catch((error: any) => console.error('Error:', error));
