//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct AccountTabView: View {
    @State private var selection: Tab = .account
    
    enum Tab {
        case account
        case profile
        case earnings
        case create
        case bookmarks
    }
    
    var body: some View {
        TabView(selection: $selection) {
            UserView()
                .tabItem {
                    Label("Home", systemImage: "person.circle")
                }
                .tag(Tab.account)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "brain.head.profile")
                }
                .tag(Tab.profile)
            
            EarningsView()
                .tabItem{
                    Label("Earnings", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.account)
            
            CreateView()
                .tabItem{
                    Label("Create", systemImage: "tv.and.mediabox")
                }
                .tag(Tab.account)
            
            BookmarksView()
                .tabItem{
                    Label("Bookmarks", systemImage: "bookmark")
                }
                .tag(Tab.account)
        }
    }
}

struct AccountTabView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTabView()
    }
}
