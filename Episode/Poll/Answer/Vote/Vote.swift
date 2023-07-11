//
//  Vote.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//
// ** data model **

import Foundation

struct Vote: Identifiable {
    var id: String = "" // same as the voter userId
    var answerId: String = "" // "episodeId_userId"
    var timestamp: Date = Date()
}
