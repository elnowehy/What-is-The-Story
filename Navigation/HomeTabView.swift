//
//  HomeTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selection: Tab = .home
    @State private var showSignInSheet = false
    
    enum Tab {
        case home
        case find
        case community
        case bookmarks
        case account
        case signout
    }
    
    var body: some View {
        TabView(selection: $selection) {
            VideoListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(Tab.community)
            
            
            BookmarksView()
                .tabItem{
                    Label("Bookmarks", systemImage: "bookmark")
                }
                .tag(Tab.bookmarks)
            
            
            AccountMenu()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag(Tab.account)
            
            SignOutView()
                .tabItem {
                    Label("Sign Out", image: "square.and.arrow.up")
                }
        }
        
        .onChange(of: selection){ value in
            if( (value == .account || value == .bookmarks) && !authManager.isLoggedIn) {
                showSignInSheet = true
            }
        }
        .sheet(isPresented: $showSignInSheet) {
            SignInView().environmentObject(authManager)
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
    
    
