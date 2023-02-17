//
//  ProfileView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-16.
//

import SwiftUI

struct ProfileView: View {
    let profileId: String
    @StateObject var profileVM: ProfileVM
    @State private var isPresentingProfileEdit = false
    @State private var bgColor = Color.white
    
    init(profileId: String) {
        self.profileId = profileId
        self._profileVM = StateObject(wrappedValue: ProfileVM(profile: Profile(id: profileId)))
        self._bgColor = State(initialValue: Color(hex: profileVM.profile.page.bgColor))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text(profileVM.profile.page.avatar)
                        Text(profileVM.profile.page.name)
                    }
                    Text(profileVM.profile.page.statement)
                    HStack {
                        Text(profileVM.profile.page.image)
                        Text(profileVM.profile.page.bio)
                    }
                }
            }
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
                bgColor: $bgColor,
                presentationMode: $isPresentingProfileEdit)
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(profileId: "")
    }
}
