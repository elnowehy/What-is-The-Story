//
//  User.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-05.
//
// Private user information

import Foundation

struct User: Encodable, Decodable, Hashable {
    var uid: String
    var name: String    // I should move this to profile but that means profile will be created right away otherwise use the email "name"@email.com
    var email: String
    var password: String
    var sponsor: String
    var tokens: Int
    var profileId: String = ""
    var invitationId: String = ""
    var witsWallet: String = ""
    var ethWallet: String = ""
    
    init(uid: String, name: String, email: String, password: String, sponsor: String, tokens: Int) {
        self.uid = uid
        self.name = name
        self.email = email
        self.password = password
        self.sponsor = sponsor // should be public?
        self.tokens = tokens   // should be public?
    }
    
    init() {
        self.uid = ""
        self.name = ""
        self.email = ""
        self.password = ""
        self.sponsor = "" // should be public?
        self.tokens = 0   // should be public?
    }
}



