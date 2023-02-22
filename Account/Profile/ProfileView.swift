//
//  ProfileView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-16.
//

import SwiftUI

struct ProfileView: View {
    @Injected private var profile: Profile
    @StateObject var profileVM: ProfileVM
    @State private var isPresentingProfileEdit = false
    @State private var bgColor = Color.white
    
    init() {
        self._profileVM = StateObject(wrappedValue: ProfileVM())
        self._bgColor = State(initialValue: Color(hex: profile.bgColor))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text(profile.avatar)
                        Text(profile.name)
                    }
                    Text(profile.statement)
                    HStack {
                        Text(profile.image)
                        Text(profile.bio)
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
        ProfileView()
    }
}
