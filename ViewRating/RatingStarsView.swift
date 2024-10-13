//
//  RatingStarts.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-08.
//

import SwiftUI

extension View {
    func ratingStarsView(rating: Double, isInteractive: Bool, onTap: ((Int) -> Void)?) -> some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                let doubleIndex = Double(index)
                Image(systemName: "star.fill")
                    .foregroundColor(doubleIndex <= rating ? .yellow : .gray)
                    .scaleEffect(doubleIndex == rating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: rating)
                    .onTapGesture {
                        if isInteractive {
                            onTap?(index)
                        }
                    }
            }
        }
    }
}
