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
        GeometryReader { geo in
            NavigationStack {
                VStack {
                    Spacer()
                    VStack {
                        Text(episodeVM.episode.title)
                        if episodeVM.episode.votingOpen {
                            Text(episodeVM.episode.question)
                            Text(episodeVM.episode.pollClosingDate.formatted())
                        }
                    }
                    .padding(.bottom)
                    
                    VideoPlayerView(player: $player)
        
                    ViewRatingView(episode: $episode, showRating: $showRating)
                        .environmentObject(viewRatingVM)
                        
                    PlayerControlView(episodeVM: episodeVM, player: $player)

                    Divider()
                    ScrollView {
                        Text(episodeVM.episode.synopsis)
                    }
                    .padding(.bottom)

                    Spacer()
                    
                    NavigationLink("Update") {
                        EpisodeUpdate(episodeVM: episodeVM, mode: .update)
                    }
                    .modifier(NavigationLinkStyle(theme: theme))
                }
            }
        }
//        .background(ShareSheet(items: [episode.video.absoluteString], isPresented: $showShareSheet, onShareCompletion: onShareCompletion))

        .onAppear{
            print(".onAppear \(episode.video)")
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
            print("onDisappear \(episode.title)")
            if let observer = timeObserver {
                player!.removeTimeObserver(observer)
            }
        }
    }
}

//struct ShareSheet: UIViewControllerRepresentable {
//    var items: [Any]
//    @Binding var isPresented: Bool
//    var onShareCompletion: (Bool) -> Void
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No update needed
//    }
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        controller.completionWithItemsHandler = { _, completed, _, _ in
//            onShareCompletion(completed)
//            isPresented = false
//        }
//        return controller
//    }
//}
//




