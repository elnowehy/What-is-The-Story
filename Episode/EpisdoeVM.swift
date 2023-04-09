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
    public var episodeIds = [String]()
    public var videoData = Data()
    public var updateVideo = false
    private var episodeManager: EpisodeManager

    init() {
        episodeManager = EpisodeManager()
    }

    // fetch data from Firebase and populate "profile"
    // input: Profile struct with the profile id populated
    // output: profile struc is populated
    // return: Void
    // @MainActor
    func fetch() async {
        self.episodeList = []
        await withTaskGroup(of: Episode.self) { group in
            for id in episodeIds {
                group.addTask {
                    self.episodeManager.episode = Episode()
                    await self.episodeManager.fetch(id: id)
                    return self.episodeManager.episode
                }
            }
            for await episode in group {
                self.episodeList.append(episode)
            }
        }
    }
    
    // create Series document in Firebase and
    // input: empty Series struct
    // output: Series struct is populated
    // return: series Id
    @MainActor
    func create() async -> String {
        episodeManager.videoData = videoData
        episodeManager.updateVideo = updateVideo
        episodeManager.episode = episode
        async let episodeId = episodeManager.create()
        episode.id = await episodeId
        return await episodeId
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
    @MainActor
    func update() async {
        episodeManager.videoData = videoData
        episodeManager.updateVideo = updateVideo
        episodeManager.episode = episode
        await episodeManager.update()
    }
    
    // remove a profile from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func remove() {
        episodeManager.episode = episode
        episodeManager.remove()
        // I'm sure much more needs to be done, e.g. remove from Profile.Creation
        
    }
}

