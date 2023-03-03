//
//  ProfileView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-16.
//
// this view has the profile info and option to edit the view

import SwiftUI

struct ProfileView: View {
    // @Injected private var profile: Profile
    // Remember: ProfileVM has @Injected Profile
    // Profile.id should be already populated before we come here.
    @StateObject var profileVM: ProfileVM
    @State private var isPresentingProfileEdit = false
    @State private var bgColor = Color.white
    
    init() {
        self._profileVM =  StateObject(wrappedValue: ProfileVM())
        // self._bgColor = State(initialValue: Color(hex: profileVM.info.bgColor))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(profileVM.profile.avatar)
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
                // bgColor: $bgColor,
                presentationMode: $isPresentingProfileEdit)
        }
        .background(bgColor)
        .onAppear{
            Task {
                await profileVM.fetch()
                await profileVM.fetchInfo()
            }
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
