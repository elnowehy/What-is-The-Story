//
//  PhotoSelector.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-15.
//

import SwiftUI
import PhotosUI

struct SingleImagePickerView: View {
    @State var label: String
    @State var image: String
    @StateObject var imagePicker = ImagePicker()
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = imagePicker.image {
                    image
                        .resizable()
                        .scaledToFit()
                }
            }
            
            PhotosPicker(selection: $imagePicker.imageSelection,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label(label, systemImage: image)
            }
            
        }
        
    }
}


struct SingleImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        SingleImagePickerView(label: "photo", image: "photo.artframe")
    }
}
