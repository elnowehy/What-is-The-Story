import fetch from 'node-fetch';
import { ethers } from 'ethers';
import * as admin from 'firebase-admin';
import { db } from './index';

const polygonScanApiKey: string = process.env.POLYSCAN_API_KEY || "";
if(!polygonScanApiKey) {
    throw new Error("Scan API Key not found in environment variables")
}
const platformWalletAddress: string = process.env.PLATFORM_WALLET_ADDRESS || "";
if(!platformWalletAddress) {
    throw new Error("Platform Wallet Address not found in environment variables")
}

interface Deposit {
    hash: string;
    amount: string;
    blockNumber: number;
}

// Function to fetch new deposit transactions
export async function fetchTransactions(userWalletAddress: string, lastProcessedBlockNumber: number): Promise<Deposit[]> {
    const url: string = `https://api-testnet.polygonscan.com/api?module=account&action=txlist&address=${userWalletAddress}&startblock=${lastProcessedBlockNumber}&endblock=99999999&sort=asc&apikey=${polygonScanApiKey}`;
    console.log(url);
    try {
        const response = await fetch(url);
        const data = await response.json();
        console.log(data)

        if (data.status !== '1' || data.message !== 'OK') {
            throw new Error('Failed to fetch transactions from PolygonScan');
        }

        const deposits: Deposit[] = data.result.filter((tx: any) =>
            tx.to.toLowerCase() === platformWalletAddress.toLowerCase()
        ).map((tx: any) => ({
            hash: tx.hash,
            // amount: ethers.formatUnits(tx.value, 'ether'),
            amount: tx.value,
            blockNumber: parseInt(tx.blockNumber, 10)
        }));
        
        console.log("deposits:", deposits)

        return deposits;
    } catch (error) {
        console.error('Error fetching transactions:', error);
        return [];
    }
}

// Function to update user's gas balance
export async function updateUserGasBalance(userId: string, userWalletAddress: string): Promise<void> {
    console.log("these are the arguments user id and userWalletAddress", userId, userWalletAddress)
    const userDoc = await db.collection('Tokens_Balance').doc(userId).get();
    const lastProcessedBlockNumber: number = userDoc.exists
        ? (userDoc.data()?.lastProcessedBlockNumber ?? 0)
        : 0;

    // Initialize current gas balance to 0 if it doesn't exist
    const currentGasBalance = userDoc.exists && userDoc.data()?.gas
        ? userDoc.data()?.gas
        : 0;

    const newDeposits: Deposit[] = await fetchTransactions(userWalletAddress, lastProcessedBlockNumber);

    if (newDeposits.length > 0) {
        // Ensure that 'tx.amount' is in MATIC units
        const totalNewDeposits: number = newDeposits.reduce((sum: number, tx: Deposit) => sum + parseFloat(ethers.formatEther(tx.amount)), 0);

        const latestBlockNumber: number = newDeposits[newDeposits.length - 1].blockNumber;

        // Update the user's gas balance and last processed block number
        const newGasBalance = currentGasBalance + totalNewDeposits;
        await db.collection('Tokens_Balance').doc(userId).update({
            userGasBalance: newGasBalance,
            lastProcessedBlockNumber: latestBlockNumber
        });
    }
}
// catch((error: any) => console.error('Error:', error));

