//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation
import Swinject

// read: pubic write: user
// Firestore path: /Profiles/<documentID>
struct Profile: ServiceType {
    var id: String = "" // profileId
    var brand: String = ""
    var avatar: String = ""
    
    public static func makeService(for container: Container) -> Self {
        return Profile()
    }
}

struct ProfileInfo {
    var id: String = "" // profileId
    var statement: String = ""
    var bio: String = ""
    var image: String = ""
    var bgColor: String = "#ffffff"
}


// read: public, write: user
// Firestore path: "/Profiles/<DocumentID>/Creation/<main>"
struct Creation {
    var id: String = "" // profileId
    var serieseIds = [String]()
    var videoIds = [String]()
}




