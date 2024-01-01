import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from './index';

export const finalizePolls = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    const polls = await fetchPollsToFinalize();
    for (const poll of polls) {
        await processPoll(poll);
    }
});


interface Poll {
    id: string;
    rewardTokens: number;
    // Add other relevant fields
}

interface Answer {
    id: string;
    userId: string;
    timestamp: Date;
}

interface AnswerVote {
    id: string;
    userId: string;
    voteCount: number;
}

// And so on for other functions...
async function fetchPollsToFinalize(): Promise<Poll[]> {
    const now = admin.firestore.Timestamp.now();
    const pollsSnapshot = await db.collection('Poll')
                                  .where('closingDate', '<=', now)
                                  .get();

    const polls: Poll[] = [];
    pollsSnapshot.forEach(doc => {
        const pollData = doc.data() as Poll;
        if ('rewardTokens' in pollData) {
           polls.push({ ...pollData,  id: doc.id });
        } else {
           console.log(`Poll with ID ${doc.id} is missing the 'rewardToken' property`);
        }
    });

    return polls;
}


async function processPoll(poll: Poll) {
    const answers: Answer[] = await fetchAnswersForPoll(poll.id);
    const answerVotes: AnswerVote[] = await countVotesForAnswers(answers);
    const winner = determineWinner(answerVotes);
    if (winner) {
        // Assuming 'winner' contains the userId of the winning user
        const winnerUserId = winner.userId;

        await allocateTokenRewards(winnerUserId, poll.id, poll.rewardTokens);
        // Optional: Notify participants
        // Update poll status to finalized
    }

    await updatePollStatus(poll.id);
}

async function fetchAnswersForPoll(pollId: string) {
    const answersSnapshot = await db.collection('Answer')
                                    .where('pollId', '==', pollId)
                                    .get();

    const answers: Answer[] = [];
    answersSnapshot.forEach(doc => {
        // Fetch only the necessary fields: id and userId
        const answerData = doc.data();
        answers.push({
            id: doc.id,
            userId: answerData.userId,
            timestamp: answerData.timestamp
        });
    });

    return answers;
}

async function countVotesForAnswers(answers: Answer[]) {
    const answerVotes: AnswerVote[] = [];

    for (const answer of answers) {
        const votesSnapshot = await db.collection('Answer')
                                      .doc(answer.id)
                                      .collection('Votes')
                                      .get();
        
        // Store the count of votes along with the answer ID and userId
        answerVotes.push({
            id: answer.id,
            userId: answer.userId,
            voteCount: votesSnapshot.size,
        });
    }

    return answerVotes;
}

function determineWinner(answerVotes: AnswerVote[]) {
    if (answerVotes.length === 0) {
        return null; // No answers or votes
    }

    // Sort the answers by vote count and then by timestamp (earliest first)
    answerVotes.sort((a, b) => b.voteCount - a.voteCount);

    // The first element after sorting will be the winner
    return answerVotes[0];
}


async function allocateTokenRewards(winnerUserId: string, pollId: string, rewardTokens: number) {
    // Fetch the episode to get the creator's userId
    const episodeDoc = await db.collection('Episode').doc(pollId).get();
    if (!episodeDoc.exists) {
        console.log(`Episode not found for poll ID: ${pollId}`);
        return;
    }

    const creatorUserId = episodeDoc.data()?.userId;
    if (!creatorUserId) {
        console.log("Creator ID not defined for an episode");
        return;
    }

    // Decrease 'reserved' tokens for the creator
    const creatorTokenBalanceRef = db.collection('UserTokenBalances').doc(creatorUserId);
    await updateTokenBalance(creatorTokenBalanceRef, 'reserved', -rewardTokens);

    // Handle the winner's token balance
    const winnerTokenBalanceRef = db.collection('UserTokenBalances').doc(winnerUserId);
    const winnerTokenBalanceDoc = await winnerTokenBalanceRef.get();

    if (!winnerTokenBalanceDoc.exists) {
        // Create a new token balance for the winner if it doesn't exist
        await winnerTokenBalanceRef.set({ unclaimed: rewardTokens });
    } else {
        // Increase 'unclaimed' tokens for the winner
        await updateTokenBalance(winnerTokenBalanceRef, 'unclaimed', rewardTokens);
    }
}



async function updatePollStatus(pollId: string): Promise<void> {
    try {
        await db.collection('Poll').doc(pollId).update({
            isFinalized: true // Or update a 'status' field if you use one
        });
        console.log(`Poll with ID ${pollId} has been finalized.`);
    } catch (error) {
        console.error(`Error updating status for poll ID ${pollId}:`, error);
    }
}

async function updateTokenBalance(tokenBalanceRef: FirebaseFirestore.DocumentReference, field: string, tokenChange: number): Promise<void> {
    try {
        // Fetch the current token balance document
        const tokenBalanceDoc = await tokenBalanceRef.get();

        if (!tokenBalanceDoc.exists) {
            console.error(`Token balance document not found for reference: ${tokenBalanceRef.path}`);
            return;
        }

        // Safely access the field in the document data
        const tokenBalanceData = tokenBalanceDoc.data() || {};
        const currentBalance = tokenBalanceData[field] || 0;
        const newBalance = Math.max(currentBalance + tokenChange, 0); // Prevent negative balance

        // Update the token balance document
        await tokenBalanceRef.update({ [field]: newBalance });
        console.log(`Token balance updated for ${field} in document: ${tokenBalanceRef.path}`);
    } catch (error) {
        console.error(`Error updating token balance for ${field} in document: ${tokenBalanceRef.path}:`, error);
    }
}


// Additional function to update the poll's status to finalized
