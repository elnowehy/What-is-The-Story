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
    @EnvironmentObject var theme: Theme
    @StateObject var categoryVM = CategoryVM()
    @State private var posterPicker: PhotosPickerItem?
    @State private var trailerPicker: PhotosPickerItem?
    // @State private var createEpisode = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategories: Set<String>
    @StateObject var episodeVM = EpisodeVM()

    init(seriesVM: SeriesVM) {
        self.seriesVM = seriesVM
        _selectedCategories = State(initialValue: seriesVM.series.categories)
    }


    var body: some View {
        VStack {
            TextField("Title", text: $seriesVM.series.title)
                .padding(.top, 20)
                .font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextEditor(text: $seriesVM.series.synopsis)
                .frame(minHeight: 100)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.bottom)

            CategorySelectionView(selectedCategories: $selectedCategories).environmentObject(categoryVM)

            Divider()
                .padding(.horizontal)

            PhotosPicker(selection: $posterPicker, matching: .images) {
                Label("Select a Poster", systemImage: "photo")
                    .font(.headline)
                    .padding(.vertical)
            }
            .padding(.horizontal)

            Spacer()

            PhotosPicker(selection: $trailerPicker, matching: .videos) {
                Label("Select a Trailer", systemImage: "film")
                    .font(.headline)
                    .padding(.vertical)
            }
            .padding(.horizontal)

            Spacer()

            HStack {
                Spacer()
                Button("Save") {
                    SaveSeries()
                    dismiss()
                }
                .font(.headline)
                .padding(.vertical)

                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .font(.headline)
                .padding(.vertical)
                .buttonStyle(VideoButtonStyle(theme: theme))
                Spacer()
            }
        }
        .task {
            episodeVM.episode.series = seriesVM.series.id
            selectedCategories = seriesVM.series.categories
            if !seriesVM.series.episodes.isEmpty {
                episodeVM.episodeIds = seriesVM.series.episodes
                await episodeVM.fetch()
            }
        }
    }
    
    private func SaveSeries() {
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
            
            seriesVM.series.categories = selectedCategories
            
            if seriesVM.series.id.isEmpty {
                seriesVM.series.profile = profileVM.profile.id
                let seriesId = await seriesVM.create()
                await profileVM.addSeries(seriesId: seriesId)
            } else {
                await seriesVM.update()
            }
        }
    }
}



//struct SeriesUPdate_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesUpdate()
//    }
//}
