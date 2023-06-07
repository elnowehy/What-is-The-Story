//
//  Votes.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
// ** data model **

import Foundation

struct Vote {
    var idea: String
    var voter: String
    var date: Date // check with gpt if we need to log this. I think we can get it from firebase anyway
}
