//
//  SearchVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-23.
//
import SwiftUI

struct SearchResult: Hashable {
    var title: String
    var description: String
}

class SearchVM: ObservableObject {
    @Published var searchResults: [SearchResult] = []  
    @Published var paginator = Paginator<SearchResult>()
    private let pageSize = 20

    private var seriesVM = SeriesVM()  // assuming you have a SeriesVM
    private var episodeVM = EpisodeVM()  // assuming you have an EpisodeVM
    private var profileVM = ProfileVM()  // using your existing ProfileVM
    
    enum SearchAttribute {
        case all, seriesTitle, episodeTitle, profile, category
    }


    // Search function
    @MainActor
    func search(query: String, by attribute: SearchAttribute) {
        // Clear the previous results
        resetSearch()
        Task {
            switch attribute {
            case .all:
                await fetchAllByKeyword(keyword: query)
            case .seriesTitle:
                await fetchSeriesByTitle(title: query)
            case .episodeTitle:
                await fetchEpisodesByTitle(title: query)
            case .profile:
                await fetchProfileByBrand(brand: query)
                
            case .category:
                await fetchSeriesByCategory(category: query)
            }
        }
    }

    // Fetch all (series, episodes, profiles) by keyword
    @MainActor
    func fetchAllByKeyword(keyword: String) async {
        // Here, you may fetch series, episodes, and profiles which title (or other related field) matches the keyword
        // Fetch data, then add the results to searchResults
        await fetchProfileByBrand(brand: keyword)
        await fetchSeriesByTitle(title: keyword)
        await fetchEpisodesByTitle(title: keyword)
        // await fetchSeriesByCategory(category: keyword)
        
    }

    // Fetch series by title
    @MainActor
    func fetchSeriesByTitle(title: String) async {
        await paginator.loadMoreData(fetch: { [self] page, pageSize in
            let list = await seriesVM.fetchSeriesByTitle(title: title)
            var results = [SearchResult]()
            for series in list {
                let searchResult = SearchResult(title: series.title, description: series.synopsis)
                results.append(searchResult)
            }
            return results
        }, appendTo: &self.searchResults)
    }

    // Fetch episodes by title
    @MainActor
    func fetchEpisodesByTitle(title: String) async {
        // Fetch episodes from Firebase where title starts with title
        await paginator.loadMoreData(fetch: { [self] page, pageSize in
            let list = await self.episodeVM.fetchEpisodeByTitle(title: title)
            let results = [SearchResult]()
            for episode in list {
                let searchResult = SearchResult(title: episode.title, description: episode.synopsis)
                searchResults.append(searchResult)
            }
            return results
        }, appendTo: &self.searchResults)
    }

    // Fetch series by category
    @MainActor
    func fetchSeriesByCategory(category: String) async {
        await paginator.loadMoreData(fetch: { [self] page, pageSize in
            let list = await seriesVM.fetchSeriesByCategory(category: category)
            let results = [SearchResult]()
            for series in list {
                let searchResult = SearchResult(title: series.title, description: series.synopsis)
                searchResults.append(searchResult)
            }
            return results
        }, appendTo: &self.searchResults)
    }
    
    // Fetch profiles by brand
    @MainActor
    func fetchProfileByBrand(brand: String) async {
        await paginator.loadMoreData(fetch: { [self] page, pageSize in
            let list = await profileVM.fetchProfileByBrand(brand: brand)
            var results = [SearchResult]()
            for (profile, statement) in list {
                let searchResult = SearchResult(title: profile.brand, description: statement)
                results.append(searchResult)
            }
            return results
        }, appendTo: &self.searchResults)
    }

    // Reset search
    func resetSearch() {
        searchResults = []
    }
}

