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
    @EnvironmentObject var viewRatingVM: ViewRatingVM
    @State private var isFullScreen = false
    @State private var player: AVPlayer?
    @State private var timeObserver: Any?
    @Environment(\.dismiss) private var dismiss
    @State private var autoPlayNextEpisode = false
    @State private var showShareSheet = false
//    @State private var onShareCompletion: (Bool) -> Void = { _ in }
    @State private var playbackPercentage: Double = 0.0
    @State private var showRating = false
//    @State private var userRating: Int? = nil
    @EnvironmentObject var userVM: UserVM


    private func handleViewCount() {
        let duration = player?.currentItem?.duration.seconds ?? 0
        let playbackTime = player!.currentTime().seconds
        playbackPercentage = playbackTime / duration

        if playbackPercentage >= 0.8 {
            viewRatingVM.viewRating.userId = userVM.user.id
            viewRatingVM.viewRating.episodeId = episode.id
            viewRatingVM.handleViewCount()
            showRating = true
        }
    }

    private func rewindToBeginning() {
        player?.seek(to: .zero)
    }

    private func skipToNextEpisode() {
        let nextEpisode = episodeVM.getNextEpisode()
        if let nextEpisode = nextEpisode {
            player?.replaceCurrentItem(with: AVPlayerItem(url: nextEpisode.video))
        }
    }

    private func skipToPreviousEpisode() {
        let previousEpisode = episodeVM.getPreviousEpisode()
        if let previousEpisode = previousEpisode {
            player?.replaceCurrentItem(with: AVPlayerItem(url: previousEpisode.video))
        }
    }

    private func playNextEpisodeAutomatically() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
            if autoPlayNextEpisode, let nextEpisode = episodeVM.getNextEpisode() {
                episode = nextEpisode
                player?.replaceCurrentItem(with: AVPlayerItem(url: nextEpisode.video))
                player?.play()
            }
        }
    }


    private func bookmark() {
        // update bookmarks
    }

//    private func share() {
//        showShareSheet = true
//        onShareCompletion = { completed in
//            if completed {
//                // The user shared the URL
//                print("URL shared")
//                // Add your custom logic for sharing completion here
//            } else {
//                // The user canceled the sharing process
//                print("URL sharing canceled")
//                // Add your custom logic for sharing cancellation here
//            }
//        }
//    }

    
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
                    
                    VideoPlayer(player: player)
                        .frame(width: geo.size.width, height: isFullScreen ?  geo.size.height : geo.size.height * 9/16)
                        .clipped()
                        .onTapGesture {
                            isFullScreen.toggle()
                        }
                    
                    AvgRatingView(avgRating: $episodeVM.episode.avgRating)
                    
                    if showRating {
                        UserRatingView(viewRatingVM: viewRatingVM)
                            .opacity(showRating ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4), value: showRating)
                    }

                    HStack {
                        Toggle("Auto Play Next Episode", isOn: $autoPlayNextEpisode)
                            .padding()

                        Button(action: rewindToBeginning) {
                            Image(systemName: "backward.end.fill")
                        }

                        Button(action: skipToPreviousEpisode) {
                            Image(systemName: "backward.end.alt.fill")
                        }
                        .disabled(episodeVM.hasPreviousEpisode() == false)

                        Button(action: skipToNextEpisode) {
                            Image(systemName: "forward.end.alt.fill")
                        }
                        .disabled(episodeVM.hasNextEpisode() == false)

                        Button(action: bookmark) {
                            Image(systemName: "bookmark")
                        }

//                        Button(action: share) {
//                            Image(systemName: "square.and.arrow.up")
//                        }
                    }
                    .padding()
                    .foregroundColor(.blue)

                    Divider()
                    ScrollView {
                        Text(episodeVM.episode.synopsis)
                    }
                    .padding(.bottom)

                    Spacer()
                    
                    NavigationLink("Update") {
                        EpisodeUpdate(episodeVM: episodeVM, mode: .update)
                    }
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
        .task {
            await userVM.currentUserData()
            viewRatingVM.viewRating.episodeId = episodeVM.episode.id
            viewRatingVM.viewRating.userId = userVM.user.id
            print(".task \(viewRatingVM.viewRating.userId)")
            print(".task \(viewRatingVM.viewRating.episodeId)")
            await viewRatingVM.fetchViewRating()
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

struct AvgRatingView: View {
    @Binding var avgRating: Double

    var body: some View {
        VStack {
            Text("Average Rating")
            ratingStars(rating: avgRating, isInteractive: false, onTap: nil)
        }
    }
}

struct UserRatingView: View {
    @ObservedObject var viewRatingVM: ViewRatingVM

    var body: some View {
        VStack {
            Text("Your Rating")
            ratingStars(rating: Double(viewRatingVM.viewRating.rating), isInteractive: true) { selectedRating in
                viewRatingVM.viewRating.rating = selectedRating
                Task {
                    await viewRatingVM.saveUserRating()
                }
            }
        }
    }
}


