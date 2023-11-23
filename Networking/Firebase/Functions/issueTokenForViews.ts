import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { FieldValue } from 'firebase-admin/lib/firestore'
import { db } from './index';

interface ViewRating {
episodeId: string
userId: string
}

interface Episode {
userId: string
}

interface TokenData {
unclaimed: number
pending: number
claimed: number
reserved: number
remaining: number
minted: number
}

export async function issueTokenForViews(snapshot: functions.firestore.DocumentSnapshot, context: functions.EventContext) {
    try {
        console.log('Inside onCreate function')
        const viewRating = snapshot.data() as ViewRating
        const { episodeId, userId } = viewRating
        
        if (episodeId === '' || userId === '') {
            console.error('Invalid viewRating data')
            return null
        }
        
        const episodeRef = db.collection('Episode').doc(episodeId)
        const episodeSnapshot = await episodeRef.get()
        const episode = episodeSnapshot.data() as Episode
        
        if (episode === null || episode.userId === undefined) {
            console.error('Invalid episode data')
            return null
        }
        
        const treasuryRef = db.collection('Tokens').doc('Treasury')
        const pendingTokensRef = treasuryRef.collection("PendingTokens").doc(userId)
        const userTokensRef = db.collection('Tokens_Balance').doc(userId)
        
        
        await db.runTransaction(async (transaction) => {
            const treasurySnapShot = await transaction.get(treasuryRef)
            const pendingTokenDoc = await transaction.get(pendingTokensRef)
            const userSnapshot = await transaction.get(userTokensRef)
            
            if (!treasurySnapShot.exists) {
                console.error('Treasury document does not exist');
                // Handle the scenario when the document does not exist
                return null;
            }
            
            const tokensToIssue = 1 // Or whatever logic you have for determining this number
            
            let currentPending = 0
            if(pendingTokenDoc.exists) {
                currentPending = pendingTokenDoc.data()?.pending || 0;
                transaction.update(pendingTokensRef, { pending: currentPending + tokensToIssue})
            } else {
                transaction.set(pendingTokensRef, {
                pending: tokensToIssue,
                user: userTokensRef.path
                })
            }
            
            if(!userSnapshot.exists) {
                transaction.set(userTokensRef, {
                unclaimed: 0,
                reserved: 0,
                claimed: 0
                })
            }
            
            
            const treasuryData = treasurySnapShot.data() as TokenData
            console.log('remaining: %d', treasuryData.remaining)
            
            transaction.update(treasuryRef, {
            pending: treasuryData.pending + tokensToIssue,
            remaining: treasuryData.remaining - tokensToIssue
            })
            
//            transaction.update(pendingTokensRef, {
//            pending: currentPending
//            })
        })
    } catch (error) {
        console.error('An error occurred:', error)
    }
    
    return null
};
