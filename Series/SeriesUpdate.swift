//
//  CreateSeriesView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will allow creators to create anew series by providing the necessary information.
//
//  Access: Account -> CreateSeriesView


import SwiftUI
//import ARKit
//import _AVKit_SwiftUI
import AVFAudio
import PhotosUI

struct SeriesUpdate: View {
    @Binding var series: Series
    @EnvironmentObject var proifleVM: ProfileVM
    @State private var posterPicker: PhotosPickerItem?
    @State private var trailerPicker: PhotosPickerItem?
    @State private var createEpisode = false
    @State var episode = Episode()
    @StateObject var episodeVM = EpisodeVM()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Title", text: $series.title)
                .padding(.top, 20)
            TextEditor(text: $series.synopsis)

            Divider()
            List(episodeVM.episodeList) { episode in
                NavigationLink(destination: EpisodeView(series: series)) {
                    AsyncImage(url: series.poster, content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 50)
                    }) {
                        ProgressView()
                    }
                    Text(series.title)
                }
            }
            PhotosPicker(selection: $posterPicker, matching: .images) {
                Label("Select a Poster", systemImage: "photo")
            }
            Spacer()
            PhotosPicker(selection: $trailerPicker, matching: .videos) {
                Label("Select a Trailer", systemImage: "film")
            }
            Spacer()
            HStack {
                Spacer()
                Button("Save") {
                    Task {
                        let seriesVM = SeriesVM()
                        seriesVM.series = series
                        if posterPicker != nil {
                            seriesVM.updatePoster = true
                            do {
                                if let data = try await posterPicker?.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        seriesVM.posterImage = uiImage
                                    }
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }

                        if trailerPicker != nil {
                            seriesVM.updateTrailer = true
                            do {
                                if let data = try await trailerPicker?.loadTransferable(type: Data.self) {
                                    seriesVM.trailerData = data
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }

                        if seriesVM.series.id.isEmpty {
                            seriesVM.series.profile = proifleVM.profile.id
                            let seriesId = await seriesVM.create()
                            await proifleVM.addSeries(seriesId: seriesId)
                        } else {
                            await seriesVM.update()
                        }
                        dismiss()
                    }
                }

                Spacer()
                NavigationLink("Create Episode") {
                    EpisodeUpdate(episode: $episode, series: $series)
                }

                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
            }
            Spacer()
        }
    }
}

//struct SeriesUPdate_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesUpdate()
//    }
//}
