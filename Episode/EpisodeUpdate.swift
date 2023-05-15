//
//  CreateViodeoView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will allow creators to create a new video by providing the necessary information.

import SwiftUI
import PhotosUI

enum Mode {
    case update
    case add
}

struct EpisodeUpdate: View {
    @ObservedObject var episodeVM: EpisodeVM
    @EnvironmentObject var seriesVM: SeriesVM
    var mode: Mode
    @State private var videoPicker: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Title", text: $episodeVM.episode.title)
                .padding(.top, 20)
            Toggle("Open for Vote?", isOn: $episodeVM.episode.votingOpen)
            if episodeVM.episode.votingOpen  {
                TextField("Question", text: $episodeVM.episode.question)
                    .padding(.top, 20)
                
                DatePicker("Poll Closing Date", selection: $episodeVM.episode.pollClosingDate)
            }
            TextEditor(text: $episodeVM.episode.synopsis)

            Divider()
            
            PhotosPicker(selection: $videoPicker, matching: .videos) {
                Label("Upload the Episode", systemImage: "film")
            }
            
            Spacer()
            HStack {
                Spacer()
                Button("Save") {
                    Task {
                        seriesVM.series.id = episodeVM.episode.series
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
                        
                        if episodeVM.episode.id.isEmpty {
                            episodeVM.episode.series = seriesVM.series.id
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
        .navigationBarBackButtonHidden()
        .onAppear{
            if mode == .add {
                let seriesId = episodeVM.episode.series
                episodeVM.episode = Episode()
                episodeVM.episode.series = seriesId
            }
            
        }
    }
}
//
//struct CreateViodeoView_Previews: PreviewProvider {
//    static var previews: some View {
//        EpisodeUpdate()
//    }
//}
