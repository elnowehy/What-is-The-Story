//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//
// this view has a ProfileView at the top and other user options/menu at the bottom

import SwiftUI

struct AccountMenu: View {
    @EnvironmentObject var userVM:UserVM
    @EnvironmentObject var theme: Theme
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
        if userVM.isLoggedIn {
            content
        } else{
            SignInView(showLogIn: $showLogIn, userVM: userVM)
        }
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink(destination: ProfileView().environmentObject(profileVM)) {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
                    
                    NavigationLink(destination: BookmarkListView()) {
                        Label("Messages", systemImage: "envelope.badge")
                    }
                    
                    NavigationLink(destination: BookmarkListView()) {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
                    
                    NavigationLink(destination: ViewsHistoryView()) {
                        Label("View History", systemImage: "clock")
                    }
                    
                    NavigationLink(destination: EarningsView()) {
                        Label("Earnings", systemImage: "chart.bar.xaxis")
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                Spacer()
                Button(action: {
                    Task.init(priority: .high) {
                        await userVM.signOut()
                    }
                }) {
                    Text("Sign Out")
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
            }
            
        }
        .task {
            if userVM.isLoggedIn && userVM.user.profileIds.count > 0 {
                profileVM.profile.id = userVM.user.profileIds[0]
                await profileVM.fetch()
                await profileVM.fetchInfo()
            }
        }
        .onChange(of: userVM.user.profileIds.count) { newValue in
            if newValue > 0 {
                profileVM.profile.id = userVM.user.profileIds[0]
                Task {
                    await profileVM.fetch()
                    await profileVM.fetchInfo()
                }
            }
        }
        .font(theme.typography.subtitle)
        .foregroundColor(theme.colors.text)
    }
}


//struct AccountTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountTabView()
//    }
//}

