import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { FieldValue } from 'firebase-admin/lib/firestore'
import { scheduledMinting } from './mintingFunctions';

export const scheduledMintingFunction = functions.pubsub
  .schedule('every 5 minutes') // replace this with your timing
  .onRun(async (context) => {
    await scheduledMinting();
    return null;
  });

admin.initializeApp({
  projectId: 'fir-test-49220'
})
const db = admin.firestore()
db.settings({
  host: 'localhost:8080',
  ssl: false
})
// const FieldValue = admin.firestore.FieldValue;

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
}

export const issueTokensForViews = functions.firestore
  .document('ViewRating/{viewRatingId}')
  .onCreate(async (snapshot: functions.firestore.DocumentSnapshot, context: functions.EventContext) => {
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

      const platformMintableBookRef = db.collection('Tokens').doc('PlatformMintableReserve')
      const userPendingTokensRef = db.collection('Tokens').doc('Container').collection('UserBooks').doc(userId)
      const ledgerRef = db.collection('Tokens').doc('Container').collection('Ledger')

      await db.runTransaction(async (transaction) => {
        const platformSnapshot = await transaction.get(platformMintableBookRef)
        const userSnapshot = await transaction.get(userPendingTokensRef)

        const platformData = platformSnapshot.data() as TokenData
        const userData = userSnapshot.data() as TokenData

        console.log('remaining: %d', platformData.remaining)

        const tokensToIssue = 1 // Or whatever logic you have for determining this number
        const updatedPlatformTokens = platformData.remaining - tokensToIssue
        if (updatedPlatformTokens === 0 || Number.isNaN(updatedPlatformTokens)) {
          console.error('Invalid platform tokens')
          return
        }

        // const updatedUserTokens = (userData?.pending || 0) + tokensToIssue
        const updatedUserTokens = (userData?.pending !== null && userData?.pending !== undefined ? userData?.pending : 0) + tokensToIssue

        if (Number.isNaN(updatedUserTokens) || updatedUserTokens === 0) {
          console.error('Invalid updated user tokens')
          return
        }

        // Assuming this relates to the 'updatedPlatformTokens' or similar

        if (platformData === null || platformData.remaining === undefined) {
          console.error('Invalid platformData')
          return null
        }

        transaction.update(platformMintableBookRef, { remaining: updatedPlatformTokens })
        transaction.set(userPendingTokensRef, { pending: updatedUserTokens })

        // if (!FieldValue) {
        //   console.error('FieldValue is undefined')
        //   return
        // }

        const ledgerData = {
          id: context.params.viewRatingId,
          amount: tokensToIssue,
          sender: 'PlatformMintableReserve',
          receiver: userId,
          type: 'view',
          status: 'Pending',
          // timestamp: FieldValue.serverTimestamp()
        }

        transaction.set(ledgerRef.doc(), ledgerData)
      })
    } catch (error) {
      console.error('An error occurred:', error)
    }

    return null
  })
