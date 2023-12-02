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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.issueTokenForViewsFunction = exports.scheduledMintingFunction = exports.db = void 0;
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const mintingFunctions_1 = require("./mintingFunctions");
const issueTokenForViews_1 = require("./issueTokenForViews");
const updateGasBalance_1 = require("./updateGasBalance");
const processTokenClaims_1 = require("./processTokenClaims");
admin.initializeApp({
    projectId: 'fir-test-49220'
});
exports.db = admin.firestore();
exports.db.settings({
    host: 'localhost:8080',
    ssl: false
});
exports.scheduledMintingFunction = functions.pubsub
    .schedule('every 5 minutes') // replace this with your timing
    .onRun((context) => __awaiter(void 0, void 0, void 0, function* () {
    yield (0, mintingFunctions_1.scheduledMinting)();
    return null;
}));
exports.issueTokenForViewsFunction = functions.firestore
    .document('ViewRating/{viewRatingId}')
    .onCreate(issueTokenForViews_1.issueTokenForViews);
exports.checkAndUpdateUserGasBalance = functions.https.onCall((data, context) => {
    const { userId, userWalletAddress } = data;
    return (0, updateGasBalance_1.updateUserGasBalance)(userId, userWalletAddress);
});
exports.handleTokenClaims = functions.https.onCall((data, context) => {
    // Extract required parameters from `data` or `context`
    const { userId, amount } = data;
    return (0, processTokenClaims_1.processTokenClaims)(userId, amount);
});
