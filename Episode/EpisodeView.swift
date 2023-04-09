//
//  EpisodeView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-05.
//

import AVKit
import SwiftUI

struct EpisodeView: View {
    @State var episode: Episode
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text(series.title)
                AsyncImage(url: series.poster, content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 50)
                }) {
                    ProgressView()
                }
                VideoPlayer(player: AVPlayer(url: series.trailer))
                    .frame(width: 300, height: 200)
                    .clipped()
                Divider()
                Text(series.synopsis)
                Spacer()
                NavigationLink("Update") {
                    SeriesUpdate(series: $series)
                    // SeriesLIstView()
                }
                Spacer()
            }
        }
    }
}
