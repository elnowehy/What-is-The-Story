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
    @ObservedObject var profileManager: ProfileManager
    
    var body: some View {
       
        Form {
            TextField("Name", text: $profileManager.profile.ProfilePage.name)
        }
        
        /* Form {
                TextField("Name", text: $profileManager.profile.landingPage.name)
                TextField("Title", text: $profileManager.profile.landingPage.title)
                // Add more fields as needed
            
            
        }
        .navigationBarTitle("Profile")
        .navigationBarItems(trailing: Button("Save") {
            // Handle save action here
        })
        */
         
    }
    
}

/*
 struct ProfileUpdate_Previews: PreviewProvider {
 static var previews: some View {
 ProfileUpdate()
 }
 }
 */
