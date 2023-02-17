//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation

struct Page {
    var id: String = ""
    var name: String = ""
    var statement: String = ""
    var bio: String = ""
    var image: String = ""
    var avatar: String = ""
    var bgColor: String = "#ffffff"
}

struct Creations {
    var id: String = ""
    var serieseIds = [String]()
    var videoIds = [String]()
}

struct Contributions {
    var id: String = ""
    var ideaIds = [String]()
    var voteIds = [String]()
    var commentIds = [String]()
}

struct History {
    var id: String = ""
    var likeIds = [String]()
    var viewIds = [String]()
}

struct Profile {
    var id: String = ""
    var page = Page()
    var creations = Creations()
    var contributions = Contributions()
    var history = History()
}

