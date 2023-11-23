//import { ethers, JsonRpcProvider } from 'ethers'
import { ethers } from 'ethers'
import contractABI from './contractABI.json'
import * as functions from 'firebase-functions';
import { db } from './index';
import { firestore } from 'firebase-admin';

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
if(!privateKey) {
    throw new Error("Private key not found in environment variables");
}

// Initialize the provider and wallet with environment variables
const provider = new ethers.JsonRpcProvider(rpcUrl);

export const scheduledMinting = async (): Promise<void> => {
    // Initialize Ethereum provider
    // const provider = new JsonRpcProvider('https://rpc-mumbai.maticvigil.com/')
    // Initialize wallet (for now using a private key, replace this later with a more secure method)
    const wallet = new ethers.Wallet(privateKey, provider)
    // Initialize contract interface
    // const contract = new ethers.Contract('YOUR_CONTRACT_ADDRESS', 'YOUR_CONTRACT_ABI', wallet)
    const contract = new ethers.Contract(contractAddress, contractABI, wallet)
    
    await db.runTransaction(async (transaction) => {
        try {
            // Retrieve the Treasury data from Firestore
            const treasuryRef = db.collection('Tokens').doc('Treasury');
            const treasurySnapshot = await transaction.get(treasuryRef);
            
            if (!treasurySnapshot.exists) {
                throw new Error('Treasury data not found');
            }
            
            // Access the pending field
            const treasuryData = treasurySnapshot.data() as {
            pending: number,
            minted: number,
            unclaimed: number                
            };
            if(treasuryData.pending == undefined) {
                throw new Error('Pending field is not avaialble in the Treasury document')
            }
            
            console.log('Pending transaction:', treasuryData.pending)
            
            const amount = ethers.parseUnits(treasuryData.pending.toString(), 'ether');
            const tx = await contract.mint(platformWallet, amount)
            
            // Wait for the transaction to be confirmed
            await tx.wait()
            
            console.log('Minting successful:', tx.hash)
            
            const pendingTokensDocs = await treasuryRef.collection('PendingTokens').get();
            for(const doc of pendingTokensDocs.docs) {
                const userPendingTokens = doc.data().pending
                const userTokensPath = doc.data().user
                const userTokensRef = db.doc(userTokensPath)
                
                const userTokensSnapshot = await transaction.get(userTokensRef)
                const userTokensData = userTokensSnapshot.data()
                
                const updatedUnclaimed = (userTokensData?.unclaimed || 0) + userPendingTokens
                transaction.update(userTokensRef, {
                    unclaimed: updatedUnclaimed
                })
                console.log("deleting ", userTokensPath)
                transaction.delete(doc.ref)
            }
            
            // Update the Treasury document
            transaction.update(treasuryRef, {
            pending: 0,
            minted: (treasuryData.minted || 0) + treasuryData.pending,
            unclaimed: (treasuryData.unclaimed || 0) + treasuryData.pending
            });
            
        } catch (error) {
            console.error('Minting failed:', error)
        }
    })
}


export const scheduledMintingFunction = functions.pubsub
.schedule('every 5 minutes')
.timeZone('America/Toronto')
.onRun(async (context) => {
    return scheduledMinting();
});

export const triggerScheduledMinting = functions.https.onRequest(async (req, res) => {
    try {
        await scheduledMinting();
        res.send('Minting triggered successfully.');
    } catch (error) {
        console.error('Minting failed:', error);
        res.status(500).send('An error occurred while minting.');
    }
});
