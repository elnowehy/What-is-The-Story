//
//  Video.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//
// ** data model **

import Foundation

struct Episode: Identifiable {
    var id: String = ""
    var userId: String = ""
    var title: String = ""
    // let duration: TimeInterval
    var synopsis: String = ""
    var video : URL = URL(filePath: "")
    // var thumbnail : URL = URL(filePath: "")
    var hasPoll: Bool = false
    var series: String = ""
    var views: Int = 0
    var numOfRatings: Int = 0
    var totalRatings: Int = 0
    var releaseDate = Date()
    var avgRating: Double = 0.0
    var nftContractAddress: String? = nil
    var nftTokenId: String? = nil
    var rewardPerViews: Int = 0
    var rewardExpiryDate: Date = Date()
    var isHidden: Bool = false
    
    var featuredScore: Double {
        let k = 1.0
        let t = Date().timeIntervalSince1970
        let t0 = releaseDate.timeIntervalSince1970
        return Double((numOfRatings /* +  numofComments */)) / (k + exp(t - t0))
        // featuredScore = (numRatings + numComments) / (k + e^(t - t0)) where t: currenttime, t0: release date
    }
}
