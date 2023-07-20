//
//  HomeTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var theme: Theme
    @State private var selection: Tab = .home
    @State private var showSignInSheet = false
    @EnvironmentObject var userVM: UserVM
    @StateObject var profileVM = ProfileVM()
    
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
            
            AccountMenu()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag(Tab.account)
            
            CreateView().environmentObject(profileVM)
                .tabItem {
                    Label("Create", systemImage: "pencil.and.outline")
                }
                .tag(Tab.signout)
        }
        .modifier(TabViewBaseStyle(theme: theme))
    }
}

    
    
