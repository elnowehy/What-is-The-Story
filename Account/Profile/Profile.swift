//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI

// read: pubic write: user
// ** data model **

struct Profile {
    var id: String = "" // profileId
    var userId: String = ""
    var brand: String = ""
    var tagline: String = ""
    var avatar = URL(filePath: "")
    var imgQlty = 0.2
    var seriesIds = [String]()
    var timestamp = Date()
}

struct ProfileInfo {
    var id: String = "" // profileId
    var bio: String = ""
    var photo = URL(filePath: "")
    var background = URL(filePath: "")
    var photoQlty = 0.2
    var bgQlty = 0.2
}





