//
//  CategoryVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-19.
//

import SwiftUI

class CategoryVM: ObservableObject{
    @Published var categoryList = [Category]()
    private var categoryManager = CategoryManager()
    
    @MainActor
    func fetchCategories() async {
        do {
            self.categoryList = try await categoryManager.fetchCategories()
        } catch {
            print("Error fetching categories:", error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchSeriesIds(category: String) async throws -> [String] {
        var seriesIds = [String]()
        
        do {
            seriesIds = try await categoryManager.fetchContentIds(category: category, type: ContentType.series.rawValue)
            return seriesIds
        } catch {
            throw error
        }
        
    }
    
    @MainActor
    func fetchEpisodeIds(category: String) async throws -> [String] {
        var episodeIds = [String]()
        
        do {
            episodeIds = try await categoryManager.fetchContentIds(category: category, type: ContentType.episode.rawValue)
            return episodeIds
        } catch {
            throw error
        }
    }
    
    @MainActor
    func addContents(categories: [Category], id: String, type: ContentType) {
        Task {
            await withTaskGroup(of: Void.self) {group in
                for category in categories {
                    group.addTask {
                        do {
                            try await self.categoryManager.addContentId(category: category, id: id, type: type.rawValue)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                await group.waitForAll()
            }
        }
    }
    
    @MainActor
    func removeContents(categories: [Category], id: String, type: ContentType) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for category in categories {
                    group.addTask {
                        do {
                            try await self.categoryManager.removeContentId(category: category, id: id, type: type.rawValue)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                await group.waitForAll()
            }
        }
    }

}

