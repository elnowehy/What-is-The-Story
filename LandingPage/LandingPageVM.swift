//
//  LandingPageVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-25.
//

import Foundation
import FirebaseFirestore

class LandingPageVM: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil
    @Published var featuredSeries: [Series] = []
    @Published var popularSeries: [Series] = []
    @Published var newSeries: [Series] = []
    @Published var trendingSeries: [Series] = []
    @Published public var featuredPaginator = Paginator<Series>()
    @Published public var popularPaginator = Paginator<Series>()
    @Published public var newPaginator = Paginator<Series>()
    @Published public var trendingPaginator = Paginator<Series>()


    public var seriesVM = SeriesVM()
    private var categoryVM = CategoryVM()

    private var currentPage: Int = 0
    private var pageSize: Int = AppSettings.pageSize

    init() {
        fetchInitialData()
    }

    private func fetchInitialData() {
        Task {
            await fetchCategories()
            await fetchFeaturedSeries()
            await fetchPopularSeries()
            await fetchNewSeries()
            await fetchTrendingSeries()
        }
    }

    @MainActor
    func fetchCategories() async {
        await categoryVM.fetchCategories()
        categories = await categoryVM.categoryList
    }
    
    @MainActor
    func fetchFeaturedSeries() async {
        await featuredPaginator.loadMoreData(fetch: {page, pageSize in
            await self.seriesVM.fetchSeriesList(listType: AppSettings.SeriesListType.featured)
        }, appendTo: &self.featuredSeries)
    }

    @MainActor
    func fetchPopularSeries() async {
        await popularPaginator.loadMoreData(fetch: {page, pageSize in
            await self.seriesVM.fetchSeriesList(listType: AppSettings.SeriesListType.popular)
        }, appendTo: &self.popularSeries)
    }

    @MainActor
    func fetchNewSeries() async {
        await newPaginator.loadMoreData(fetch: {page, pageSize in
            await self.seriesVM.fetchSeriesList(listType: AppSettings.SeriesListType.new)
        }, appendTo: &self.newSeries)
    }

    @MainActor
    func fetchTrendingSeries() async {
        await trendingPaginator.loadMoreData(fetch: {page, pageSize in
            await self.seriesVM.fetchSeriesList(listType: AppSettings.SeriesListType.trending)
        }, appendTo: &self.trendingSeries)
    }

    func selectCategory(_ category: Category) {
        selectedCategory = category
        self.featuredPaginator = Paginator<Series>()
        self.popularPaginator = Paginator<Series>()
        self.newPaginator = Paginator<Series>()
        self.trendingPaginator = Paginator<Series>()
        fetchInitialData()
    }
}
