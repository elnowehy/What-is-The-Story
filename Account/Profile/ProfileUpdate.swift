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
    @EnvironmentObject var profileVM: ProfileVM
    @Binding var presentationMode: Bool
    @StateObject var avatarPicker = ImagePicker()
    @StateObject var photoPicker = ImagePicker()
    @StateObject var backgroundPicker = ImagePicker()
    @State private var isSaving: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                TextField("Your Brand", text: $profileVM.profile.brand)
                    .padding(.top, 20)
                TextField("You in one sentence", text: $profileVM.profile.tagline)
                Text("Tell us more:")
                TextEditor(text: $profileVM.info.bio)
                Divider()
                SingleImagePickerView(label: "Avatar", image: "person.badge.plus.fill", imagePicker: avatarPicker)
                SingleImagePickerView(label: "Photo", image: "person.crop.artframe", imagePicker: photoPicker)
                SingleImagePickerView(label: "Background", image: "person.and.background.dotted", imagePicker: backgroundPicker)
                
                HStack {
                    Button("Cancel") {
                        presentationMode = false
                    }
                    Spacer()
                    Button("Save") {
                        SaveProfile()
                    }
                }
            }
            .padding()
            
            if isSaving {
                SavingProgressView()
            }
        }
    }
    
    private func SaveProfile() {
        Task {
            isSaving = true
            if avatarPicker.image != nil {
                profileVM.avatarImage = avatarPicker.image!
                await profileVM.update()
            }
            if photoPicker.image != nil {
                profileVM.photoImage = photoPicker.image!
                profileVM.updatePhoto = true
            }
            if backgroundPicker.image != nil {
                profileVM.bgImage = backgroundPicker.image!
                profileVM.updateBackground = true
            }
            await profileVM.updateInfo()
            presentationMode = false
            
            isSaving = false
        }
    }
    
}

/*
struct ProfileUpdate_Previews: PreviewProvider {
    static var previews: some View {
        ProfileUpdate()
    }
}
 */
 
