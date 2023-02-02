//
//  User.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-05.
//

import Foundation

struct User: Encodable, Decodable, Hashable {
    var uid: String
    var name: String
    var email: String
    var password: String
    var sponsor: String
    var tokens: Int
    
    init(uid: String, name: String, email: String, password: String, sponsor: String, tokens: Int) {
        self.uid = uid
        self.name = name
        self.email = email
        self.password = password
        self.sponsor = sponsor
        self.tokens = tokens
    }
}

