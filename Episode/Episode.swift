//
//  Video.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//

import Foundation

struct Episode: Identifiable {
    var id: String = ""
    var title: String = ""
    // let duration: TimeInterval
    var synopsis: String = ""
    var question: String = ""
    var video : URL = URL(filePath: "")
    // var thumbnail : URL = URL(filePath: "")
    var votingOpen: Bool = false
    var pollClosingDate: Date = Date()
    var series: String = ""
    var views: Int = 0
    var numOfRatings: Int = 0
    var avgRating : Int = 0 // look in to having this as a computed property
    var releaseDate = Date()
    var featuredScore = 0 // featuredScore = (numRatings + numComments) / (k + e^(t - t0)) where t: currenttime, t0: release date
}
