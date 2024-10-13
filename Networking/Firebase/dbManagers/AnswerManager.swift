//
//  AnswerManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//
import Foundation
import Firebase
// import FirebaseFireStoreSwift

class AnswerManager: ObservableObject {
    @Published var answer = Answer()
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
        guard !answer.id.isEmpty else {
            print("Error: answer id can't be empty.")
            return
        }
    
        self.ref = self.db.collection("Answer").document(answer.id)
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.ref?.documentID as? String ?? "",
            "pollId": self.answer.pollId,
            "userId": self.answer.userId,
            "text": self.answer.text,
            "timestamp": Date(),
        ]
    }
    
    
    func populateStruct() {
        answer.id = self.data["id"] as? String ?? ""
        answer.pollId = self.data["pollId"] as? String ?? ""
        answer.userId = self.data["userId"] as? String ?? ""
        answer.text = self.data["text"] as? String ?? ""
        if let timestamp = self.data["timestamp"] as? Timestamp {
            answer.timestamp = timestamp.dateValue()
        }
    }
    
    @MainActor
    func update() async {
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
    
    @MainActor
    func voteCount() async throws -> Int {
        setRef()
        let votes = try await ref!.collection("Votes").getDocuments().count
        return votes
    }
}
