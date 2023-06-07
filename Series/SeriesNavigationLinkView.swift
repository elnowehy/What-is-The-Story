//
//  SeriesNavigationLinkView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-07.
//

import SwiftUI

struct SeriesNavigationLinkView: View {
    let series: Series
    
    var body: some View {
        // Series image
        AsyncImage(url: series.poster)
            .scaledToFit()
            .frame(width: 50, height: 50)
            .cornerRadius(4)
        
        // Series details
        VStack(alignment: .leading, spacing: 8) {
            Text(series.title)
                .font(.headline)
            Text(series.synopsis)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
    }
}

//struct SeriesNavigationLinkView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesNavigationLinkView()
//    }
//}
