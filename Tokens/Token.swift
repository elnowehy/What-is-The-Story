//
//  Token.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
// ** data model **

import Foundation
import FirebaseFirestore

struct Tokens: Identifiable, Codable {
    var id: String = "" // transaction id
    var senderID: String = "" // user id of sender
    var receiverID: String = "" // user id of receiver
    var amount: Int = 0 // amount of tokens transacted
    var timestamp = Date() // transaction timestamp
    var transType: TransType // the type of the transaction

    enum TransType: String, Codable {
        case viewReward = "view_reward"
        case pollReward = "poll_reward"
        case sharedViewReward = "shared_view_reward"
        case claimReward = "claim_reward"
        case transactionTax = "transaction_tax"
        case inheritance = "inheritance"
        case development = "development"
        case others = "others"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case senderID
        case receiverID
        case amount
        case timestamp
        case transType
    }
    
    init(senderID: String, receiverID: String, amount: Int, timestamp: Date = Date(), transType: TransType) {
        self.id = "" // Will be replaced by Firestore-generated ID
        self.senderID = senderID
        self.receiverID = receiverID
        self.amount = amount
        self.timestamp = timestamp
        self.transType = transType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        senderID = try container.decode(String.self, forKey: .senderID)
        receiverID = try container.decode(String.self, forKey: .receiverID)
        amount = try container.decode(Int.self, forKey: .amount)

        let timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.timestamp = timestamp.dateValue() // convert Timestamp to Date

        transType = try container.decode(TransType.self, forKey: .transType)
    }
}


struct Platform {
    var id: String = "platform" // unique ID for platform
    var totalTokens: Int = AppSettings.totalTokens // total tokens in the system for distribution
    var remainingTokens: Int = AppSettings.totalTokens
}


