//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI

// read: pubic write: user
// Firestore path: /Profiles/<documentID>
struct Profile {
    var id: String = "" // profileId
    var brand: String = ""
    var avatar = URL(filePath: "")
    var imgQlty = 0.2
    var seriesIds = [String]()
    var timestamp = Date()
}

struct ProfileInfo {
    var id: String = "" // profileId
    var statement: String = ""
    var bio: String = ""
    var photo = URL(filePath: "")
    var background = URL(filePath: "")
    var photoQlty = 0.2
    var bgQlty = 0.2
}





