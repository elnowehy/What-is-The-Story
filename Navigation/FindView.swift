//
//  FindView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-15.
//

import SwiftUI

struct FindView: View {
    @State private var scrollTarget: String?

    var body: some View {
        // Vertical list of letters
        VStack {
            ForEach(0..<26) { i in
                let letter = String(UnicodeScalar(i + 65)!)
                Text(letter)
                    .onTapGesture {
                        scrollTarget = letter
                    }
            }
        }

        // Main series list
//        ScrollViewReader { proxy in
//            ScrollView {
//                ForEach(seriesList) { series in
//                    Text(series.title)
//                        .id(series.title.first)
//                }
//                .onChange(of: scrollTarget) { target in
//                    if let target = target {
//                        proxy.scrollTo(target, anchor: .top)
//                    }
//                }
//            }
//        }
    }
}


struct FindView_Previews: PreviewProvider {
    static var previews: some View {
        FindView()
    }
}
