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

import SwiftUI

struct SeriesView: View {
    @State var series: Series
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
                Divider()
                Text(series.synopsis)
                Spacer()
//                HStack {
//                    padding()
//                    Button("Add Episode") {
//                        //add epdisode
//                    }
//                    padding()
//                    Button("Delete") {
//                        // delete series
//                    }
//                    padding()
                    NavigationLink("Update") {
                        SeriesUpdate(series: $series)
                        // SeriesLIstView()
                    }
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                    padding()
//                }
                Spacer()
            }
        }
    }
}

//struct SeriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesView()
//    }
//}
