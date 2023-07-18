//
//  Comments.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
// ** data model **

import Foundation

struct Comment: Identifiable, Codable{
    var id: String = ""
    var userId: String = ""
    var text: String = ""
    var contentId: String = ""
    var parentId: String = "" // Optional, only for replies
    var replies: [Comment] = []
    var isDeleted: Bool = false
    var timestamp: Date = Date()
    var editedTimestamp: Date = Date()
}

