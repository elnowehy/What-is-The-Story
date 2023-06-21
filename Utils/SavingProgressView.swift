//
//  SavingProgressView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-18.
//

import SwiftUI

struct SavingProgressView: View {
    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea() // Covers the whole screen
            .overlay(
                VStack {
                    ProgressView() // Default loading indicator
                    Text("Saving...")
                        .foregroundColor(.white)
                        .font(.title)
                }
            )
    }
}

struct SavingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SavingProgressView()
    }
}
