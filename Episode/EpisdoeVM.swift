//
//  SeriesVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-27.
//

import SwiftUI

class EpisodeVM: ObservableObject{
    @Published var episodeList = [Episode]()
    @Published var episode = Episode()
    @Published var currentPage = 0
    public var episodeIds = [String]()
    public var videoData = Data()
    public var updateVideo = false
    private var episodeManager: EpisodeManager
    var paginator = ArrayPaginator<Episode>()

    init() {
        episodeManager = EpisodeManager()
    }
    
    
    @MainActor
    func fetch() async -> [Episode] {
        let startIndex = currentPage * AppSettings.pageSize
        let endIndex = min(startIndex + AppSettings.pageSize, episodeIds.count)
        if startIndex >= endIndex {
            return episodeList
        }
        
        let pageIds = Array(episodeIds[startIndex..<endIndex])
        
        for id in pageIds {
            if !episodeList.contains(where: {$0.id == id}) {
                let episodeManager = EpisodeManager()
                let episode = await episodeManager.fetch(id: id)
                self.episodeList.append(episode)
            }
        }
        currentPage += 1
        
        return episodeList
    }
    
//    @MainActor
//    func fetchEpisodeByTitle(title: String) async -> [Episode] {
//        episodeList = []
//        
//        episodeList = await self.episodeManager.fetchByQuery(field: "title", prefix: title, pageSize: AppSettings.pageSize)
//        
//        return episodeList
//    }

    @MainActor
    func create() async -> String {
        episodeManager.videoData = videoData
        episodeManager.updateVideo = updateVideo
        episodeManager.episode = episode
        async let episodeId = episodeManager.create()
        episode.id = await episodeId
        return await episodeId
    }
    
    @MainActor
    func update() async {
        episodeManager.videoData = videoData
        episodeManager.updateVideo = updateVideo
        episodeManager.episode = episode
        await episodeManager.update()
    }
    
    func remove() {
        episodeManager.episode = episode
        episodeManager.remove()
        // I'm sure much more needs to be done, e.g. remove from Profile.Creation
        
    }
    
    // Get the next episode
    func getNextEpisode() -> Episode? {
        if let currentIndex = episodeList.firstIndex(where: { $0.id == episode.id }) {
            if currentIndex < episodeList.count - 1 {
                let nextEpisode = episodeList[currentIndex + 1]
                self.episode = nextEpisode
                return nextEpisode
            }
        }
        return nil
    }

    // Get the previous episode
    func getPreviousEpisode() -> Episode? {
        if let currentIndex = episodeList.firstIndex(where: { $0.id == episode.id }) {
            if currentIndex > 0 {
                let previousEpisode = episodeList[currentIndex - 1]
                self.episode = previousEpisode
                return previousEpisode
            }
        }
        return nil
    }

    // Check if there is a previous episode
    func hasPreviousEpisode() -> Bool {
        if let currentIndex = episodeList.firstIndex(where: { $0.id == episode.id }) {
            return currentIndex > 0
        }
        return false
    }

    // Check if there is a next episode
    func hasNextEpisode() -> Bool {
        if let currentIndex = episodeList.firstIndex(where: { $0.id == episode.id }) {
            return currentIndex < episodeList.count - 1
        }
        return false
    }
    
    @MainActor
    func incrementViewCount() {
        Task {
            episode.views += 1
            await update()
        }
    }
    
    @MainActor
    func addRating(rating: Int) async {
        episode.numOfRatings += 1
        episode.totalRatings += rating
        
        episode.avgRating = Double(episode.totalRatings) / Double (episode.numOfRatings)
        await update()
    }
    
    @MainActor
    func updateRating(old: Int, new: Int) async {
        episode.totalRatings -= old
        episode.totalRatings += new
        
        episode.avgRating = Double(episode.totalRatings) / Double (episode.numOfRatings)
        await update()
    }

}

