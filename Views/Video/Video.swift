//
//  Video.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//

import Foundation

struct Video: Identifiable {
    let id: String //epdisode ID
    let title: String
    let duration: TimeInterval
    let thumbnail: String
    let synopsis: String
    let question: String
    let video: URL
    let votingOpen: Bool
    let creator: String
    let series: String
    let views: Int
    let likes: Int
}
