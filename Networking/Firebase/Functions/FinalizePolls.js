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
Object.defineProperty(exports, "__esModule", { value: true });
exports.finalizePolls = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const index_1 = require("./index");
exports.finalizePolls = functions.pubsub.schedule('every 24 hours').onRun((context) => __awaiter(void 0, void 0, void 0, function* () {
    const polls = yield fetchPollsToFinalize();
    for (const poll of polls) {
        yield processPoll(poll);
    }
}));
// And so on for other functions...
function fetchPollsToFinalize() {
    return __awaiter(this, void 0, void 0, function* () {
        const now = admin.firestore.Timestamp.now();
        const pollsSnapshot = yield index_1.db.collection('Poll')
            .where('closingDate', '<=', now)
            .get();
        const polls = [];
        pollsSnapshot.forEach(doc => {
            const pollData = doc.data();
            if ('rewardTokens' in pollData) {
                polls.push(Object.assign(Object.assign({}, pollData), { id: doc.id }));
            }
            else {
                console.log(`Poll with ID ${doc.id} is missing the 'rewardToken' property`);
            }
        });
        return polls;
    });
}
function processPoll(poll) {
    return __awaiter(this, void 0, void 0, function* () {
        const answers = yield fetchAnswersForPoll(poll.id);
        const answerVotes = yield countVotesForAnswers(answers);
        const winner = determineWinner(answerVotes);
        if (winner) {
            // Assuming 'winner' contains the userId of the winning user
            const winnerUserId = winner.userId;
            yield allocateTokenRewards(winnerUserId, poll.id, poll.rewardTokens);
            // Optional: Notify participants
            // Update poll status to finalized
        }
        yield updatePollStatus(poll.id);
    });
}
function fetchAnswersForPoll(pollId) {
    return __awaiter(this, void 0, void 0, function* () {
        const answersSnapshot = yield index_1.db.collection('Answer')
            .where('pollId', '==', pollId)
            .get();
        const answers = [];
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
    });
}
function countVotesForAnswers(answers) {
    return __awaiter(this, void 0, void 0, function* () {
        const answerVotes = [];
        for (const answer of answers) {
            const votesSnapshot = yield index_1.db.collection('Answer')
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
    });
}
function determineWinner(answerVotes) {
    if (answerVotes.length === 0) {
        return null; // No answers or votes
    }
    // Sort the answers by vote count and then by timestamp (earliest first)
    answerVotes.sort((a, b) => b.voteCount - a.voteCount);
    // The first element after sorting will be the winner
    return answerVotes[0];
}
function allocateTokenRewards(winnerUserId, pollId, rewardTokens) {
    var _a;
    return __awaiter(this, void 0, void 0, function* () {
        // Fetch the episode to get the creator's userId
        const episodeDoc = yield index_1.db.collection('Episode').doc(pollId).get();
        if (!episodeDoc.exists) {
            console.log(`Episode not found for poll ID: ${pollId}`);
            return;
        }
        const creatorUserId = (_a = episodeDoc.data()) === null || _a === void 0 ? void 0 : _a.userId;
        if (!creatorUserId) {
            console.log("Creator ID not defined for an episode");
            return;
        }
        // Decrease 'reserved' tokens for the creator
        const creatorTokenBalanceRef = index_1.db.collection('UserTokenBalances').doc(creatorUserId);
        yield updateTokenBalance(creatorTokenBalanceRef, 'reserved', -rewardTokens);
        // Handle the winner's token balance
        const winnerTokenBalanceRef = index_1.db.collection('UserTokenBalances').doc(winnerUserId);
        const winnerTokenBalanceDoc = yield winnerTokenBalanceRef.get();
        if (!winnerTokenBalanceDoc.exists) {
            // Create a new token balance for the winner if it doesn't exist
            yield winnerTokenBalanceRef.set({ unclaimed: rewardTokens });
        }
        else {
            // Increase 'unclaimed' tokens for the winner
            yield updateTokenBalance(winnerTokenBalanceRef, 'unclaimed', rewardTokens);
        }
    });
}
function updatePollStatus(pollId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield index_1.db.collection('Poll').doc(pollId).update({
                isFinalized: true // Or update a 'status' field if you use one
            });
            console.log(`Poll with ID ${pollId} has been finalized.`);
        }
        catch (error) {
            console.error(`Error updating status for poll ID ${pollId}:`, error);
        }
    });
}
function updateTokenBalance(tokenBalanceRef, field, tokenChange) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // Fetch the current token balance document
            const tokenBalanceDoc = yield tokenBalanceRef.get();
            if (!tokenBalanceDoc.exists) {
                console.error(`Token balance document not found for reference: ${tokenBalanceRef.path}`);
                return;
            }
            // Safely access the field in the document data
            const tokenBalanceData = tokenBalanceDoc.data() || {};
            const currentBalance = tokenBalanceData[field] || 0;
            const newBalance = Math.max(currentBalance + tokenChange, 0); // Prevent negative balance
            // Update the token balance document
            yield tokenBalanceRef.update({ [field]: newBalance });
            console.log(`Token balance updated for ${field} in document: ${tokenBalanceRef.path}`);
        }
        catch (error) {
            console.error(`Error updating token balance for ${field} in document: ${tokenBalanceRef.path}:`, error);
        }
    });
}
// Additional function to update the poll's status to finalized
