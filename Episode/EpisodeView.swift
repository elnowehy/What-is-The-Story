//
//  EpisodeView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-05.
//

import AVKit
import SwiftUI

struct EpisodeView: View {
    @ObservedObject var episodeVM : EpisodeVM
    @State var episode: Episode
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text(episodeVM.episode.title)
                if episodeVM.episode.votingOpen {
                    Text(episodeVM.episode.question)
                    Text(episodeVM.episode.pollClosingDate.formatted())
                }

                VideoPlayer(player: AVPlayer(url: episodeVM.episode.video))
                    .frame(width: 300, height: 200)
                    .clipped()
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
        }
    }
}
