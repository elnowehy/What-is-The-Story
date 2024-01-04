import dotenv from 'dotenv';
dotenv.config();

import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { FieldValue } from 'firebase-admin/lib/firestore'
import { scheduledMinting } from './mintingFunctions'
import { issueTokenForViews } from './issueTokenForViews'
import { updateUserBalances } from './updateUserBalances';
import { processTokenClaims } from './processTokenClaims';
import { runFinalizePolls, triggerFinalizePolls } from './FinalizePolls';

admin.initializeApp({
  projectId: 'fir-test-49220'
})

export const db = admin.firestore()
db.settings({
  host: 'localhost:8080',
  ssl: false
})

export const scheduledMintingFunction = functions.pubsub
  .schedule('every 5 minutes') // replace this with your timing
  .onRun(async (context) => {
    await scheduledMinting();
    return null;
  });

export const issueTokenForViewsFunction = functions.firestore
  .document('ViewRating/{viewRatingId}')
  .onCreate(issueTokenForViews)

exports.checkAndUpdateUserBalances = functions.https.onCall((data, context) => {
    const { userId, userWalletAddress } = data;
    return updateUserBalances(userId, userWalletAddress);
});

exports.handleTokenClaims = functions.https.onCall((data, context) => {
    // Extract required parameters from `data` or `context`
    const { userId, amount } = data;
    return processTokenClaims(userId, amount);
});

export const finalizePollsFunction = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    await runFinalizePolls();
});

// HTTP-triggered function for testing
exports.triggerFinalizePolls = triggerFinalizePolls;

