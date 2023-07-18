//
//  CommentManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-12.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class CommentManager: ObservableObject {
    private var db: Firestore
    private var data: [String: Any]
    
    var coll: CollectionReference {
        db.collection("Comment")
    }
    
    init() {
        self.db = AppDelegate.db
        self.data = [:]
    }

    // Fetch comments for a given contentId
    func fetchComments(for contentId: String) async throws -> [Comment] {
        let querySnapshot = try await db.collection("Comment").whereField("contentId", isEqualTo: contentId).getDocuments()
        var comments = [Comment]()
        for document in querySnapshot.documents {
            var comment = try? document.data(as: Comment.self)
            comment?.id = document.documentID
            if let comment = comment {
                comments.append(comment)
            }
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
        let documentReference = try db.collection("Comment").addDocument(from: comment)
        return try await documentReference.getDocument().data(as: Comment.self)
    }

    // Post a reply to a comment
    func postReply(comment: Comment) async throws -> Comment {
        let documentReference = try db.collection("Comment").addDocument(from: comment)
        return try await documentReference.getDocument().data(as: Comment.self)
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

