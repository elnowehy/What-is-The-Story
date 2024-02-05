//
//  ErrorHandlingVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-02-04.
//

import Foundation

class ErrorHandlingVM: ObservableObject, ErrorHandling {
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    func handleError(_ error: Error) {
        // Log the error
        logError(error)
        
        // Optionally, prepare and show an error message to the user
        let message = UIErrorMessage(for: error)
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
    
    func dismissError() {
        showError = false
    }
    
    func logError(_ error: Error) {
        // Implement the logging logic here, e.g., print to console, send to Crashlytics
        print(error.localizedDescription)
    }
    
    func UIErrorMessage(for error: Error) -> String {
        // Translate the error into a user-friendly message
        return "Something went wrong. Please try again."
    }
}
