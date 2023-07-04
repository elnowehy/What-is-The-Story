//
//  SearchVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-23.
//
import SwiftUI

struct SearchResult: Hashable {
    var title: String
    var id: String
    var contentType: ContentType
}

class SearchVM: ObservableObject {
    @Published var searchResults: [SearchResult] = []  
    var seriesPaginator = ArrayPaginator<Series>()
    var episodePaginator = ArrayPaginator<Episode>()
    
    @Published var categories = [Category]()
    @Published var selectedCategories = [Category]()
    private var categoryVM = CategoryVM()
    
    @Published var isSelected = false
    @Published var tagSuggestions = [Tag]()
    private var tagVM = TagVM()
    
    private var seriesVM = SeriesVM()
    private var episodeVM = EpisodeVM()




//    @MainActor
//    init() {
//        Task {
//            await categoryVM.fetchCategories()
//            categories = categoryVM.categoryList
//        }
//    }
    
    @MainActor
    func fetchCategories() {
        Task {
            await categoryVM.fetchCategories()
            categories = categoryVM.categoryList
        }
    }

    // Search function
    @MainActor
    func search(tags: [String]) {
        // Clear the previous results
        resetSearch()
        seriesVM.reset()
        Task {
            do {
                let categories: [String] = selectedCategories.map { $0.id }
                
                var seriesList = Set<String>()
                for category in categories {
                    let list = try await categoryVM.fetchSeriesIds(category: category)
                    seriesList.formUnion(list)
                }
                
                for tag in tags {
                    let list = try await tagVM.fetchSeriesIds(tag: tag)
                    seriesList.formUnion(list)
                    print("\(tag)")
                    print("\(list.count)")
                    print("\(seriesList.count)")
                }
                
                var episodeList = Set<String>()
                for category in categories {
                    let list = try await categoryVM.fetchEpisodeIds(category: category)
                    episodeList.formUnion(list)
                }
                
                for tag in tags {
                    let list = try await tagVM.fetchEpisodeIds(tag: tag)
                    episodeList.formUnion(list)
                }
                
                seriesResult(seriesList: Array(seriesList))
                
                episodeResult(episodeList: Array(episodeList))
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    @MainActor
    func seriesResult(seriesList: [String]) {
        seriesVM.seriesIds = seriesList
        Task {
            do {
                let fetchedSeries = try await seriesPaginator.loadMoreData(fetch: seriesVM.fetch)
                let searchResults = fetchedSeries.map { SearchResult(title: $0.title, id: $0.id, contentType: .series) }
                self.searchResults.append(contentsOf: searchResults)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func episodeResult(episodeList: [String]) {
        episodeVM.episodeIds = episodeList
        Task {
            do {
                let fetchedEpisodes = try await episodePaginator.loadMoreData(fetch: episodeVM.fetch)
                let searchResults = fetchedEpisodes.map { SearchResult(title: $0.title, id: $0.id, contentType: .episode) }
                self.searchResults.append(contentsOf: searchResults)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // Reset search
    func resetSearch() {
        searchResults = []
        seriesPaginator.reset()
        episodePaginator.reset()
    }
    
    func isSelectedCategory(_ category: Category) -> Bool {
        selectedCategories.contains(category)
    }

    
    func toggleCategorySelection(_ category: Category) {
        if isSelectedCategory(category) {
            // If the category is already selected, remove it from the selectedCategories array
            selectedCategories.removeAll { $0 == category }
        } else {
            // If the category is not selected, add it to the selectedCategories array
            selectedCategories.append(category)
        }
    }
    
    @MainActor
    func fetchTagSuggestions(tagPrefix: String) async throws -> [Tag] {
        do {
            tagSuggestions = try await tagVM.fetchTagSuggestions(prefix: tagPrefix)
            return tagSuggestions
        } catch {
            throw error
        }
    }
}

