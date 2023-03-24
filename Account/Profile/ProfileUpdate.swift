//
//  ProfileView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will show the public user's activity, such as the videos they've liked, viewed,
//  commented, and voted on. They can also view their transaction history, such as their token
//  transfer and commission.
//
//  Access:
//  1. VideoPlayerView -> ProfileView: Users can tap on a button to access their profile view.
//  2. Account View

import SwiftUI

struct ProfileUpdate: View {
    @ObservedObject var profileVM: ProfileVM
    @Binding var presentationMode: Bool
    @StateObject var imagePicker = ImagePicker()
    
    var body: some View {
        VStack {
            TextField("Your Brand", text: $profileVM.profile.brand)
                .padding(.top, 20)
            TextField("You in one sentence", text: $profileVM.info.statement)
            Text("Tell us more:")
            TextEditor(text: $profileVM.info.bio)
            Divider()
            SingleImagePickerView(label: "Avatar", image: "person.badge.plus.fill", imagePicker: imagePicker)
//            SingleImagePickerView(label: "Photo", image: "person.crop.artframe")
//            SingleImagePickerView(label: "Background", image: "person.and.background.dotted")
            
            HStack {
                Button("Cancel") {
                    presentationMode = false
                }
                Spacer()
                Button("Save") {
                    Task {
                        if imagePicker.image != nil {
                            profileVM.avatarImage = imagePicker.image!
                        }
                        await profileVM.update()
                        await profileVM.updateInfo()
                        presentationMode = false
                    }
                }
            }
        }
        .padding()
    }
    
}

/*
struct ProfileUpdate_Previews: PreviewProvider {
    static var previews: some View {
        ProfileUpdate()
    }
}
 */
 
