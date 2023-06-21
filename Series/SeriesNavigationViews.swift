//
//  SeriesNavigationLinkView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-07.
//

import SwiftUI

struct SeriesRow: View {
    let series: Series
    let seriesVM: SeriesVM
    @EnvironmentObject var theme: Theme

    var body: some View {
        NavigationLink(destination: SeriesView(seriesVM: seriesVM, series: series)) {
            SeriesNavigationLinkView(series: series)
        }
    }
}

struct SeriesNavigationLinkView: View {
    let series: Series
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        // Series image
        AsyncImage(url: series.poster) { image in
            image
                .resizable()
                .cardStyle(theme: theme)
               
        } placeholder: {
            ProgressView()
        }
    }
}

//struct SeriesNavigationLinkView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesNavigationLinkView()
//    }
//}
