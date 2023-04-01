//
//  SeriesWelcome.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-27.
//

import SwiftUI

struct CreateView: View {
    @EnvironmentObject var profileVM: ProfileVM
    @StateObject var seriesVM = SeriesVM()
    @State var series = Series()
    
    var body: some View {
        NavigationStack {
            if profileVM.profile.seriesIds.isEmpty {
                VStack {
                    Spacer()
                    Text("You haven't created any series yet.")
                    
                }
            }
            
            Spacer()
            NavigationLink(
                destination: SeriesUpdate(series: $series),
                label: { Text("Create Series") }
            )
            Divider()
            
            List(seriesVM.seriesList) { series in
                NavigationLink(destination: SeriesView(series: series)) {
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
            if !profileVM.profile.seriesIds.isEmpty {
                seriesVM.seriesIds = profileVM.profile.seriesIds
                await seriesVM.fetch()
        }
//        .onAppear {
//            Task {
//                await profileVM.fetch()
//                if !profileVM.profile.seriesIds.isEmpty {
//                    seriesVM.seriesIds = profileVM.profile.seriesIds
//                    await seriesVM.fetch()
//                }
//            }
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
