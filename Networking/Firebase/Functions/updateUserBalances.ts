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

// Replace hardcoded values with environment variables
const contractAddress = process.env.CONTRACT_ADDRESS || "";
if(!contractAddress) {
    throw new Error("Contract Address not found in environment variables");
}

interface Deposit {
    hash: string;
    gas: string;
    unclaimed: string;
    blockNumber: number;
}

// function to extract the amount from the "input" field
function parseUnclaimedTokens(input: string): string {
    console.log(`Parsing input data: ${input}`);
    // Assuming ERC-20 transfer, which starts with '0xa9059cbb'
    const methodId = input.slice(0, 10);
    // and assuming token decimals is 18
    console.log(`Method Identifier: ${methodId}`);
    if (input.startsWith('0xa9059cbb')) {
        const amountHex = '0x' + input.slice(74, 138); // Extract the amount part of the input
        console.log(`Extracted hex amount: ${amountHex}`);
        const amountInEther = ethers.formatEther(amountHex);
        console.log(`Parsed amount in ether: ${amountInEther}`);
        return amountInEther; // Convert to a decimal string with 18 decimals
    }
    return '0'; // Default to '0' if no tokens transferred
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

        const deposits: Deposit[] = data.result
            .filter((tx: any) =>
                tx.to.toLowerCase() === platformWalletAddress.toLowerCase() ||
                tx.to.toLowerCase() === contractAddress.toLowerCase()
            )
            .map((tx: any) => {
                console.log(`Transaction Value: ${tx.value}, input: ${tx.input}`);
                const unclaimed = tx.value === '0' ? parseUnclaimedTokens(tx.input) : '0';
                return {
                    hash: tx.hash,
                    // amount: ethers.formatUnits(tx.value, 'ether'),
                    gas: ethers.formatEther(tx.value),
                    unclaimed: unclaimed,
                    blockNumber: parseInt(tx.blockNumber, 10)
                }
        });
        
        console.log("deposits:", deposits)

        return deposits;
    } catch (error) {
        console.error('Error fetching transactions:', error);
        return [];
    }
}

// Function to update user's gas balance
export async function updateUserBalances(userId: string, userWalletAddress: string): Promise<void> {
    console.log("these are the arguments user id and userWalletAddress", userId, userWalletAddress)
    const userDoc = await db.collection('Tokens_Balance').doc(userId).get();
    const lastProcessedBlockNumber: number = userDoc.exists
        ? (userDoc.data()?.lastProcessedBlockNumber ?? 0)
        : 0;

    // Initialize current gas balance to 0 if it doesn't exist
    const currentGasBalance = userDoc.exists && userDoc.data()?.gas
        ? userDoc.data()?.gas
        : 0;
        
    const currentUnclaimedBalance = userDoc.exists && userDoc.data()?.unclaimed
        ? userDoc.data()?.unclaimed
        : 0;

    const newDeposits: Deposit[] = await fetchTransactions(userWalletAddress, lastProcessedBlockNumber);

    if (newDeposits.length > 0) {
        // Ensure that 'tx.gas' is in MATIC units
        const totalNewGas = newDeposits.reduce((sum, tx) => sum + parseFloat(tx.gas), 0);
        const totalNewUnclaimed = newDeposits.reduce((sum, tx) => sum + parseFloat(tx.unclaimed), 0);

        const latestBlockNumber: number = newDeposits[newDeposits.length - 1].blockNumber;

        await db.collection('Tokens_Balance').doc(userId).update({
            gas: currentGasBalance + totalNewGas,
            unclaimed: currentUnclaimedBalance + totalNewUnclaimed,
            lastProcessedBlockNumber: latestBlockNumber
        });
    }
}
// catch((error: any) => console.error('Error:', error));


