//
//  Series.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//

import Foundation

struct Series: Identifiable, Codable, Equatable {
    var id: String = ""
    var profile: String = ""
    var title: String = ""
    var categories: Set<String> = []
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
    var trendingScore = 1.0  // vlaue / (k + e^(t - t0) where t: current time, t0: view time, k: factor, e: natural logarithm
    var popularScore = 0 // 0.5 * averageRating + 0.5 * totalViews
    var newScore = 0 // newSeriesScore = (0.6 * (currentDate - releaseDateWeight)) + (0.2 * averageRating) + (0.2 * numberOfRatings)
                     // releaseDateWeight = (currentDate - initialReleaseDate) / (latestReleaseDate - initialReleaseDate)
    
    var averageRating: Double {
        return numberOfRatings == 0 ? 0 : Double(totalRatings) / Double(numberOfRatings)
    }
}
