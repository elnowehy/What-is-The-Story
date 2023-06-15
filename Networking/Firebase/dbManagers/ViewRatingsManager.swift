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
    @Published var selectedEpisodes: [ViewRating] = []
    @Published var usersWhoRated: [String] = []
    private var lastDocument: DocumentSnapshot?
    private var db: Firestore
    private var ref: DocumentReference?
    private var data: [String: Any]
    
    enum FetchResult {
        case success
        case notFound
        case error(Error)
    }
    
    
    init() {
        self.db = AppDelegate.db
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
            "timestamp": Date(),
        ]
    }
    
    
    func populateStruct() {
        viewRating.episodeId = self.data["episodeId"] as? String ?? ""
        viewRating.userId = self.data["userId"] as? String ?? ""
        viewRating.rating = self.data["rating"] as? Int ?? 0
        if let timestamp = self.data["timestamp"] as? Timestamp {
            viewRating.timestamp = timestamp.dateValue()
        }
            
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
    func fetchUserHistory(userId: String, sortOrder: ViewRatingVM.SortOrder, pageSize: Int) async -> [ViewRating]{
        selectedEpisodes = []
        // print("**\(userId)**")
        var query = db.collection("ViewRating").whereField("userId", isEqualTo: userId).limit(to: pageSize)
        
        switch sortOrder {
        case .timestampAscending:
            query = query.order(by: "timestamp")
        case .timestampDescending:
            query = query.order(by: "timestamp", descending: true)
        case .ratingAscending:
            query = query.order(by: "rating")
        case .ratingDescending:
            query = query.order(by: "rating", descending: true)
        }
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        do {
            let documents = try await query.getDocuments()
            for document in documents.documents {
                self.data = document.data()
                populateStruct()
                selectedEpisodes.append(viewRating)
            }
            
            lastDocument = documents.documents.last
            
        } catch {
            print(error.localizedDescription)
        }
        
        return selectedEpisodes
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
    
    func delete() async {
        setRef()
        viewRating.userId = randomString(length: 10)
        await populateData()
        do {
            try await ref!.updateData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
}


