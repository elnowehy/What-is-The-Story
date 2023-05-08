//
//  ViewsVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-28.
//

import Foundation

class ViewRatingVM: ObservableObject {
    @Published var viewRating = ViewRating()
    private var episodeManager = EpisodeManager()
    private var seriesManager =  SeriesManager()
    private var viewRatingManager = ViewRatingManager()
//    public var episodeId: String = ""
//    public var userId: String = ""
    @Published var ratedEpisodes: [String] = []
    @Published var usersWhoRated: [String] = []
    
    init() {
        print("calling ViewRatingVM")
    }
    
    deinit {
        print("deallocating ViewRatingVM")
    }

    
    func handleViewCount() {
        // Add an entry to the Views database
        Task {
            viewRatingManager.viewRating = viewRating
            await viewRatingManager.add()
            
            // Increment the views count for the Episode
            await incrementEpisodeViews()
            
            // Increment the totalViews count for the Series
            await incrementSeriesTotalViews()
        }
    }

    private func incrementEpisodeViews() async {
        // Fetch the Episode with the given episodeId from the EpisodeDatabase
        
        await episodeManager.fetch(id: viewRating.episodeId)
        
        // Increment the views count for the fetched Episode
        episodeManager.episode.views += 1
        // Update the Episode in the EpisodeDatabase with the new views count
        await episodeManager.update()
    }

    private func incrementSeriesTotalViews() async {
        // Fetch the Episode with the given episodeId from the EpisodeDatabase
        // Fetch the Series related to the fetched Episode from the SeriesDatabase
        // Increment the totalViews count for the fetched Series
        // Update the Series in the SeriesDatabase with the new totalViews count

        // Alternatively, call a function in SeriesVM to handle this logic
    }

    func saveUserRating() async {
        // Update user's rating in the ViewsRatings database
        // Implement the logic to interact with your database or API here
        await viewRatingManager.fetch()
        if viewRatingManager.viewRating.rating != 0 {
            await viewRatingManager.update()
        }
        
        // update episode rating
        await episodeManager.fetch(id: viewRating.episodeId)
        episodeManager.episode.numOfRatings += 1
        episodeManager.episode.totalRatings += 1
        
        episodeManager.episode.avgRating = Double(episodeManager.episode.totalRatings / episodeManager.episode.numOfRatings)
        await episodeManager.update()
        
        // update series rating
        seriesManager.series.id = episodeManager.episode.series
        await seriesManager.fetch(id: seriesManager.series.id)
        seriesManager.series.totalRatings += viewRating.rating
        seriesManager.series.numberOfRatings += 1
        await seriesManager.update()
    }


    func fetchViewRating() async {
        // Set the userId in the viewRatingManager
        viewRatingManager.viewRating.userId = viewRating.userId
        // Set the episodeId in the viewRatingManager
        viewRatingManager.viewRating.episodeId = viewRating.episodeId

        // Fetch user's rating from the ViewsRatings database
        await viewRatingManager.fetch()
    }

    func fetchAllEpisodesRatedByUser() async {
        viewRatingManager.viewRating.userId = viewRating.userId
        await viewRatingManager.fetchAllEpisodesRatedByUser()
        ratedEpisodes = viewRatingManager.ratedEpisodes
    }

    func fetchAllUsersWhoRatedEpisode() async {
        viewRatingManager.viewRating.episodeId = viewRating.episodeId
        await viewRatingManager.fetchAllUsersWhoRatedEpisode()
        usersWhoRated = viewRatingManager.usersWhoRated
    }
    
}
