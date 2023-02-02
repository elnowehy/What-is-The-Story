//
//  Ideas.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//

import Foundation

struct Idea {
    var id: String
    var video: String
    var creator: String
    var description: String
    var date: Date // does firebase provide this anyway?
    var votes: Int
    var selected: Bool
}
