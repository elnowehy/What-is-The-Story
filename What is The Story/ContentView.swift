//
//  ContentView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-10.
//

import SwiftUI
   

struct ContentView: View {
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HomeTabView()
            .background(theme.colors.primaryBackground.edgesIgnoringSafeArea(.all))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
