//
//  EpisodeView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-05.
//

// create a view that displays the episode details and video player and count views

import AVKit
import SwiftUI

struct EpisodeView: View {
    @EnvironmentObject var episodeVM: EpisodeVM
    @EnvironmentObject var seriesVM: SeriesVM
    @State var episode: Episode
    var mode: Mode
    @StateObject var viewRatingVM = ViewRatingVM()
    @StateObject var pollVM = PollVM()
    @State private var timeObserver: Any?
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var playbackPercentage: Double = 0.0
    @State private var showRating = false
    @State private var countViews = true
    @EnvironmentObject var userVM: UserVM
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var playerVM: PlayerVM
    @State private var player: AVPlayer?
    @State private var isSynopsisExpanded = false
    @State private var isPollExpanded = false
    @StateObject var commentVM = CommentVM()
    @State private var isCommentsExpanded = false
    
    private func handleViewCount() {
        guard let player = playerVM.player else { return }
        
        let duration = player.currentItem?.duration.seconds ?? 0
        let playbackTime = player.currentTime().seconds
        playbackPercentage = playbackTime / duration

        if playbackPercentage >= 0.8 {
            viewRatingVM.viewRating.userId = userVM.user.id
            viewRatingVM.viewRating.episodeId = episode.id
            showRating = true
            
            if countViews {
                episodeVM.incrementViewCount()
                seriesVM.incrementViewCount()
                viewRatingVM.add()
                countViews = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.medium) {
                
                Text(episodeVM.episode.title)
                
                // PlayerView(player: $player)
                if let player = playerVM.player {
                    PlayerView(player: .constant(player))
                } else {
                    // Show a placeholder or alternative view when player is nil.
                    Text("No Video!!")
                }
                
                ViewRatingView(episode: $episode, showRating: $showRating)
                    .environmentObject(viewRatingVM)
                
                if let player = playerVM.player {
                    PlayerControlView(episodeVM: episodeVM, player: .constant(player))
                } else {
                    // Show a placeholder or alternative view when player is nil.
                    Text("No Video!!")
                }

                Divider()
                DisclosureGroup(isExpanded: $isSynopsisExpanded) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(episodeVM.episode.synopsis)
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.text)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        Spacer()
                    }
                } label: {
                    Text("Synopsis")
                        .font(theme.typography.subtitle)
                        .foregroundColor(theme.colors.text)
                }
                
                
                if episodeVM.episode.hasPoll {
                    DisclosureGroup(isExpanded: $isPollExpanded) {
                        PollView(pollVM: pollVM)
                    } label: {
                        Text("Poll")
                            .font(theme.typography.subtitle)
                            .foregroundColor(theme.colors.text)
                    }
                }
                
                DisclosureGroup(isExpanded: $isCommentsExpanded) {
                    HStack {
                        VStack(alignment: .leading) {
                            CommentView(commentVM: commentVM, contentId: episodeVM.episode.id)
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.text)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                } label: {
                    Text("Comments")
                        .font(theme.typography.subtitle)
                        .foregroundColor(theme.colors.text)
                }
                
                Spacer()
                if episodeVM.episode.userId == userVM.user.id && mode == .update {
                    NavigationLink("Update") {
                        EpisodeUpdate(episodeVM: episodeVM, mode: .update)
                            .environmentObject(seriesVM)
                    }
                    .modifier(NavigationLinkStyle(theme: theme))
                }
            }
        }
         
        .padding()
        .onAppear{
            print(".onAppear \(episode.video)")
            episodeVM.episode = episode
            if !episodeVM.episode.video.absoluteString.isEmpty {
                playerVM.preparePlayer(with: episode.video)
                if let player = playerVM.player, !userVM.user.id.isEmpty {
                    self.player = player
                    let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
                        handleViewCount()
                    }
                }
            }
            
            if episodeVM.episode.hasPoll {
                Task {
                    pollVM.poll.id = episodeVM.episode.id
                    await pollVM.fetch()
                }
            }
        }
        
        .task {
            if seriesVM.series.id.isEmpty {
                seriesVM.series.id = episode.series
                seriesVM.seriesIds.append(episode.series)
                await seriesVM.fetch()
            }
        }
        
        .onDisappear {
            print("onDisappear \(episode.title)")
            if let observer = timeObserver, let player = self.player {
                player.removeTimeObserver(observer)
                timeObserver = nil
                self.player = nil
            }
        }
    }
}

struct EpisodeViewLink: View {
    let episodeID: String
    @StateObject var episodeVM = EpisodeVM()
    @StateObject var seriesVM = SeriesVM()
    @State private var episode = Episode()

    var body: some View {
        Group {
            EpisodeView(episode: episode, mode: .view)
                .environmentObject(episodeVM)
                .environmentObject(seriesVM)
        }
        .task {
            await populateVMs(episode: episodeID)
        }
    }

    private func populateVMs(episode: String) async {
        episodeVM.episodeIds[0] = episodeID
        let episodeList = await episodeVM.fetch()
        let episode = episodeList[0]
        episodeVM.episode = episode
        
        if episode.series.isEmpty {
            print("\(episodeID) doesn't have a series id??")
            return
        } else {
            seriesVM.series.id = episode.series
            let seriesList = await seriesVM.fetch()
            seriesVM.series = seriesList[0]
        }
        
    }
}








