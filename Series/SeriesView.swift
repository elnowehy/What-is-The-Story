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
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text(seriesVM.series.title)
                AsyncImage(url: seriesVM.series.poster, content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 50)
                }) {
                    ProgressView()
                }
                VideoPlayer(player: AVPlayer(url: seriesVM.series.trailer))
                    .frame(width: 300, height: 200)
                    .clipped()
                Divider()
                Text(seriesVM.series.synopsis)
                Spacer()
                NavigationLink("Update") {
                    SeriesUpdate(seriesVM: seriesVM)
                    // SeriesLIstView()
                }
                Spacer()
            }
        }
        .onAppear{ seriesVM.series = series}
    }
}

//struct SeriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesView()
//    }
//}
