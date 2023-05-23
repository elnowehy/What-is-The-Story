//
//  Bookmark.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-19.
//

import Foundation

struct Bookmark: Identifiable {
    var id: String = ""
    var userId: String = ""
    var contentType: ContentType = .episode
    var contentId: String = ""
    var timestamp = Date()
}

enum ContentType: String {
    case episode
    case series
}
