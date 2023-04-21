//
//  VideoListView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-14.
//

import SwiftUI

struct VideoListView: View {
    var body: some View {
        VStack {
            AsyncImage(url: /*@START_MENU_TOKEN@*/URL(string: "https://example.com/icon.png")/*@END_MENU_TOKEN@*/)
                .frame(width: 360.0, height: 200.0)
            Spacer()
            Text("Hello, List!")
            Spacer()
        }
    }
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
