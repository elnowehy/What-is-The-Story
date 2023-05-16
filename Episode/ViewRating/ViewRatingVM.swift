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
    @Published var ratedEpisodes: [String] = []
    @Published var usersWhoRated: [String] = []
    @Published var isLoading: Bool = false
    @Published var firstView: Bool = false
    @Published var userId: String = ""
    @Published var viewHistory: [ViewRating] = []
    public var paginator = Paginator<ViewRating>()
    
    
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

//    func fetchAllEpisodesRatedByUser() async {
//        viewRatingManager.viewRating.userId = viewRating.userId
//        await viewRatingManager.fetchUserHistory()
//        ratedEpisodes = viewRatingManager.ratedEpisodes
//    }

    func fetchAllUsersWhoRatedEpisode() async {
        viewRatingManager.viewRating.episodeId = viewRating.episodeId
        await viewRatingManager.fetchAllUsersWhoRatedEpisode()
        usersWhoRated = viewRatingManager.usersWhoRated
    }
    
    @MainActor
    func fetchUserHistory(pageSize: Int) async {
        // print("VM:**\(self.userId)**")
        await paginator.loadMoreData(fetch: { page, pageSize in
            await self.viewRatingManager.fetchUserHistory(pageSize: pageSize, userId: self.userId)
        }, appendTo: &self.viewHistory)
        
        // viewHistory = viewRatingManager.selectedEpisodes
    }
    
    func delete() async {
        await viewRatingManager.delete()

        // Delete the corresponding documents from Firestore
//        let db = Firestore.firestore()
//
//        let sourceDocument = db.collection("sourceCollection").document("sourceDocumentID")
//        let destinationDocument = db.collection("destinationCollection").document("destinationDocumentID")
//
//        do {
//            let documentSnapshot = try await sourceDocument.getDocument()
//            if let data = documentSnapshot.data() {
//                do {
//                    try await destinationDocument.setData(data)
//                } catch {
//                    print("Error writing document: \(error)")
//                }
//            }
//        } catch {
//            print("Error reading document: \(error)")
//        }

    }
    
}
