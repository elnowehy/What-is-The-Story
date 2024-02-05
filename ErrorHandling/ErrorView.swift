//
//  ErrorView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-02-05.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject var errorHandlingVM: ErrorHandlingVM

    var body: some View {
        Group {
            if errorHandlingVM.showError {
                // You can customize this view to be an alert, banner, etc.
                Text(errorHandlingVM.errorMessage)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .clipShape(Capsule())
                    // Use .onTapGesture or other modifiers to handle user interaction
            }
        }
        // Positioning and other modifiers to ensure the error view is properly presented
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .transition(.slide) // Add transitions for smoother appearance/disappearance
        .onTapGesture {
            errorHandlingVM.dismissError()  // Method to reset the error state
        }
    }
}
