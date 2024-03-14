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
    // private var crashlyricsManager = CrashlyticsManager()
    private var errorReporter: ErrorReporting
    
    init(errorReporter: ErrorReporting) {
        self.errorReporter = errorReporter
    }

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
        errorReporter.logError(error)
    }
    
    func UIErrorMessage(for error: Error) -> String {
        switch error {
        case let error as AppError:
            switch error {
            case .network(let errorCode):
                // Handle network error codes and return specific messages
                return "Network Error: \(errorCode)"
            case .database(let errorCode):
                // Handle database error codes and return specific messages
                return "Database Error: \(errorCode)"
            case .authentication(let errorCode):
                // Handle authentication error codes and return specific messages
                return "Authentication Error: \(errorCode)"
            case .unknown:
                return "An unknown error occurred."
            }
        default:
            return "An unexpected error occurred."
        }
    }
}
