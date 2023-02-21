//
//  Profile.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation
import Swinject

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

struct Profile: ServiceType {
    var id: String = ""
    var page = Page()
    var creations = Creations()
    
    public static func makeService(for container: Container) -> Self {
        return Profile()
    }
}

