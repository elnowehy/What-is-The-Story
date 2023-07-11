//
//  Answer.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//
// ** data model **

import Foundation

struct Answer: Identifiable {
    var id: String = "" // "pollId_userId"
    var pollId: String = "" // same as episode id
    var userId: String = ""
    var text: String = ""
    var timestamp: Date = Date()
}
