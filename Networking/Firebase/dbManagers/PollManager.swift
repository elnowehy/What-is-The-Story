//
//  PollDataManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PollManager: ObservableObject {
    @Published var poll = Poll()
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
        guard !poll.id.isEmpty else {
            print("Error: poll id can't be empty.")
            return
        }
    
        self.ref = self.db.collection("Poll").document(poll.id)
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.ref?.documentID as? String ?? "",
            "question": self.poll.question,
            "closingDate": self.poll.closingDate,
            "timestamp": Date(),
            "answerIds": self.poll.answerIds,
            "rewardTokens": self.poll.rewardTokens,
        ]
    }
    
    
    func populateStruct() {
        poll.id = self.data["id"] as? String ?? ""
        poll.question = self.data["question"] as? String ?? ""
        poll.answerIds = self.data["answerIds"] as? [String] ?? []
        poll.rewardTokens = self.data["rewardTokens"] as? Double ?? 0.0
        if let closingDate = self.data["closingDate"] as? Timestamp {
            poll.closingDate = closingDate.dateValue()
        }
        if let timestamp = self.data["timestamp"] as? Timestamp {
            poll.timestamp = timestamp.dateValue()
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
    
    func delete() async {
        setRef()
        do {
            try await ref!.delete()
        } catch {
            print(error.localizedDescription)
        }
    }
}
