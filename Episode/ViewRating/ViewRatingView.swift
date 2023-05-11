//
//  ViewRatingView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-09.
//

import SwiftUI

struct ViewRatingView: View {
    @Binding var episode: Episode
    @Binding var showRating: Bool
    @EnvironmentObject var viewRatingVM: ViewRatingVM
    @EnvironmentObject var userVM: UserVM

    var body: some View {
        VStack {
            AvgRatingView(avgRating: $episode.avgRating)
            if showRating {
                UserRatingView()
                    .opacity(showRating ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: showRating)
            }
        }
        .task {
            await userVM.currentUserData()
            viewRatingVM.viewRating.episodeId = episode.id
            viewRatingVM.viewRating.userId = userVM.user.id
            await viewRatingVM.fetch()
        }
    }
}


struct AvgRatingView: View {
    @Binding var avgRating: Double

    var body: some View {
        VStack {
            Text("Average Rating")
            ratingStars(rating: avgRating, isInteractive: false, onTap: nil)
        }
    }
}

struct UserRatingView: View {
    @EnvironmentObject var viewRatingVM: ViewRatingVM
    @EnvironmentObject var episodeVM: EpisodeVM
    @EnvironmentObject var seriesVM: SeriesVM
    
    var body: some View {
        VStack {
            Text("Your Rating")
            if viewRatingVM.isLoading {
                ProgressView()
            } else {
                ratingStars(rating: Double(viewRatingVM.viewRating.rating), isInteractive: true) { selectedRating in
                    Task {
                        if viewRatingVM.firstView {
                            await episodeVM.addRating(rating: selectedRating)
                            await seriesVM.addRating(rating: selectedRating)
                            viewRatingVM.firstView = false
                        } else {
                            let old = viewRatingVM.viewRating.rating
                            let new = selectedRating
                            await episodeVM.updateRating(old: old, new: new)
                            await seriesVM.updateRating(old: old, new: new)
                        }
                        
                        viewRatingVM.viewRating.rating = selectedRating
                        await viewRatingVM.update()
                    }
                }
            }
        }
    }
}
