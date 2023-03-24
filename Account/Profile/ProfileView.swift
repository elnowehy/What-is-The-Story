//
//  ProfileView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-16.
//
// this view has the profile info and option to edit the view

import SwiftUI

struct ProfileView: View {
    @StateObject var profileVM: ProfileVM
    @State private var isPresentingProfileEdit = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    AsyncImage(url: profileVM.profile.avatar, content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }) {
                        ProgressView()
                    }
                    
                    Text(profileVM.profile.brand)
                }
                Text(profileVM.info.statement)
                HStack {
                    Text(profileVM.info.image)
                    Text(profileVM.info.bio)
                    Text("")
                }
            }
            .foregroundColor(.black)
            .background(Color.blue)
            
            
            .navigationBarTitle("Profile")
            .navigationBarItems(trailing:
                                    Button(action: {
                self.isPresentingProfileEdit = true
            }) {
                Text("Edit")
            }
            )
        }
        .sheet(isPresented: $isPresentingProfileEdit) {
            ProfileUpdate(
                profileVM: profileVM,
                presentationMode: $isPresentingProfileEdit)
        }
        .background(
            Image(profileVM.info.bgImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
        .onAppear{
            Task {
                // for some reason this code is executed AFTER the view is rendered.
                // The view is rendered properly after I click Edit then cancel
                await profileVM.fetch()
                print("\(profileVM.profile.avatar)")
                await profileVM.fetchInfo()
                print("\(profileVM.info.bio)")
            }
        }
    }
}



//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
