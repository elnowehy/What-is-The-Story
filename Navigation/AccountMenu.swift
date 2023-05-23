//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//
// this view has a ProfileView at the top and other user options/menu at the bottom

import SwiftUI

struct AccountMenu: View {
    @StateObject var userVM:UserVM
    @EnvironmentObject var authManager: AuthManager
    @StateObject var profileVM = ProfileVM()
    @State var showLogIn = true
    

    enum Tab {
        case profile
        case create
        case bookmarks
        case earnings
        case settings
    }
    
    var body: some View {
        if authManager.isLoggedIn {
            content
        } else{
            SignInView(showLogIn: $showLogIn, userVM: userVM)
        }
    }
    
    var content: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ProfileView().environmentObject(profileVM)) {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                
                NavigationLink(destination: CreateView().environmentObject(profileVM)) {
                    Label("Create", systemImage: "pencil.and.outline")
                }
                
                NavigationLink(destination: BookmarkListView()) {
                    Label("Messages", systemImage: "envelope.badge")
                }
                
                NavigationLink(destination: BookmarkListView()) {
                    Label("Bookmarks", systemImage: "bookmark")
                }
                
                NavigationLink(destination: UserViewHistoryView()) {
                    Label("View History", systemImage: "clock")
                }
                
                NavigationLink(destination: EarningsView()) {
                    Label("Earnings", systemImage: "chart.bar.xaxis")
                }
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape")
                }
                
                NavigationLink(destination: SignOutView()) {
                    Label("Sign Out", systemImage: "square.and.arrow.up.fill")
                }
                
            }
        }
        .onAppear {
            // to get here, the user has to be logged in first, right?
            // consider the full array in the future
            // *** authManager.isLoggedIn set to true once the user is signed up
            if authManager.isLoggedIn {
                profileVM.profile.id = userVM.user.profileIds[0]
            } 
        }
    }
}


//struct AccountTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountTabView()
//    }
//}

