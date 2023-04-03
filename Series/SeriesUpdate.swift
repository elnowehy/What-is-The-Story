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
import ARKit
import _AVKit_SwiftUI
import AVFAudio
import PhotosUI

struct SeriesUpdate: View {
    @Binding var series: Series
    // var seriesVM = SeriesVM()
    @EnvironmentObject var proifleVM: ProfileVM
    @State private var posterPicker: PhotosPickerItem? //ImagePicker()
    @State private var trailerPicker: PhotosPickerItem?
    @State var videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TextField("Title", text: $series.title)
                .padding(.top, 20)
            TextEditor(text: $series.synopsis)

            Divider()
             
            // SingleImagePickerView(label: "Poster", image: "photo", imagePicker: posterPicker)
            PhotosPicker(selection: $posterPicker, matching: .images) {
                Label("Select a Poster", systemImage: "photo")
            }
            
            PhotosPicker(selection: $trailerPicker, matching: .videos) {
                Label("Select a Trailer", systemImage: "film")
            }
//            if let videoURL = videoURL {
//                VideoPlayer(player: AVPlayer(url: videoURL))
//            } else {
//                Text("No video selected")
//            }
//            Button("Select video") {
//                // Show the video picker
//                let picker = VideoPicker(videoURL: $videoURL, sourceType: .photoLibrary)
//                picker.sourceType = .photoLibrary
//                picker.videoQuality = .typeHigh
//                picker.showsCameraControls = true
//                picker.videoMaximumDuration = 30.0
//                picker.mediaTypes = [UTType.movie.identifier]
//                // presentationMode.wrappedValue.dismiss()
//                dismiss()
//            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
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
                        
//                        if videoURL != nil {
//                            seriesVM.updateTrailer = true
//                        }
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
            }
        }
    }
}

//struct SeriesUPdate_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesUpdate()
//    }
//}
