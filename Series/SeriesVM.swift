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
    public var seriesIds = [String]()
    public var posterImage = UIImage(systemName: "photo")!
    public var updatePoster = false
    public var trailerData = Data()
    public var updateTrailer = false
    private var seriesManager: SeriesManager

    init() {
        seriesManager = SeriesManager()
    }

    // fetch data from Firebase and populate "profile"
    // input: Profile struct with the profile id populated
    // output: profile struc is populated
    // return: Void
    @MainActor
    func fetch() async {
        self.seriesList = []
        await withTaskGroup(of: Series.self) { group in
            for id in seriesIds {
                group.addTask {
                    self.seriesManager.series = Series()
                    await self.seriesManager.fetch(id: id)
                    return self.seriesManager.series
                }
            }
            for await series in group {
                self.seriesList.append(series)
            }
        }
    }
    
    // create Series document in Firebase and
    // input: empty Series struct
    // output: Series struct is populated
    // return: series Id
    @MainActor
    func create() async -> String {
        seriesManager.posterImage = posterImage
        seriesManager.trailerData = trailerData
        seriesManager.updatePoster = updatePoster
        seriesManager.updateTrailer = updateTrailer
        seriesManager.series = series
        async let seriesId = seriesManager.create()
        series.id = await seriesId
        return await seriesId
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
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
    
}
