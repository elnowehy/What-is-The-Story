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
    @Binding var player: AVPlayer
    @State private var autoPlayNextEpisode = false
    @StateObject var bookmarkVM = BookmarkVM()
    @State private var isBookmarked = false
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var userVM: UserVM
    @State private var showingShareSheet = false
    
    private func rewindToBeginning() {
        player.seek(to: .zero)
    }
    
    private func skipToNextEpisode() {
        if let nextEpisode = episodeVM.getNextEpisode() {
            episodeVM.episode = nextEpisode
            player.replaceCurrentItem(with: AVPlayerItem(url: nextEpisode.video))
        }
    }
    
    private func skipToPreviousEpisode() {
        if let previousEpisode = episodeVM.getPreviousEpisode() {
            episodeVM.episode = previousEpisode
            player.replaceCurrentItem(with: AVPlayerItem(url: previousEpisode.video))
        }
    }
    
    private func playNextEpisodeAutomatically() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            if autoPlayNextEpisode, let nextEpisode = episodeVM.getNextEpisode() {
                episodeVM.episode = nextEpisode
                player.replaceCurrentItem(with: AVPlayerItem(url: nextEpisode.video))
                player.play()
            }
        }
    }
    
    private func updateBookmark() {
        Task {
            if isBookmarked {
                await bookmarkVM.delete()
                isBookmarked = false
            } else {
                bookmarkVM.add()
                isBookmarked = true
            }
        }
    }
    
    // Function to generate the share link
    private func generateShareLink() -> URL? {
        let baseLink = "\(AppSettings.baseLink)/episode"
        guard let episodeID = episodeVM.episode.id.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let inviterCode = userVM.user.invitationCode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        let shareLink = "\(baseLink)?ep=\(episodeID)&inviter=\(inviterCode)"
        return URL(string: shareLink)
    }

    
    var body: some View {
        HStack {
            Spacer()
            Toggle("Auto Play Next Episode", isOn: $autoPlayNextEpisode)
                .padding()
                .toggleStyle(ToggleBaseStyle(theme: theme))
                .font(theme.typography.button)
            Spacer()
            
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
            
            Button(action: {
                self.showingShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            .sheet(isPresented: $showingShareSheet, content: {
                ShareSheet(items: [generateShareLink()])
            })
            
            Spacer()
        }
        .sheet(isPresented: $showingShareSheet, content: {
            ShareSheet(items: [generateShareLink()])
        })
        .buttonStyle(ButtonBaseStyle(theme: theme))
        .background(theme.colors.tertiaryBackground)
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

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update required
    }
}
