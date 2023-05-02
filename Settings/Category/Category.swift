//
//  Category.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-19.
//

import Foundation

struct Category: Identifiable, Codable, Equatable {
    let name: String
    
    var id: String {
        return name
    }
}
