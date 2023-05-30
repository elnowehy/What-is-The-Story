//
//  HomeTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var theme: Theme
    @State private var selection: Tab = .home
    @State private var showSignInSheet = false
    @EnvironmentObject var userVM: UserVM
    
    enum Tab {
        case home
        case find
        case community
        case account
        case signout
    }
    
    var body: some View {
        TabView(selection: $selection) {
            LandingPageView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            SearchView()
                .tabItem {
                    Label("Find", systemImage: "magnifyingglass")
                }
                .tag(Tab.find)
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(Tab.community)
            
            AccountMenu(userVM: userVM)
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag(Tab.account)
            
            BookmarkListView()
                .tabItem {
                    Label("About", systemImage: "bookmark")
                }
                .tag(Tab.signout)
        }
        .sheet(isPresented: $showSignInSheet) {
            SignInView(showLogIn: $showSignInSheet, userVM: userVM)
        }
        .onChange(of: selection) { newValue in
            showSignInSheet = selection == .account && !authManager.isLoggedIn
        }
    }
}
    

    
    /*
     struct HomeTabView_Previews: PreviewProvider {
     static var previews: some View {
     @Binding var isShowingAccountTab: Bool
     HomeTabView(isShowingAccountTab: $isShowingAccountTab)
     }
     }
     */
    
    
