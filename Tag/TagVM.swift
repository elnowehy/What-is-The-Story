//
//  tagVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-31.
//

import SwiftUI

class TagVM: ObservableObject{
    @Published var tagList = [Tag]()
    private var tagManager = TagManager()
    
    @MainActor
    func fetchTags() {
        Task {
            do {
                self.tagList = try await tagManager.fetchTags()
            } catch {
                print("Error fetching tags:", error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func fetchSeriesIds(tag: String) async throws -> [String] {
        var seriesIds = [String]()
        
        do {
            seriesIds = try await tagManager.fetchContentIds(tag: tag, type: ContentType.series.rawValue)
            
        } catch {
            print(error.localizedDescription)
        }
        
        return seriesIds
    }
    
    @MainActor
    func fetchEpisodeIds(tag: String) async throws -> [String] {
        var seriesIds = [String]()
        do {
            seriesIds = try await tagManager.fetchContentIds(tag: tag, type: ContentType.episode.rawValue)
            
        } catch {
            print(error.localizedDescription)
        }
        return seriesIds
    }
    
    @MainActor
    func addContents(tags: [Tag], id: String, type: ContentType) {
        Task {
            await withTaskGroup(of: Void.self) {group in
                for tag in tags {
                    group.addTask {
                        do {
                            try await self.tagManager.addContentId(tag: tag, id: id, type: type.rawValue)
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
    func removeContents(tags: [Tag], id: String, type: ContentType) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for tag in tags {
                    group.addTask {
                        do {
                            try await self.removeTag(tag: tag, contentId: id, type: type)
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
    func fetchTagSuggestions(prefix: String) async throws -> [Tag] {
        do {
            let suggestions = try await tagManager.fetchTagSuggestions(prefix: prefix.lowercased())
            return suggestions
        } catch {
            throw error
        }
    }

    @MainActor
    func removeTag(tag: Tag, contentId: String, type: ContentType) async throws -> Void {
        do {
            try await tagManager.removeContentId(tag: tag, id: contentId, type: type.rawValue)
            
            if try await tagManager.emptyTag(tagId: tag.id) {
                try tagManager.deleteTag(tagId: tag.id)
            }
        } catch {
            throw error
        }
    }
}
