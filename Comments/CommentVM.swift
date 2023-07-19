//
//  CommentVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-11.
//

import SwiftUI

class CommentVM: ObservableObject {
    @Published var comments = [Comment]()
    @Published var replyingToComment: Comment?
    @Published var editingComment: Comment?
    @Published var isReplying = false
    @Published var isEditing = false
    @Published var isLoading = true
    private var commentManager = CommentManager()

    @MainActor
    func fetchComments(for contentId: String) async {
        do {
            isLoading = true
            self.comments = try await commentManager.fetchComments(for: contentId)
            isLoading = false
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    @MainActor
    func postComment(text: String, contentId: String, userId: String) async {
        do {
            var comment = Comment()
            comment.contentId = contentId
            comment.userId = userId
            comment.text = text
            comment = try await commentManager.postComment(comment: comment)
            self.comments.append(comment)
        } catch {
            print("Error posting comment: \(error)")
        }
    }
    
    @MainActor
    func postReply(comment: Comment, text: String, userId: String) async {
        do {
            self.isReplying = true
            var reply = Comment()
            reply.text = text
            reply.userId = userId
            reply.parentId = comment.id
            reply.contentId = comment.contentId
            reply.timestamp = Date()
            reply.editedTimestamp = Date()
            _ = try await commentManager.postReply(comment: reply)
            self.isReplying = false
            await self.fetchComments(for: comment.contentId)
        } catch {
            print("Error posting reply: \(error)")
        }
    }

    @MainActor
    func delete(comment: Comment) async {
        do {
            try await commentManager.deleteComment(comment: comment)
            if let index = self.comments.firstIndex(where: { $0.id == comment.id }) {
                self.comments.remove(at: index)
            }
        } catch {
            print("Error deleting comment: \(error)")
        }
    }
    
    @MainActor
    func edit(comment: Comment, with text: String) async {
        do {
            self.isEditing = true
            try await commentManager.editComment(comment: comment, with: text)
            if let index = self.comments.firstIndex(where: { $0.id == comment.id }) {
                self.comments[index].text = text
            }
            self.isEditing = false
        } catch {
            print("Error editing comment: \(error)")
        }
    }
    
//    @MainActor
//    func prepareReply(to comment: Comment) {
//        self.replyingToComment = comment
//        self.isReplying = true
//    }
//
//    @MainActor
//    func prepareEdit(for comment: Comment) {
//        self.editingComment = comment
//        self.isEditing = true
//    }
}

