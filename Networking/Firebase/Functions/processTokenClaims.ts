import { ethers, JsonRpcProvider } from 'ethers';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import contractABI from './contractABI.json';
import { db } from './index';

// Replace hardcoded values with environment variables
const contractAddress = process.env.CONTRACT_ADDRESS || "";
if(!contractAddress) {
    throw new Error("Contract Address not found in environment variables");
}
const privateKey = process.env.PRIVATE_KEY || "";
if(!privateKey) {
    throw new Error("Private key not found in environment variables");
}
const rpcUrl = process.env.RPC_URL || "";
if(!rpcUrl) {
    throw new Error("RPC URL not found in environment variables");
}

// Initialize the provider and wallet with environment variables
const provider = new ethers.JsonRpcProvider(rpcUrl);
const wallet = new ethers.Wallet(privateKey, provider);

export const processTokenClaims = async (userId: string, amount: number): Promise<void> => {
    await db.runTransaction(async (transaction) => {
        try {
            const userRef = db.collection('User').doc(userId);
            const userDoc = await transaction.get(userRef)
            if (!userDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'User document doesn not exit');
            }
            
            const userWalletAddress = userDoc.data()?.wallet ?? "";
            if(!userWalletAddress) {
                throw new Error("User wallet address is undefined")
            }
            const contract = new ethers.Contract(contractAddress, contractABI, wallet);
            
            // Calculate the amount to transfer (assuming amount is in the correct unit)
            const transferAmount = ethers.parseUnits(amount.toString(), 'ether');
            
            // Estimate gas limit for the transfer
            const estimateGasLimit = await contract.transfer.estimateGas(userWalletAddress, transferAmount);
            const defaultGasPrice = ethers.parseUnits("30", "gwei");
            const estimatedGasFeeWei = defaultGasPrice * estimateGasLimit;
            const estimatedGasFee = ethers.formatEther(estimatedGasFeeWei);
            
            // Check if the user has enough gas balance
            const userGasBalanceRef = db.collection('Tokens_Balance').doc(userId);
            const userGasBalanceDoc = await transaction.get(userGasBalanceRef)
            if (!userGasBalanceDoc.exists) {
                throw new Error('User gas balance not found');
            }
            let userGasBalance = userGasBalanceDoc.data()?.userGasBalance;
            let userUnclaimed = userGasBalanceDoc.data()?.uncalimed;
            let userClaimed = userGasBalanceDoc.data()?.claimed;
            
            if(userGasBalance < estimatedGasFee) {
                throw new functions.https.HttpsError('failed-precondition', `Not enough gas balance: ${userGasBalance} MATIC. Required: ${estimatedGasFee} MATIC`);
            }
            console.log(`userGasBalance: ${userGasBalance}, estimatedGasFee: ${estimatedGasFee}`)
            
            // Call transfer function of your smart contract
            const tx = await contract.transfer(userWalletAddress, transferAmount);
            const receipt = await tx.wait();
            console.log("receipt: ", receipt);
            console.log("gas used", Number(receipt.gasUsed));
            
            // Deduct actual gas fee
            const actualGasFeeWei = Number(receipt.gasUsed) * Number(receipt.gasPrice);
            const actualGasFee = Number(ethers.formatEther(actualGasFeeWei.toString()));
            console.log("actual gas fee: ", actualGasFee);
            
            userGasBalance -= Number(actualGasFee);
            console.log("userGasBalance: ", userGasBalance);
            
            // update token balance for treasury and users
            const treasuryRef = db.collection("Tokens").doc("Treasury")
            const treasuryDoc = await transaction.get(treasuryRef)
            if (!treasuryDoc.exists) {
                throw new Error('Treasury data not found');
            }
            let treasuryUnclaimed = treasuryDoc.data()?.uncailmed
            
            // await db.collection('Tokens_Balance').doc(userId).update({ userGasBalance });
            transaction.update(userGasBalanceRef, {
                userGasBalance: userGasBalance,
                claimed: userClaimed + amount,
                uncalimed: userUnclaimed - amount,
            })
            
            transaction.update(treasuryRef, {
                unClaimed: treasuryUnclaimed - amount
            })
            
            console.log(`Tokens transferred to ${userWalletAddress}: ${amount}`);
        } catch (error) {
            console.error("Claim processing failed: ", error)
        }
    })
}
                            
