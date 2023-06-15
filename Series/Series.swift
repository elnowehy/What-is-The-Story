//
//  Series.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//
// ** data model **

import Foundation

struct Series: Identifiable, Codable, Equatable {
    var id: String = ""
    var profile: String = ""
    var userId: String = ""
    var title: String = ""
    var categories: Set<String> = []
    var tags: Set<String> = []
    var synopsis: String = ""
    var episodes = [String]()
    var poster = URL(filePath: "")
    var imgQlty = 0.5
    var trailer = URL(filePath: "")
    var initialReleaseDate = Date()
    var latestReleaseDate = Date()
    var totalRatings = 0
    var numberOfRatings = 0
    var totalViews = 0

    var averageRating: Double {
        return numberOfRatings == 0 ? 0 : Double(totalRatings) / Double(numberOfRatings)
    }
    
    var trendingScore: Double {
        let k = 1.0 // factor (customize according to your needs)
        let t = Date().timeIntervalSince1970
        let t0 = initialReleaseDate.timeIntervalSince1970
        return 1.0 / (k + exp(t - t0))
    }
    
    var popularScore: Double {
        return 0.5 * averageRating + 0.5 * Double(totalViews)
    }
    
    var newScore: Double {
        let currentDate = Date().timeIntervalSince1970
        let releaseDateWeight = (currentDate - initialReleaseDate.timeIntervalSince1970) / (latestReleaseDate.timeIntervalSince1970 - initialReleaseDate.timeIntervalSince1970)
        return (0.6 * releaseDateWeight) + (0.2 * averageRating) + (0.2 * Double(numberOfRatings))
    }
}

