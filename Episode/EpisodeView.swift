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
    @State var player: AVPlayer?
    @State private var timeObserver: Any?
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var playbackPercentage: Double = 0.0
    @State private var showRating = false
    @State private var countViews = true
    @EnvironmentObject var userVM: UserVM
    @EnvironmentObject var theme: Theme
    @State private var isSynopsisExpanded = false
    @State private var isPollExpanded = false
    
    private func handleViewCount() {
        let duration = player?.currentItem?.duration.seconds ?? 0
        let playbackTime = player!.currentTime().seconds
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
                
                VideoPlayerView(player: $player)
                
                ViewRatingView(episode: $episode, showRating: $showRating)
                    .environmentObject(viewRatingVM)
                
                PlayerControlView(episodeVM: episodeVM, player: $player)
                
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
                
                
                if episodeVM.episode.votingOpen {
                    DisclosureGroup(isExpanded: $isPollExpanded) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(episodeVM.episode.question)
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.text)
                                    .multilineTextAlignment(.leading)
                                Text("Closing Date: \(formattedTimestamp(for:  episodeVM.episode.pollClosingDate))")
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.accent)
                            }
                            Spacer()
                        }
                    } label: {
                        Text("Poll")
                            .font(theme.typography.subtitle)
                            .foregroundColor(theme.colors.text)
                    }
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
        //        .background(ShareSheet(items: [episode.video.absoluteString], isPresented: $showShareSheet, onShareCompletion: onShareCompletion))
        .padding()
        .onAppear{
            print(".onAppear \(episode.video)")
            episodeVM.episode = episode
            player = AVPlayer(url: episodeVM.episode.video)
            if player != nil && !userVM.user.id.isEmpty {
                player!.replaceCurrentItem(with: AVPlayerItem(url: episodeVM.episode.video))
                let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                timeObserver = player!.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
                    handleViewCount()
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
            if let observer = timeObserver {
                player!.removeTimeObserver(observer)
            }
        }
    }
}





