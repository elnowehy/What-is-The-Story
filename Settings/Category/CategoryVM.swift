//
//  CategoryVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-19.
//

import SwiftUI

class CategoryVM: ObservableObject{
    @Published var categoryList = [Category]()
    
    @MainActor
    func fetch() {
        let categoryManager = CategoryManager()
        
        Task {
            do {
                let categories = try await categoryManager.fetchCategories()
                self.categoryList = categories
            } catch {
                print("Error fetching categories:", error.localizedDescription)
            }
        }
    }
}

