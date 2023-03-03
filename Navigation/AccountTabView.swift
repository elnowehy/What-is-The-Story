//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//
// this view has a ProfileView at the top and other user options/menu at the bottom

import SwiftUI

struct AccountTabView: View {
    @State private var selection: Tab = .profile
    @StateObject var profileVM: ProfileVM
    private var userVM = UserVM()
    
    init() {
        self._profileVM =  StateObject(wrappedValue: ProfileVM())
    }
    
    enum Tab {
        case profile
        case create
        case earnings
        case settings
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
            
            CreateView()
                .tabItem {
                    Label("Create", systemImage: "pencil.and.outline")
                }
                .tag(Tab.create)
            
            
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
            // consider the full array in the future
            profileVM.profile.id = userVM.user.profileIds[0]
        }
    }
}


struct AccountTabView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTabView()
    }
}

