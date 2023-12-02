"use strict";
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
exports.issueTokenForViews = void 0;
const index_1 = require("./index");
function issueTokenForViews(snapshot, context) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            console.log('Inside onCreate function');
            const viewRating = snapshot.data();
            const { episodeId, userId } = viewRating;
            if (episodeId === '' || userId === '') {
                console.error('Invalid viewRating data');
                return null;
            }
            const episodeRef = index_1.db.collection('Episode').doc(episodeId);
            const episodeSnapshot = yield episodeRef.get();
            const episode = episodeSnapshot.data();
            if (episode === null || episode.userId === undefined) {
                console.error('Invalid episode data');
                return null;
            }
            const treasuryRef = index_1.db.collection('Tokens').doc('Treasury');
            const pendingTokensRef = treasuryRef.collection("PendingTokens").doc(userId);
            const userTokensRef = index_1.db.collection('Tokens_Balance').doc(userId);
            yield index_1.db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
                var _a;
                const treasurySnapShot = yield transaction.get(treasuryRef);
                const pendingTokenDoc = yield transaction.get(pendingTokensRef);
                const userSnapshot = yield transaction.get(userTokensRef);
                if (!treasurySnapShot.exists) {
                    console.error('Treasury document does not exist');
                    // Handle the scenario when the document does not exist
                    return null;
                }
                const tokensToIssue = 1; // Or whatever logic you have for determining this number
                let currentPending = 0;
                if (pendingTokenDoc.exists) {
                    currentPending = ((_a = pendingTokenDoc.data()) === null || _a === void 0 ? void 0 : _a.pending) || 0;
                    transaction.update(pendingTokensRef, { pending: currentPending + tokensToIssue });
                }
                else {
                    transaction.set(pendingTokensRef, {
                        pending: tokensToIssue,
                        user: userTokensRef.path
                    });
                }
                if (!userSnapshot.exists) {
                    transaction.set(userTokensRef, {
                        unclaimed: 0,
                        reserved: 0,
                        claimed: 0
                    });
                }
                const treasuryData = treasurySnapShot.data();
                console.log('remaining: %d', treasuryData.remaining);
                transaction.update(treasuryRef, {
                    pending: treasuryData.pending + tokensToIssue,
                    remaining: treasuryData.remaining - tokensToIssue
                });
                //            transaction.update(pendingTokensRef, {
                //            pending: currentPending
                //            })
            }));
        }
        catch (error) {
            console.error('An error occurred:', error);
        }
        return null;
    });
}
exports.issueTokenForViews = issueTokenForViews;
;
