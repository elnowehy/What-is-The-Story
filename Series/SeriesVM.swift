//
//  SeriesVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-27.
//

import SwiftUI

class SeriesVM: ObservableObject{
    @Published var seriesList = [Series]()
    @Published var series = Series()
    @Published var currentPage = 0
    public var seriesIds = [String]()
    public var posterImage = UIImage(systemName: "photo")!
    public var updatePoster = false
    public var trailerData = Data()
    public var updateTrailer = false
    private var seriesManager = SeriesManager()


    @MainActor
    func fetch() async -> [Series] {
        let startIndex = currentPage * AppSettings.pageSize
        let endIndex = min(startIndex + AppSettings.pageSize, seriesIds.count)
        
        if startIndex >= endIndex {
            print("this shouldn't happen: startIndex\(startIndex), endIndex\(endIndex)")
            return seriesList
        }
        let pageIds = Array(seriesIds[startIndex..<endIndex])

        for id in pageIds {
            let seriesManager = SeriesManager()
            let series = await seriesManager.fetch(id: id)
            seriesList.append(series)
        }
        
        currentPage += 1
        return seriesList
    }

    
    @MainActor
    func fetchSeriesList<PaginatableItem: Paginatable>(listType: AppSettings.SeriesListType, category: Category? = nil, lastDocument: PaginatableItem? = nil) async -> PaginatedResult<Series, PaginatableItem> {
        var paginatedSeries = PaginatedResult<Series, PaginatableItem>(items: [], lastItem: nil)
        
        do {
            paginatedSeries = try await self.seriesManager.fetchAllSeries(listType: listType, category: category, startAfter: lastDocument)
        } catch {
            print(error.localizedDescription)
        }
        return paginatedSeries
    }
    
    @MainActor
    func fetchSeriesByCategory(category: String) async -> [Series] {
        seriesList = []
        do {
            seriesList = try await self.seriesManager.fetchSeriesByCategory(category: category)
        } catch {
            print(error.localizedDescription)
        }
        return seriesList
    }
    
    @MainActor
    func create() async -> String {
        seriesManager.posterImage = posterImage
        seriesManager.trailerData = trailerData
        seriesManager.updatePoster = updatePoster
        seriesManager.updateTrailer = updateTrailer
        seriesManager.series = series
        async let seriesId = seriesManager.create()
        series.id = await seriesId
        seriesList.append(series)
        seriesIds.append(series.id)
        return await seriesId
    }
    

    @MainActor
    func update() async {
        seriesManager.posterImage = posterImage
        seriesManager.trailerData = trailerData
        seriesManager.updatePoster = updatePoster
        seriesManager.updateTrailer = updateTrailer
        seriesManager.series = series
        await seriesManager.update()
    }
    
    // remove a profile from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func remove() {
        seriesManager.series = series
        seriesManager.remove()
        // I'm sure much more needs to be done, e.g. remove from Profile.Creation
        
    }
    
    // this function has to be called after the series has been
    // created and we already have the seriesId
    @MainActor
    func addEpisode(episodeId: String) async  {
        seriesManager.series = self.series
        await seriesManager.addEpisode(episodeId: episodeId)
        series.episodes.append(episodeId)
    }
    
    @MainActor
    func removeEpisode(episodeId: String) async {
        await seriesManager.removeEpisode(episodeId: episodeId)
        
        series.episodes.removeAll { id in
            episodeId == id
        }
        
    }
    
    @MainActor
    func incrementViewCount()  {
        Task {
            series.totalViews += 1
            await update()
        }
    }
    
    @MainActor
    func addRating(rating: Int) async {
        series.numberOfRatings += 1
        series.totalRatings += rating
        await update()
    }
    
    @MainActor
    func updateRating(old: Int, new: Int) async {
        series.totalRatings -= old
        series.totalRatings += new
        await update()
    }
    
    func reset() {
        currentPage = 0
        seriesList = []
    }
    
}
