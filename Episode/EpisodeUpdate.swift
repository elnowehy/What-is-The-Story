//
//  CreateViodeoView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will allow creators to create a new video by providing the necessary information.

import SwiftUI
import PhotosUI

struct EpisodeUpdate: View {
    @Binding var episode: Episode
    @Binding var series: Series
    @EnvironmentObject var proifleVM: ProfileVM
    @State private var videoPicker: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Title", text: $episode.title)
                .padding(.top, 20)
            Toggle("Open for Vote?", isOn: $episode.votingOpen)
            if episode.votingOpen  {
                TextField("Question", text: $episode.question)
                    .padding(.top, 20)
                
                // DatePicker("Poll Closing Date", selection: $episode.pollClosingDate)
            }
            TextEditor(text: $episode.synopsis)

            Divider()
            
            PhotosPicker(selection: $videoPicker, matching: .videos) {
                Label("Upload the Episode", systemImage: "film")
            }
            
            Spacer()
            HStack {
                Spacer()
                Button("Save") {
                    Task {
                        let episodeVM = EpisodeVM()
                        let seriesVM = SeriesVM()
                        seriesVM.series = series
                        episodeVM.episode = episode
                        if videoPicker != nil {
                            episodeVM.updateVideo = true
                            do {
                                if let data = try await videoPicker?.loadTransferable(type: Data.self) {
                                    episodeVM.videoData = data
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                        if episode.id.isEmpty {
                            episodeVM.episode.series = series.id
                            let id = await episodeVM.create()
                            await seriesVM.addEpisode(episodeId: id)
                        } else {
                            await episodeVM.update()
                        }
                        dismiss()
                    }
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
//
//struct CreateViodeoView_Previews: PreviewProvider {
//    static var previews: some View {
//        EpisodeUpdate()
//    }
//}
