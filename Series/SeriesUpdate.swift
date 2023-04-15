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
import AVFAudio
import PhotosUI

struct SeriesUpdate: View {
    @ObservedObject var seriesVM: SeriesVM
    @EnvironmentObject var profileVM: ProfileVM
    @State private var posterPicker: PhotosPickerItem?
    @State private var trailerPicker: PhotosPickerItem?
    @State private var createEpisode = false
    @StateObject var episodeVM = EpisodeVM()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Title", text: $seriesVM.series.title)
                .padding(.top, 20)
            TextEditor(text: $seriesVM.series.synopsis)

            Divider()
            List(episodeVM.episodeList) { episode in
                NavigationLink(destination: EpisodeView(episodeVM: episodeVM, episode: episode)) {
//                    AsyncImage(url: seriesVM.series.poster, content: { image in
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 50)
//                    }) {
//                        ProgressView()
//                    }
                    Text(episode.title)
                }
                .isDetailLink(false)
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
                            seriesVM.series.profile = profileVM.profile.id
                            let seriesId = await seriesVM.create()
                            await profileVM.addSeries(seriesId: seriesId)
                        } else {
                            await seriesVM.update()
                        }
                        dismiss()
                    }
                }

                Spacer()
                NavigationLink("Create Episode") {
                    EpisodeUpdate(episodeVM: episodeVM)
                }

                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
            }
        }
        .task {
            episodeVM.episode.series = seriesVM.series.id
            if !seriesVM.series.episodes.isEmpty {
                episodeVM.episodeIds = seriesVM.series.episodes
                await episodeVM.fetch()
            }
        }
    }
}

//struct SeriesUPdate_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesUpdate()
//    }
//}
