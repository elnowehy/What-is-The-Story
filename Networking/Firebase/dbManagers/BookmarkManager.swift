//
//  BookmarkManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-19.
//

import Foundation
import Firebase
// import FirebaseFireStoreSwift

class BookmarkManager: ObservableObject {
    @Published var bookmark = Bookmark()
    @Published var bookmarked: [Bookmark] = []
    @Published var userIds = [String]()
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
        guard !bookmark.userId.isEmpty, !bookmark.contentId.isEmpty else {
            print("Error: episodeId and userId must be non-empty.")
            return
        }
        
        let compoundDocumentId = bookmark.contentId + "_" + bookmark.userId
        self.ref = self.db.collection("Bookmark").document(compoundDocumentId)
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.ref?.documentID as? String ?? "",
            "contentId": self.bookmark.contentId,
            "userId": self.bookmark.userId,
            "contentType": self.bookmark.contentType.rawValue,
            "timestamp": Date(),
        ]
    }
    
    
    func populateStruct() {
        bookmark.id = self.data["id"] as? String ?? ""
        bookmark.contentId = self.data["contentId"] as? String ?? ""
        bookmark.userId = self.data["userId"] as? String ?? ""
        if let contentTypeString = self.data["contentType"] as? String {
            bookmark.contentType = ContentType(rawValue: contentTypeString) ?? .episode // Defaulting to .episode if conversion fails
        }
        if let timestamp = self.data["timestamp"] as? Timestamp {
            bookmark.timestamp = timestamp.dateValue()
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
    func fetchUserBookmarks(userId: String, sortOrder: BookmarkVM.SortOrder, startAfter: DBPaginatable? = nil) async throws -> PaginatedResult<Bookmark, DBPaginatable> {
        
        var bookmarked: [Bookmark] = []
        var query = db.collection("Bookmark").whereField("userId", isEqualTo: userId).limit(to: AppSettings.pageSize)
        
        switch sortOrder {
        case .timestampAscending:
            query = query.order(by: "timestamp")
        case .timestampDescending:
            query = query.order(by: "timestamp", descending: true)
        }
        
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter.document)
        }
        
        let documents = try await query.getDocuments()
        for document in documents.documents {
            self.data = document.data()
            populateStruct()
            bookmarked.append(bookmark)
        }
        
        let lastDocument = documents.documents.last.map { DBPaginatable(document: $0) }
        return PaginatedResult(items: bookmarked, lastItem: lastDocument)
    }


    
    
    func delete() async {
        setRef()
        do {
            try await ref!.delete()
        } catch {
            print(error.localizedDescription)
        }
    }
}


