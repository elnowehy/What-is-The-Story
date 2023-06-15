//
//  User.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-05.
//
// ** data model **

import Foundation

// read and write for user only
// Firestore path: /User/<documentID>
struct User: Identifiable, Codable {
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var profileIds: [String] = []
    var invitationCode: String = ""
    var witsWallet: String = ""
    var ethWallet: String = ""
    var createdTimestamp = Date()
    var loggedInTimestamp = Date()
}

// read: all, write: system only
// Firestore path: /Users/<documentID>/Info/<main>
struct PublicInfo {
    var id: String = "main"
    var sponsor: String = ""
    var tokens: Int = 0
    var inviteeIDs = [String]()
}

// read: all, write: user
// Firestore path: /Users/<documentID>/Contribution/<main>
struct Contribution {
    var id: String = "main"
    var ideaIds = [String]()
    var voteIds = [String]()
    var commentIds = [String]()
}



