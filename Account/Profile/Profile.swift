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
    var id: String = ""
    var brand: String = ""
    var statement: String = ""
    var bio: String = ""
    var image: String = ""
    var avatar: String = ""
    var bgColor: String = "#ffffff"
    public static func makeService(for container: Container) -> Self {
        return Profile()
    }
}


// read: public, write: user
// Firestore path: "/Profiles/<DocumentID>/Creation/<main>"
struct Creation {
    var id: String = "main"
    var serieseIds = [String]()
    var videoIds = [String]()
}




