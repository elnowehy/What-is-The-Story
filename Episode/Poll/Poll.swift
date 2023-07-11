//
//  File.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//
// ** data model **

import Foundation

struct Poll: Identifiable {
    var id: String = "" // same as the episode id
    var question: String = ""
    var closingDate: Date = Date()
    var timestamp: Date = Date()
    var answerIds: [String] = [] // "pollId_userId"
}
