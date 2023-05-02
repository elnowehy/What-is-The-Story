//
//  LandingPageVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-25.
//

import Foundation

class LandingPageVM: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil
    @Published var featuredSeries: [Series] = []
    @Published var popularSeries: [Series] = []
    @Published var newSeries: [Series] = []
    @Published var trendingSeries: [Series] = []

    private var seriesManager = SeriesManager()
    private var categoryVM = CategoryManager()

    private var currentPage: Int = 0
    private var pageSize: Int = 20 // adjust the page size as needed

    // Flags for pagination
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMoreData: Bool = true

    init() {
        fetchInitialData()
    }

    private func fetchInitialData() {
        Task {
            // Fetch initial data for each list
            fetchCategories()
            await fetchFeaturedSeries()
            await fetchPopularSeries()
            await fetchNewSeries()
            await fetchTrendingSeries()
        }
    }

    func fetchCategories() {
        // Fetch categories
    }
    
    private func fetchSeriesList(for listType: SeriesListType) async {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 0
        
        do {
            let seriesList = try await seriesManager.fetchAllSeries(for: listType, category: selectedCategory, page: currentPage, pageSize: pageSize)
            updateSeriesList(listType, with: seriesList)
        } catch {
            print("Error fetching series list: \(error.localizedDescription)")
        }
        
        isLoading = false
    }


    func fetchFeaturedSeries() async {
        await fetchSeriesList(for: .featured)
    }

    func fetchPopularSeries() async {
        await fetchSeriesList(for: .popular)
    }

    func fetchNewSeries() async {
        await fetchSeriesList(for: .new)
    }

    func fetchTrendingSeries() async {
        await fetchSeriesList(for: .trending)
    }

    // Supporting pagination
    func loadMoreSeries(for listType: SeriesListType) async {
        guard !isLoading, hasMoreData else { return }

        isLoading = true
        currentPage += 1

        do {
            let moreSeries = try await seriesManager.fetchAllSeries(for: listType, category: selectedCategory, page: currentPage, pageSize: pageSize)
            if moreSeries.isEmpty {
                hasMoreData = false
            } else {
                updateSeriesList(listType, with: moreSeries)
            }
        } catch {
            print("Error fetching more series: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func selectCategory(_ category: Category) {
        selectedCategory = category
        fetchInitialData()
    }

    private func updateSeriesList(_ listType: SeriesListType, with moreSeries: [Series]) {
        switch listType {
        case .featured:
            featuredSeries.append(contentsOf: moreSeries)
        case .popular:
            popularSeries.append(contentsOf: moreSeries)
        case .new:
            newSeries.append(contentsOf: moreSeries)
        case .trending:
            trendingSeries.append(contentsOf: moreSeries)
        }
    }

    enum SeriesListType {
        case featured
        case popular
        case new
        case trending
    }
}


/*
class LandingPageVM: ObservableObject {
    @Published var categories: [Category] = []
    @Published var featuredSeries: [Series] = []
    @Published var popularSeries: [Series] = []
    @Published var newSeries: [Series] = []
    @Published var trendingSeries: [Series] = []
    private var allSeries: [Series] = []
    
    private var seriesManager = SeriesManager()
    private var categoryVM = CategoryManager()
    
    init() {
        Task {
            do {
                try await loadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadData() async throws {
        let allSeries = try await seriesManager.fetchAllSeries()
    }
    
    func fetchCategories() {
        // fetch categories
        
    }
    
    /* Featured Series Score
     Fundamental Attributes:
     totalRatings: The sum of all the ratings for the series
     numberOfRatings: The total number of ratings the series has received
     releaseDate: The date when the series was released
     Computed Attributes:
     averageRating: totalRatings / numberOfRatings
     releaseDateWeight: (currentDate - releaseDate) / (currentDate - earliestSeriesReleaseDate)
     score: (0.4 * averageRating) + (0.3 * numberOfRatings) + (0.3 * releaseDateWeight)
     */
    @MainActor
    func fetchFeaturedSeries() async {
        // Calculate the scores for each series and store them in a dictionary
        var scores: [String: Double] = [:]
        for series in allSeries {
            let averageRating = Double(series.totalRatings) / Double(series.numberOfRatings)
            let releaseDateWeight = (Date().timeIntervalSince1970 - series.releaseDate.timeIntervalSince1970) / (Date().timeIntervalSince1970 - earliestSeriesReleaseDate.timeIntervalSince1970)
            let score = (0.4 * averageRating) + (0.3 * Double(series.numberOfRatings)) + (0.3 * releaseDateWeight)
            scores[series.id] = score
        }
        
        // Sort the series based on their scores in descending order
        featuredSeries = allSeries.sorted { scores[$0.id]! > scores[$1.id]! }
    }

    
    
    /* Popular Series Score
     
     Fundamental Attributes:
     totalRatings: The sum of all the ratings for the series
     numberOfRatings: The total number of ratings the series has received
     numberOfViews: The total number of views for the series (calculated as the sum of views for all episodes within the series)
     Computed Attributes:
     averageRating: totalRatings / numberOfRatings
     score: (0.5 * averageRating) + (0.5 * numberOfViews)
     */
    func fetchPopularSeries() {
        
    }
    
    
    /* New Series Score

     Fundamental Attributes:
     totalRatings: The sum of all the ratings for the series
     numberOfRatings: The total number of ratings the series has received
     releaseDate: The date when the series was released
     Computed Attributes:
     averageRating: totalRatings / numberOfRatings
     releaseDateWeight: (currentDate - releaseDate) / (currentDate - earliestSeriesReleaseDate)
     score: (0.6 * releaseDateWeight) + (0.2 * averageRating) + (0.2 * numberOfRatings)
     */
    // score = (0.6 * releaseDateWeight) + (0.2 * averageRating) + (0.2 * numberOfRatings) // Or just total rating?
    func fetchNewSeries() {
        
    }
    
    
    /* Trending Series Score
     
     Fundamental Attributes:
     totalRatings: The sum of all the ratings for the series
     numberOfRatings: The total number of ratings the series has received
     numberOfViews: The total number of views for the series (calculated as the sum of views for all episodes within the series)
     previousTotalRatings: The sum of all the ratings for the series one week ago
     previousNumberOfRatings: The total number of ratings the series had one week ago
     previousNumberOfViews: The total number of views for the series one week ago (calculated as the sum of views for all episodes within the series)
     Computed Attributes:
     averageRating: totalRatings / numberOfRatings
     previousAverageRating: previousTotalRatings / previousNumberOfRatings
     ratingIncrease: (averageRating - previousAverageRating) / previousAverageRating
     viewIncrease: (numberOfViews - previousNumberOfViews) / previousNumberOfViews
     score: (0.5 * ratingIncrease) + (0.5 * viewIncrease)
    */
    func fetchTrendingSeries() {
        
    }

}
*/
