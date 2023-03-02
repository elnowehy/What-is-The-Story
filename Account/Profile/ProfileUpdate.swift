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
    @Binding var bgColor: Color
    @Binding var presentationMode: Bool
    
    var body: some View {
        
        VStack {
            TextField("Your Brand", text: $profileVM.profile.brand)
            TextField("You in one sentence", text: $profileVM.info.statement)
            Text("Tell us more:")
            TextEditor(text: $profileVM.info.bio)
            Divider()
            SingleImagePickerView(label: "Avatar", image: "person.badge.plus.fill")
            SingleImagePickerView(label: "Photo", image: "person.crop.artframe")
            ColorPicker("Background Color", selection: $bgColor)
        }
        
        HStack {
            Spacer()
            Button("Cancel") {
                presentationMode = false
            }
            Spacer()
            Button("Save") {
                Task {
                    await profileVM.update()
                    await profileVM.updateInfo()
                    presentationMode = false
                }
            }
            Spacer()
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
