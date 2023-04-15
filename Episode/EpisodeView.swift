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
    @ObservedObject var episodeVM: EpisodeVM
    @State var episode: Episode
    @State private var isFullScreen = false
    @State private var player: AVPlayer?
    @State private var timeObserver: Any?
    @Environment(\.dismiss) private var dismiss
    
    private func handleViewCount() {
        let duration = player?.currentItem?.duration.seconds ?? 0
        let playbackTime = player!.currentTime().seconds
        let playbackPercentage = playbackTime / duration

        if playbackPercentage >= 0.8 {
            print("Count another view")
        }
        print("\(duration), \(playbackTime), \(playbackPercentage)")
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                VStack {
                    Spacer()
                    Text(episodeVM.episode.title)
                    if episodeVM.episode.votingOpen {
                        Text(episodeVM.episode.question)
                        Text(episodeVM.episode.pollClosingDate.formatted())
                    }
                    
                    VideoPlayer(player: player)
                        .frame(width: geo.size.width, height: isFullScreen ?  geo.size.height : geo.size.height * 9/16)
                        .clipped()
                        .onTapGesture {
                            isFullScreen.toggle()
                        }
                }
                Divider()
                Text(episodeVM.episode.synopsis)
                Spacer()
                NavigationLink("Update") {
                    EpisodeUpdate(episodeVM: episodeVM)
                }
                Spacer()
            }
        }
        .onAppear{
            episodeVM.episode = episode
            player = AVPlayer(url: episodeVM.episode.video)
            if player != nil {
                player!.replaceCurrentItem(with: AVPlayerItem(url: episodeVM.episode.video))
                let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                timeObserver = player!.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
                    handleViewCount()
                }
            }
        }
        .onDisappear {
            if let observer = timeObserver {
                player!.removeTimeObserver(observer)
            }
        }
    }
}
