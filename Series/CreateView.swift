//
//  SeriesWelcome.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-27.
//

import SwiftUI

struct CreateView: View {
    @EnvironmentObject var profileVM: ProfileVM
    @EnvironmentObject var theme: Theme
    @StateObject var seriesVM = SeriesVM()
    @State var series = Series()
    
    var body: some View {
        NavigationStack {
            Text(profileVM.profile.id)
            if profileVM.profile.seriesIds.isEmpty {
                VStack {
                    Spacer()
                    Text("You haven't created any series yet.")
                    
                }
            }
            
            Spacer()
            NavigationLink(
                destination: SeriesUpdateView(seriesVM: seriesVM).environmentObject(profileVM),
                label: { Text("Create Series") }
            )
            Divider()
            
            List(seriesVM.seriesList) { series in
                NavigationLink(destination: SeriesView(seriesVM: seriesVM, series: series).environmentObject(profileVM))
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
            }
            
        }
        .task {
            await profileVM.fetch()
            print(profileVM.profile.id)
            if !profileVM.profile.seriesIds.isEmpty {
                seriesVM.seriesIds = profileVM.profile.seriesIds
                await seriesVM.fetch()
            }
        }
        .modifier(NavigationLinkStyle(theme: theme))
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
