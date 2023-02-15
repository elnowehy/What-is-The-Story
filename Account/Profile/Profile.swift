//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation

struct Profile: Identifiable {
    var id: String
    
    // landing Page
    var name: String = ""
    var title: String = ""
    var bio: String = ""
    var image: String = ""
    var thumbnail: String = ""
    var bgColor: String = "#ffffff"
    
    // Creations
    var serieseIds = [String]()
    var videoIds = [String]()
    
    // Contributions
    var ideaIds = [String]()
    var voteIds = [String]()
    var commentIds = [String]()
    
    // History
    var likeIds = [String]()
    var viewIds = [String]()
    
}
