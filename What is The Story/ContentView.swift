//
//  ContentView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-10.
//

import SwiftUI
   

struct ContentView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var errorHandlingVM: ErrorHandlingVM
    
    var body: some View {
        ZStack {
            if let episdeID = navigationManager.selectedEpisodeID {
                EpisodeViewLink(episodeID: episdeID)
            } else {
                HomeTabView()
                    .background(theme.colors.primaryBackground.edgesIgnoringSafeArea(.all))
            }
            
            ErrorView(errorHandlingVM: errorHandlingVM)
                .zIndex(1.0)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
