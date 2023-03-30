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

struct SeriesUpdate: View {
    @StateObject var seriesVM: SeriesVM
    @EnvironmentObject var proifleVM: ProfileVM
    @StateObject var posterPicker = ImagePicker()
//    @State var videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TextField("Title", text: $seriesVM.series.title)
                .padding(.top, 20)
            Text("Synopsis:")
            TextEditor(text: $seriesVM.series.synopsis)
            
            Divider()
            
            SingleImagePickerView(label: "Poster", image: "photo", imagePicker: posterPicker)
            
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
//                presentationMode.wrappedValue.dismiss()
//            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Save") {
                    Task {
                        if posterPicker.image != nil {
                            seriesVM.updatePoster = true
                            seriesVM.posterImage = posterPicker.image!
                        }
//                        if videoURL {
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
