//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//
// this view has a ProfileView at the top and other user options/menu at the bottom

import SwiftUI

struct AccountTabView: View {
    @StateObject var userVM:UserVM
    @EnvironmentObject var authManager: AuthManager
    @State private var selection: Tab = .profile
    @StateObject var profileVM = ProfileVM()
    @Environment(\.dismiss) private var dismiss
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
        TabView(selection: $selection) {
            ProfileView().environmentObject(profileVM)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
            
            CreateView().environmentObject(profileVM)
                .tabItem {
                    Label("Create", systemImage: "pencil.and.outline")
                }
                .tag(Tab.create)
            
            BookmarksView()
                .tabItem{
                    Label("Bookmarks", systemImage: "bookmark")
                }
                .tag(Tab.bookmarks)
            
            EarningsView()
                .tabItem{
                    Label("Earnings", systemImage: "chart.bar.xaxis")
                }
                .tag(Tab.earnings)
            
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        //  not working, will look into it later
        // .animation(.linear, value: 1)
        // .background(Color(red: 0255, green: 0/255, blue: 0/255))
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

