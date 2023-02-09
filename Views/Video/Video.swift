//
//  Video.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//

import Foundation
import SwiftUI

struct Video {
    let eid: String //epdisode ID
    let title: String
    let duration: TimeInterval
    let thumbnailImage: Image
    let description: String
    let isEpisode: Bool
    let question: String
    let video: URL
    let votingOpen: Bool
    let creator: String
    let views: Int
    let likes: Int
}
