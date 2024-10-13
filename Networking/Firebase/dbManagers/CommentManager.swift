//
//  CommentManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-12.
//

import Foundation
import Firebase
// import FirebaseFireStoreSwift

class CommentManager: ObservableObject {
    private var db: Firestore
    private var data: [String: Any]
    private var userManager = UserManager()
    
    var coll: CollectionReference {
        db.collection("Comment")
    }
    
    init() {
        self.db = AppDelegate.db
        self.data = [:]
    }
    
    @MainActor
    func populateData(comment: Comment) {
        self.data = [
            "userId": comment.userId,
            "text": comment.text,
            "contentId": comment.contentId,
            "parentId": comment.parentId,
            "isDelete": comment.isDeleted,
            "timestamp": comment.timestamp,
            "editedTimestamp": comment.editedTimestamp,
        ]
    }
    
    @MainActor
    func populateStruct(data: [String: Any]) async -> Comment {
        var comment = Comment()
        comment.userId = data["userId"] as? String ?? ""
        comment.text = data["text"] as? String ?? ""
        comment.contentId = data["contentId"] as? String ?? ""
        comment.parentId = data["parentId"] as? String ?? ""
        comment.isDeleted = data["isDeleted"] as? Bool ?? false
        comment.timestamp = data["timestamp"] as? Date ?? Date()
        comment.editedTimestamp = data["editedTimestamp"] as? Date ?? Date()
        
        if let userId = data["userId"] as? String {
            do {
                userManager.user.id = userId
                try await userManager.fetch()
                comment.userName = userManager.user.name
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return comment
    }


    // Fetch comments for a given contentId
    @MainActor
    func fetchComments(for contentId: String) async throws -> [Comment] {
        let querySnapshot = try await db.collection("Comment").whereField("contentId", isEqualTo: contentId).getDocuments()
        var comments = [Comment]()
        for document in querySnapshot.documents {
            let data = document.data()
            var comment = await populateStruct(data: data)
            comment.id = document.documentID
            comments.append(comment)
        }
        
        var rootComments = [Comment]()
        var replies = [Comment]()
        
        for comment in comments {
            if comment.parentId.isEmpty {
                rootComments.append(comment)
            } else {
                replies.append(comment)
            }
        }
        
        for reply in replies {
            if let index = rootComments.firstIndex(where: { $0.id == reply.parentId }) {
                rootComments[index].replies.append(reply)
            }
        }
        
        return rootComments
    }

    
    // Post a comment
    func postComment(comment: Comment) async throws -> Comment {
        await populateData(comment: comment)
        let documentReference = try await db.collection("Comment").addDocument(data: self.data)
        var posted = comment
        posted.id = documentReference.documentID
        return posted
    }

    // Post a reply to a comment
    func postReply(comment: Comment) async throws -> Comment {
        await populateData(comment: comment)
        let documentReference = try await db.collection("Comment").addDocument(data: self.data)
        var reply = comment
        reply.id = documentReference.documentID
        return reply
    }
    
    // Delete a comment
    func deleteComment(comment: Comment) async throws {
        try await db.collection("Comment").document(comment.id).updateData(["isDeleted" : true])
    }
    
    // Edit a comment
    func editComment(comment: Comment, with text: String) async throws {
        try await db.collection("Comment").document(comment.id).updateData(["text" : text, "editedTimestamp": Date()])
    }
}

