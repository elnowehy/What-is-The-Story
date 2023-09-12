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
    //@Published var featuredSeries: [Series] = []
    @Published var popularSeries: [Series] = []
    @Published var newSeries: [Series] = []
    @Published var trendingSeries: [Series] = []
    // @Published public var featuredPaginator = Paginator<Series, DocumentSnapshot>()
    @Published public var popularPaginator = Paginator<Series, DBPaginatable>()
    @Published public var newPaginator = Paginator<Series, DBPaginatable>()
    @Published public var trendingPaginator = Paginator<Series, DBPaginatable>()


    public var seriesVM = SeriesVM()
    private var categoryVM = CategoryVM()

    private var currentPage: Int = 0
    private var pageSize: Int = AppSettings.pageSize

    init() {
        Task {
            await fetchCategories()
            fetchInitialData()
        }
    }

    private func fetchInitialData() {
        Task {
//            await fetchFeaturedSeries()
            await fetchPopularSeries()
            await fetchNewSeries()
            await fetchTrendingSeries()
        }
    }

    @MainActor
    func fetchCategories() async {
        await categoryVM.fetchCategories()
        categories = categoryVM.categoryList
    }
    
//    @MainActor
//    func fetchFeaturedSeries() async {
//        await featuredPaginator.loadMoreData(fetch: { page, pageSize in
//            await self.seriesVM.fetchSeriesList(listType: SeriesListType.featured, category: self.selectedCategory)
//        }, appendTo: &self.featuredSeries)
//    }

    @MainActor
    func fetchPopularSeries() async {
        await popularPaginator.loadMoreData(fetch: {page in
            await self.seriesVM.fetchSeriesList(listType: SeriesListType.popular, category: self.selectedCategory)
        }, appendTo: &self.popularSeries)
    }

    @MainActor
    func fetchNewSeries() async {
        await newPaginator.loadMoreData(fetch: {page in
            await self.seriesVM.fetchSeriesList(listType: SeriesListType.new, category: self.selectedCategory)
        }, appendTo: &self.newSeries)
    }

    @MainActor
    func fetchTrendingSeries() async {
        await trendingPaginator.loadMoreData(fetch: {page in
            await self.seriesVM.fetchSeriesList(listType: SeriesListType.trending, category: self.selectedCategory)
        }, appendTo: &self.trendingSeries)
    }

    @MainActor
    func selectCategory(_ category: Category) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
        self.popularSeries = []
        self.newSeries = []
        self.trendingSeries = []
        // self.featuredPaginator.reset()
        self.popularPaginator.reset()
        self.newPaginator.reset()
        self.trendingPaginator.reset()
        fetchInitialData()
        
    }
}
