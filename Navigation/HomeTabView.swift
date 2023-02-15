//
//  HomeTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct HomeTabView: View {
    @State private var selection: Tab = .home
    @Binding var isShowingAccountTab: Bool
    
    enum Tab {
        case home
        case community
        case account
    }
    
    var body: some View {
        TabView(selection: $selection){
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
            /*
            UserView()
                .tabItem{
                    Label("Account", systemImage: "person.circle")
                }
                .tag(Tab.account)
             */
            
            Button(action: {
                isShowingAccountTab = true // Set the `isShowingAccountTab` state to true when the button is clicked
            }) {
                Label("Account", systemImage: "person.circle")
            }
            .tag(Tab.account)
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
