//
//  Bookmark.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-19.
//
// ** data model **

import Foundation

struct Bookmark: Identifiable {
    var id: String = ""
    var userId: String = ""
    var contentType: ContentType = .episode
    var contentId: String = ""
    var timestamp = Date()
}
