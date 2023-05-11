//
//  ViewsManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-28.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class ViewRatingManager: ObservableObject {
    @Published var viewRating = ViewRating()
    @Published var ratedEpisodes: [String] = []
    @Published var usersWhoRated: [String] = []
    private var db: Firestore
    private var ref: DocumentReference?
    private var data: [String: Any]
    
    enum FetchResult {
        case success
        case notFound
        case error(Error)
    }
    
    
    init() {
        self.db = Firestore.firestore()
        self.data = [:]
    }
        
    func setRef() {
        guard !viewRating.userId.isEmpty, !viewRating.episodeId.isEmpty else {
            print("Error: episodeId and userId must be non-empty.")
            return
        }
        
        let compoundDocumentId = viewRating.episodeId + "_" + viewRating.userId
        self.ref = self.db.collection("ViewRating").document(compoundDocumentId)
    }

    @MainActor
    func populateData() async {
        self.data = [
            "episodeId": self.viewRating.episodeId,
            "userId": self.viewRating.userId,
            "rating": self.viewRating.rating,
            "timesamp": Date(),
        ]
    }
    
    
    func populateStruct() {
        viewRating.episodeId = self.data["episodeId"] as? String ?? ""
        viewRating.userId = self.data["userId"] as? String ?? ""
        viewRating.rating = self.data["rating"] as? Int ?? 0
        viewRating.timestamp = self.data["timestamp"] as? Date ?? Date()
    }
    
    @MainActor
    func add() async {
        setRef()
        await populateData()
        do {
            try await ref!.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func fetch() async -> FetchResult {
        setRef()
        do {
            let document = try await ref!.getDocument()
            if document.exists {
                let data = document.data()
                self.data = data!
                self.populateStruct()
                return .success
            } else {
                return .notFound
            }
        } catch {
            return .error(error)
        }
    }
    
    @MainActor
    func update() async {
        setRef()
        await populateData() // I need to think about the avatar image and URL
        do {
            try await ref!.updateData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchAllEpisodesRatedByUser() async {
        ratedEpisodes = []
        let query = db.collection("ViewRating").whereField("userId", isEqualTo: viewRating.userId)
        
        do {
            let documents = try await query.getDocuments()
            for document in documents.documents {
                let episodeId = document.get("episodeId") as? String ?? ""
                ratedEpisodes.append(episodeId)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchAllUsersWhoRatedEpisode() async {
        usersWhoRated = []
        let query = db.collection("ViewRating").whereField("episodeId", isEqualTo: viewRating.episodeId)
        
        do {
            let documents = try await query.getDocuments()
            for document in documents.documents {
                let userId = document.get("userId") as? String ?? ""
                usersWhoRated.append(userId)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func remove() {
        setRef()
        ref!.delete()
    }
}


