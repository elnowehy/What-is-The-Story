//
//  TagManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-31.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class TagManager {
    private let db = Firestore.firestore()
    private let batch = db.batch()
    private let ref = db.collection("Tags")
    
    func addContentId(tag: Tag, id: String, type: String) async throws {
        let tagRef = ref.document(tag.id)
        let contentRef = tagRef.collection(type)
        
        do {
            let snapshot = try await tagRef.getDocument()
            
            if snapshot.data.isEmpty {
                try await tagRef.setData([:])
            }
            try await contentRef.document(id).setData([:])
        } catch {
            throw error
        }
    }
    
    func removeContentId(tag: Tag, id: String, type: String) async throws {
        let contentRef = ref.document(tag.id).collection(type)
        
        do {
            try await contentRef.document(id).delete()
        } catch {
            throw error
        }
    }

    
    func fetchTags() async throws -> [Tag] {
        var tags = [Tag]()
        do {
            let snapshot = try await ref.getDocuments()
            let ids = snapshot.documents.map { $0.documentID }
            for id in ids {
                let category = Tag(id: id)
                tags.append(category)
            }
            return tags
        } catch {
            throw error
        }
    }
    
    func fetchContentIds(tag: String, type: String) async throws -> [String] {
        var contentIds = [String]()
        
        let seriesRef = ref.document(tag).collection(type)
        do {
            let snapshot = try await seriesRef.getDocuments()
            contentIds = snapshot.documents.map {$0.documentID}
            print("\(snapshot.documents.count)")
        } catch {
            throw error
        }
        
        return contentIds
    }
    
    
    
    func fetchTagSuggestions(prefix: String) async throws -> [Tag] {
        var tags = [Tag]()
        
        let query = ref.whereField("id", isGreaterThanOrEqualTo: prefix)
            .whereField("id", isLessThan: prefix + "\u{f8ff}")
        
        do {
            let snapshot = try await query.getDocuments()
            
            for document in snapshot.documents {
                let tagId = document.documentID
                let tag = Tag(id: tagId)
                tags.append(tag)
            }
        } catch {
            throw error
        }
        
        return tags
    }
    
    func lastTag(tagId: String) async throws -> Bool {
        let seriesSnapshot = try await Firestore.firestore().collection("Tags").document(tagId).collection("series").getDocuments()
        let episodesSnapshot = try await Firestore.firestore().collection("Tags").document(tagId).collection("episodes").getDocuments()

        return seriesSnapshot.isEmpty && episodesSnapshot.isEmpty
    }
    
    func deleteTag(tagId: String) -> Void {
        // Delete the tag document
        let tagRef = db.collection("Tags").document(tagId)
        batch.deleteDocument(tagRef)

        // Delete the "series" subcollection and its documents
        let seriesRef = tagRef.collection("series")
        batch.deleteDocuments(seriesRef)

        // Delete the "episodes" subcollection and its documents
        let episodesRef = tagRef.collection("episodes")
        batch.deleteDocuments(episodesRef)

        // Commit the batched write operation
        batch.commit { error in
            if let error = error {
                print("Error deleting tag and subcollections: \(error.localizedDescription)")
            } else {
                print("Tag and subcollections deleted successfully")
            }
        }

    }
}
