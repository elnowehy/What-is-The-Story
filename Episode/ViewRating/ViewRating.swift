//
//  EpisodeViews.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-26.
//

import Foundation

struct ViewRating: Codable {
    var episodeId: String = ""
    var userId: String = ""
    var rating: Int = 0 // 1...5
    var timestamp: Date = Date()
}

