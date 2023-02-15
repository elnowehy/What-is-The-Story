//
//  HomeTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct HomeTabView: View {
    @State private var selection: Tab = .home
    
    enum Tab {
        case home
        case find
        case community
        case bookmarks
        case account
    }
    
    var body: some View {
        TabView(selection: $selection) {
            VideoListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            FindView()
            .tabItem {
                Label("Find", systemImage: "magnifyingglass")
            }
            .tag(Tab.find)
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(Tab.community)

            BookmarksView()
                .tabItem{
                    Label("Bookmarks", systemImage: "bookmark")
                }

            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
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
