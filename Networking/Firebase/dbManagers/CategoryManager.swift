//
//  CategoryManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-19.
//

import Foundation
import Firebase
// import FirebaseFireStoreSwift

class CategoryManager {
    private let ref = AppDelegate.db.collection("Categories")

    
    func addContentId(category: Category, id: String, type: String) async throws {
        let contentRef = ref.document(category.id).collection(type)
        
        do {
            try await contentRef.document(id).setData([:])
        } catch {
            throw error
        }
    }
    
    func removeContentId(category: Category, id: String, type: String) async throws {
        let contentRef = ref.document(category.id).collection(type)
        
        do {
            try await contentRef.document(id).delete()
        } catch {
            throw error
        }
    }

    
    func fetchCategories() async throws -> [Category] {
        var categories = [Category]()
        do {
            let snapshot = try await ref.getDocuments()
            let ids = snapshot.documents.map { $0.documentID }
            for id in ids {
                let category = Category(id: id)
                categories.append(category)
            }
            return categories
        } catch {
            throw error
        }
    }
    
    func fetchContentIds(category: String, type: String) async throws -> [String] {
        var contentIds = [String]()
        
        let seriesRef = ref.document(category).collection(type)
        do {
            let snapshot = try await seriesRef.getDocuments()
            contentIds = snapshot.documents.map {$0.documentID}
        } catch {
            throw error
        }
        
        return contentIds
    }
}



