//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation

struct ProfilePage {
    var userName: String = ""
    var statement: String = ""
    var bio: String = ""
    var image: String = ""
    var thumbnail: String = ""
    var bgColor: String = "#ffffff"
}

struct Creations {
    var serieseIds = [String]()
    var videoIds = [String]()
}

struct Contributions {
    var ideaIds = [String]()
    var voteIds = [String]()
    var commentIds = [String]()
}

struct History {
    var likeIds = [String]()
    var viewIds = [String]()
}

struct Profile {
    var id: String
    var landingPage: ProfilePage
    var creations: Creations
    var contributions: Contributions
    var history: History
}

