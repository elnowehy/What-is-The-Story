//
//  PlayerControlView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-29.
//

import SwiftUI
import AVKit

struct PlayerControlView: View {
    @StateObject var episodeVM: EpisodeVM
    @Binding var player: AVPlayer?
    @State private var autoPlayNextEpisode = false
    @StateObject var bookmarkVM = BookmarkVM()
    @State private var isBookmarked = false
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var userVM: UserVM
    
    private func rewindToBeginning() {
        player!.seek(to: .zero)
    }
    
    private func skipToNextEpisode() {
        if let nextEpisode = episodeVM.getNextEpisode() {
            episodeVM.episode = nextEpisode
            player!.replaceCurrentItem(with: AVPlayerItem(url: nextEpisode.video))
        }
    }
    
    private func skipToPreviousEpisode() {
        if let previousEpisode = episodeVM.getPreviousEpisode() {
            episodeVM.episode = previousEpisode
            player!.replaceCurrentItem(with: AVPlayerItem(url: previousEpisode.video))
        }
    }
    
    private func playNextEpisodeAutomatically() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
            if autoPlayNextEpisode, let nextEpisode = episodeVM.getNextEpisode() {
                episodeVM.episode = nextEpisode
                player!.replaceCurrentItem(with: AVPlayerItem(url: nextEpisode.video))
                player!.play()
            }
        }
    }
    
    private func updateBookmark() {
        if isBookmarked {
            bookmarkVM.delete()
            isBookmarked = false
        } else {
            bookmarkVM.add()
            isBookmarked = true
        }
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
        HStack {
            Toggle("Auto Play Next Episode", isOn: $autoPlayNextEpisode)
                .padding()
                .toggleStyle(GenToggleStyle(theme: theme))
            
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
            
            if(!userVM.user.id.isEmpty) {
                Button(action: updateBookmark) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
            }
        }
            
            //                        Button(action: share) {
            //                            Image(systemName: "square.and.arrow.up")
            //                        }
        }
        .buttonStyle(VideoButtonStyle(theme: theme))
        .task {
            if(!userVM.user.id.isEmpty) {
                bookmarkVM.bookmark.userId = userVM.user.id
                bookmarkVM.bookmark.contentId = episodeVM.episode.id
                Task {
                    await bookmarkVM.fetch()
                    if bookmarkVM.bookmark.id.isEmpty {
                        isBookmarked = false
                    } else {
                        isBookmarked = true
                    }
                }
            }
        }
    }
}

//struct PlayerControlView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerControlView()
//    }
//}
