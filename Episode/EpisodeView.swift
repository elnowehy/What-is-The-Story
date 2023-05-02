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
    @ObservedObject var viewRatingsVM = ViewRatingVM()
    @State var episode: Episode
    @State private var isFullScreen = false
    @State private var player: AVPlayer?
    @State private var timeObserver: Any?
    @Environment(\.dismiss) private var dismiss
    @State private var autoPlayNextEpisode = false
    @State private var showShareSheet = false
    @State private var onShareCompletion: (Bool) -> Void = { _ in }
    @State private var playbackPercentage: Double = 0.0
    @State private var showRating = false
    @State private var userRating: Int? = nil
    @ObservedObject var userVM = UserVM()
    
    private func handleViewCount() {
        let duration = player?.currentItem?.duration.seconds ?? 0
        let playbackTime = player!.currentTime().seconds
        playbackPercentage = playbackTime / duration

        if playbackPercentage >= 0.8 {
            viewRatingsVM.userId = userVM.user.id
            viewRatingsVM.episodeId = episode.id
            viewRatingsVM.handleViewCount()
            showRating = true
        }
        print("\(duration), \(playbackTime), \(playbackPercentage)")
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
    
    private func share() {
        showShareSheet = true
        onShareCompletion = { completed in
            if completed {
                // The user shared the URL
                print("URL shared")
                // Add your custom logic for sharing completion here
            } else {
                // The user canceled the sharing process
                print("URL sharing canceled")
                // Add your custom logic for sharing cancellation here
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
                    
                    VideoPlayer(player: player)
                        .frame(width: geo.size.width, height: isFullScreen ?  geo.size.height : geo.size.height * 9/16)
                        .clipped()
                        .onTapGesture {
                            isFullScreen.toggle()
                        }
                    
                    if showRating {
                        RatingView(avgRating: $episodeVM.episode.avgRating, userRating: $userRating)
                            .opacity(showRating ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4), value: showRating)
                    }

                    HStack {
                        Toggle("Auto Play Next Episode", isOn: $autoPlayNextEpisode)
                            .padding()

                        Button(action: rewindToBeginning) {
                            Image(systemName: "gobackward")
                        }
                        
                        Button(action: skipToPreviousEpisode) {
                            Image(systemName: "skip.backward")
                        }
                        .disabled(episodeVM.hasPreviousEpisode() == false)
                        
                        Button(action: skipToNextEpisode) {
                            Image(systemName: "skip.forward")
                        }
                        .disabled(episodeVM.hasNextEpisode() == false)
                        
                        Button(action: bookmark) {
                            Image(systemName: "bookmark")
                        }
                        
                        Button(action: share) {
                            Image(systemName: "square.and.arrow.up")
                        }
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
                        EpisodeUpdate(episodeVM: episodeVM)
                    }
                }
            }
        }
        .background(ShareSheet(items: [episode.video], isPresented: $showShareSheet, onShareCompletion: onShareCompletion))
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
        .task {
            await userVM.currentUserData()
            viewRatingsVM.viewRating.episodeId = episodeVM.episode.id
            viewRatingsVM.viewRating.userId = userVM.user.id
            await viewRatingsVM.fetchViewRating()
        }
        .onDisappear {
            if let observer = timeObserver {
                player!.removeTimeObserver(observer)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    @Binding var isPresented: Bool
    var onShareCompletion: (Bool) -> Void

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onShareCompletion(completed)
            isPresented = false
        }
        return controller
    }
}

struct RatingView: View {
    @Binding var avgRating: Int
    @Binding var userRating: Int?

    var body: some View {
        VStack {
            Text("Average Rating")
            ratingStars(rating: avgRating, isInteractive: false)
            
            Text("Your Rating")
            ratingStars(rating: userRating ?? 0, isInteractive: true)
        }
    }
    
    private func ratingStars(rating: Int, isInteractive: Bool) -> some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index <= rating ? .yellow : .gray)
                    .scaleEffect(index == rating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: rating)
                    .onTapGesture {
                        if isInteractive {
                            userRating = index
                        }
                    }
            }
        }
    }

}


