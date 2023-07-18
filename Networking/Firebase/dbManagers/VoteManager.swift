//
//  VoteManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class VoteManager: ObservableObject {
    @Published var vote = Vote()
    var userId: String = ""
    private var db: Firestore
    private var ref: DocumentReference?
    private var data: [String: Any]

    init() {
        self.db = AppDelegate.db
        self.data = [:]
    }
        
    func setRef() {
        guard !vote.id.isEmpty else {
            print("Error: vote id can't be empty.")
            return
        }
        self.ref = self.db.collection("Answer").document(vote.answerId).collection("Votes").document(vote.id)
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.ref?.documentID as? String ?? "",
            "answerId": self.vote.answerId,
            "timestamp": Date(),
        ]
    }
    
    
    func populateStruct() {
        vote.id = self.data["id"] as? String ?? ""
        vote.answerId = self.data["answerId"] as? String ?? ""
        if let timestamp = self.data["timestamp"] as? Timestamp {
            vote.timestamp = timestamp.dateValue()
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
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                return .networkError(error)
            } else {
                return .otherError(error)
            }
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
