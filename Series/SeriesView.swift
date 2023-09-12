//
//  SeriesView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will show the details of a selected series, such as the series title, description, and
//  a list of episodes. Users can tap on an episode to watch the video.
//
//  Access: HomeView -> SeriesView. When a user taps on a series in the home view, they will be
//          taken to the series view to see the details of the selected series

import AVKit
import SwiftUI

struct SeriesView: View {
    @ObservedObject var seriesVM: SeriesVM
    @State var series: Series
    var mode: Mode
    @StateObject var episodeVM = EpisodeVM()
    @StateObject var bookmarkVM = BookmarkVM()
    @StateObject var commentVM = CommentVM()
    @State private var isBookmarked = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var playerVM: PlayerVM
    @EnvironmentObject var userVM: UserVM
    @State private var isPlayingVideo = false
    @State private var isSynopsisExpanded = false
    @State private var isCommentsExpanded = false
    @State private var averageRating: Double = 0
    
    private func updateBookmark() {
        Task {
            if isBookmarked {
                await bookmarkVM.delete()
                isBookmarked = false
            } else {
                bookmarkVM.bookmark.contentType = ContentType.series
                bookmarkVM.add()
                isBookmarked = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.medium) {
                
                HStack {
                    Text(seriesVM.series.title)
                    if(!userVM.user.id.isEmpty) {
                        Spacer()
                        Button(action: updateBookmark) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack {
                    if isPlayingVideo {
                        // PlayerView(player: playerVM.player)
                        if let player = playerVM.player {
                            PlayerView(player: .constant(player))
                        } else {
                            // Show a placeholder or alternative view when player is nil.
                            Text("No Video!!")
                        }
                    } else {
                        AsyncImage(url: seriesVM.series.poster, content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    isPlayingVideo = true
                                }
                        }) {
                            ProgressView()
                        }
                    }
                }
                
                AvgRatingView(avgRating: $averageRating)
                    .font(theme.typography.caption)
                
                Divider()
                DisclosureGroup(isExpanded: $isSynopsisExpanded) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(seriesVM.series.synopsis)
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.text)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                } label: {
                    Text("Synopsis")
                        .font(theme.typography.subtitle)
                        .foregroundColor(theme.colors.text)
                }
                
                DisclosureGroup(isExpanded: $isCommentsExpanded) {
                    HStack {
                        VStack(alignment: .leading) {
                            CommentView(commentVM: commentVM, contentId: seriesVM.series.id)
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
                
                if seriesVM.series.userId == userVM.user.id && mode == .update {
                    HStack {
                        Spacer()
                        NavigationLink("Update") {
                            SeriesUpdateView(seriesVM: seriesVM)
                        }
                        .modifier(NavigationLinkStyle(theme: theme))
                        
                        Spacer()
                        NavigationLink("Create Episode") {
                            EpisodeUpdate(episodeVM: episodeVM, mode: .add).environmentObject(seriesVM)
                        }
                        .modifier(NavigationLinkStyle(theme: theme))
                        .padding(.vertical)
                        
                        Spacer()
                    }
                }
                // Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .top)
            
            List(episodeVM.episodeList) { episode in
                NavigationLink(destination: EpisodeView(episode: episode, mode: .update)
                    .environmentObject(episodeVM)
                    .environmentObject(seriesVM)
                ) {
                    Text(episode.title)
                }
                .isDetailLink(false)
                .font(theme.typography.subtitle)
            }
            
            Spacer()
        }
        .task {
            episodeVM.episode.series = seriesVM.series.id
            playerVM.preparePlayer(with: seriesVM.series.trailer)
            if !seriesVM.series.episodes.isEmpty {
                episodeVM.episodeIds = seriesVM.series.episodes
                await episodeVM.fetch()
            }
            
            if(!userVM.user.id.isEmpty) {
                bookmarkVM.bookmark.userId = userVM.user.id
                bookmarkVM.bookmark.contentId = seriesVM.series.id
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
        .padding()
        .onAppear{
            seriesVM.series = series
            averageRating = series.averageRating
        }
    }
}


//struct SeriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesView()
//    }
//}
