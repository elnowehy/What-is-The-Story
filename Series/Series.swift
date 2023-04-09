//
//  Series.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//

import Foundation

struct Series: Identifiable {
    var id: String = ""
    var profile: String = ""
    var title: String = ""
    var genre: String = ""
    var synopsis: String = ""
    var episodes = [String]()
    var poster = URL(filePath: "")
    var imgQlty = 0.5
    var trailer = URL(filePath: "")
    var rating = 1...5
}
