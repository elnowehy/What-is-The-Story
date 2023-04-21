//
//  CategoryManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-19.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class CategoryManager {
    private let db = Firestore.firestore()

    func fetchCategories() async throws -> [Category] {
        let categoriesRef = db.collection("Category")
        
        do {
            let snapshot = try await categoriesRef.getDocuments()
            let categories = snapshot.documents.map { (document) -> Category in
                let name = document.documentID
                return Category(name: name)
            }
            return categories
        } catch {
            throw error
        }
    }
}



