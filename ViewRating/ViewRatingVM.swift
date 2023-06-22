//
//  ViewsVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-28.
//

import Foundation
import FirebaseFirestore

class ViewRatingVM: ObservableObject {
    @Published var viewRating = ViewRating()
    private var episodeManager = EpisodeManager()
    private var seriesManager =  SeriesManager()
    private var viewRatingManager = ViewRatingManager()
    @Published var ratedEpisodes: [String] = []
    @Published var usersWhoRated: [String] = []
    @Published var isLoading: Bool = false
    @Published var firstView: Bool = false
    @Published var userId: String = ""
    @Published var viewHistory: [ViewRating] = []
    public var paginator = Paginator<ViewRating, DBPaginatable>()
    
    enum SortOrder {
        case timestampAscending
        case timestampDescending
        case ratingAscending
        case ratingDescending
    }

    
    
    func add() {
        // Add an entry to the Views database
        Task {
            viewRatingManager.viewRating = viewRating
            await viewRatingManager.add()
        }
    }

    func update() async {
        // Update user's rating in the ViewsRatings database
        // Implement the logic to interact with your database or API here
        // await viewRatingManager.fetch()
        if viewRating.rating != 0 {
            viewRatingManager.viewRating.rating = viewRating.rating
            await viewRatingManager.update()
        }
    }

    @MainActor
    func fetch() async {
        // Set the userId in the viewRatingManager
        viewRatingManager.viewRating.userId = viewRating.userId
        // Set the episodeId in the viewRatingManager
        viewRatingManager.viewRating.episodeId = viewRating.episodeId

        // Fetch user's rating from the ViewsRatings database
        isLoading = true
        let result = await viewRatingManager.fetch()
        switch result {
        case .success:
            self.viewRating = viewRatingManager.viewRating
            firstView = false
        case .notFound:
            firstView = true
        case .error(let error):
            print(error.localizedDescription)
        }
        isLoading = false
    }

    func fetchAllUsersWhoRatedEpisode() async {
        viewRatingManager.viewRating.episodeId = viewRating.episodeId
        await viewRatingManager.fetchAllUsersWhoRatedEpisode()
        usersWhoRated = viewRatingManager.usersWhoRated
    }
    
    @MainActor
    func fetchUserHistory(sortOrder: SortOrder) async {
 
        do {
            await paginator.loadMoreData(fetch: { page, pageSize in
                return try await self.viewRatingManager.fetchUserHistory( userId: self.userId, sortOrder: sortOrder)
            }, appendTo: &self.viewHistory)
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func delete() async {
        await viewRatingManager.delete()
    }
    
}
