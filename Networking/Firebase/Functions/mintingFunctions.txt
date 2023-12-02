import { ethers, JsonRpcProvider } from 'ethers'
import contractABI from './contractABI.json'
import * as functions from 'firebase-functions';
import { db } from './index';
import { firestore } from 'firebase-admin';

//async function getTreasuryData(): Promise<firestore.DocumentSnapshot> {
//    return db.collection('Tokens').doc('Treasury').get();
//}

export const scheduledMinting = async (): Promise<void> => {
    // Initialize Ethereum provider
    const provider = new JsonRpcProvider('https://rpc-mumbai.maticvigil.com/')
    // Initialize wallet (for now using a private key, replace this later with a more secure method)
    const wallet = new ethers.Wallet('4363859ee8d14578ad38cb7950c5f32824063652667f309000ca1617d8b27910', provider)
    // Initialize contract interface
    // const contract = new ethers.Contract('YOUR_CONTRACT_ADDRESS', 'YOUR_CONTRACT_ABI', wallet)
    const contract = new ethers.Contract('0x3beed2e7551cf76d0012d686aacc291b324526f0', contractABI, wallet)
    
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
            const tx = await contract.mint('0x281D8424A948b5535F51B2BF033a95aD9EE991Fb', amount)
            
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
