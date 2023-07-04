//
//  SeriesWelcome.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-27.
//

import SwiftUI

struct CreateView: View {
    @EnvironmentObject var userVM:UserVM
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var profileVM: ProfileVM
    @EnvironmentObject var theme: Theme
    @StateObject var seriesVM = SeriesVM()
    @StateObject var profile = ProfileVM()
    @State var showLogIn = true
    
    var body: some View {
        if authManager.isLoggedIn {
            content
        } else{
            SignInView(showLogIn: $showLogIn, userVM: userVM)
        }
    }
    
    var content: some View {
        NavigationStack {
            Text(profileVM.profile.brand)
            if profileVM.profile.seriesIds.isEmpty {
                VStack {
                    Spacer()
                    Text("You haven't created any series yet.")
                        .font(theme.typography.subtitle)
                }
            }
            
            Spacer()
            NavigationLink(
                destination: SeriesUpdateView(seriesVM: seriesVM)
                    .environmentObject(profileVM)
                    .onAppear{ seriesVM.series = Series() },
                label: {
                    Text("Create Series")
                }
            )
            .modifier(NavigationLinkStyle(theme: theme))
            
            Divider()
            
            List(seriesVM.seriesList) { series in
                NavigationLink(destination: SeriesView(seriesVM: seriesVM, series: series, mode: .update).environmentObject(profileVM))
                {
                    AsyncImage(url: series.poster, content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 50)
                    }) {
                        ProgressView()
                    }
                    Text(series.title)
                }
                .font(theme.typography.subtitle)
                // .modifier(NavigationLinkStyle(theme: theme))
            }
            .padding()
            
        }
        .task {
            await loadSeries()
        }
        
//        .onChange(of: profileVM.profile.seriesIds.last) { _ in
//            Task {
//                print("series count: \(seriesVM.seriesList.count)")
//                await loadSeries()
//            }
//        }
    }
    
    @MainActor
    private func loadSeries() async {
        if authManager.isLoggedIn {
            profileVM.profile.id = userVM.user.profileIds[0]
            await profileVM.fetch()
            if !profileVM.profile.seriesIds.isEmpty {
                seriesVM.seriesIds = profileVM.profile.seriesIds
                await seriesVM.fetch()
            }
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
