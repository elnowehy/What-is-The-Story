//
//  Token.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//

import Foundation

struct Token {
    var owner: String
    var source: String
    enum source {
        case view
        case vote
        case commision
        case transfer
    }
}
