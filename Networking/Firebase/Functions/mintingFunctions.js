"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
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
exports.triggerScheduledMinting = exports.scheduledMintingFunction = exports.scheduledMinting = void 0;
//import { ethers, JsonRpcProvider } from 'ethers'
const ethers_1 = require("ethers");
const contractABI_json_1 = __importDefault(require("./contractABI.json"));
const functions = __importStar(require("firebase-functions"));
const index_1 = require("./index");
// console.log(process.env);
const contractAddress = process.env.CONTRACT_ADDRESS || "";
if (!contractAddress) {
    throw new Error("Contract address is not defined in environment variables");
}
const platformWallet = process.env.PLATFORM_WALLET_ADDRESS || "";
if (!platformWallet) {
    throw new Error("Platform Wallett address is not defined in environment variables");
}
const rpcUrl = process.env.RPC_URL || "";
if (!rpcUrl) {
    throw new Error("RPC URL is not defined in environment variables");
}
const privateKey = process.env.PRIVATE_KEY || "";
if (!privateKey) {
    throw new Error("Private key not found in environment variables");
}
// Initialize the provider and wallet with environment variables
const provider = new ethers_1.ethers.JsonRpcProvider(rpcUrl);
const scheduledMinting = () => __awaiter(void 0, void 0, void 0, function* () {
    // Initialize Ethereum provider
    // const provider = new JsonRpcProvider('https://rpc-mumbai.maticvigil.com/')
    // Initialize wallet (for now using a private key, replace this later with a more secure method)
    const wallet = new ethers_1.ethers.Wallet(privateKey, provider);
    // Initialize contract interface
    // const contract = new ethers.Contract('YOUR_CONTRACT_ADDRESS', 'YOUR_CONTRACT_ABI', wallet)
    const contract = new ethers_1.ethers.Contract(contractAddress, contractABI_json_1.default, wallet);
    yield index_1.db.runTransaction((transaction) => __awaiter(void 0, void 0, void 0, function* () {
        try {
            // Retrieve the Treasury data from Firestore
            const treasuryRef = index_1.db.collection('Tokens').doc('Treasury');
            const treasurySnapshot = yield transaction.get(treasuryRef);
            if (!treasurySnapshot.exists) {
                throw new Error('Treasury data not found');
            }
            // Access the pending field
            const treasuryData = treasurySnapshot.data();
            if (treasuryData.pending == undefined) {
                throw new Error('Pending field is not avaialble in the Treasury document');
            }
            console.log('Pending transaction:', treasuryData.pending);
            const amount = ethers_1.ethers.parseUnits(treasuryData.pending.toString(), 'ether');
            const tx = yield contract.mint(platformWallet, amount);
            // Wait for the transaction to be confirmed
            yield tx.wait();
            console.log('Minting successful:', tx.hash);
            const pendingTokensDocs = yield treasuryRef.collection('PendingTokens').get();
            for (const doc of pendingTokensDocs.docs) {
                const userPendingTokens = doc.data().pending;
                const userTokensPath = doc.data().user;
                const userTokensRef = index_1.db.doc(userTokensPath);
                const userTokensSnapshot = yield transaction.get(userTokensRef);
                const userTokensData = userTokensSnapshot.data();
                const updatedUnclaimed = ((userTokensData === null || userTokensData === void 0 ? void 0 : userTokensData.unclaimed) || 0) + userPendingTokens;
                transaction.update(userTokensRef, {
                    unclaimed: updatedUnclaimed
                });
                console.log("deleting ", userTokensPath);
                transaction.delete(doc.ref);
            }
            // Update the Treasury document
            transaction.update(treasuryRef, {
                pending: 0,
                minted: (treasuryData.minted || 0) + treasuryData.pending,
                unclaimed: (treasuryData.unclaimed || 0) + treasuryData.pending
            });
        }
        catch (error) {
            console.error('Minting failed:', error);
        }
    }));
});
exports.scheduledMinting = scheduledMinting;
exports.scheduledMintingFunction = functions.pubsub
    .schedule('every 5 minutes')
    .timeZone('America/Toronto')
    .onRun((context) => __awaiter(void 0, void 0, void 0, function* () {
    return (0, exports.scheduledMinting)();
}));
exports.triggerScheduledMinting = functions.https.onRequest((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield (0, exports.scheduledMinting)();
        res.send('Minting triggered successfully.');
    }
    catch (error) {
        console.error('Minting failed:', error);
        res.status(500).send('An error occurred while minting.');
    }
}));
