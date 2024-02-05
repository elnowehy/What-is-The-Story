//
//  ErrorHandlingProtocol.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-01-29.
//

import Foundation

protocol ErrorHandling {
    /// Handles an error by logging it, determining if it's user-facing, and possibly displaying an appropriate message.
    func handleError(_ error: Error)
    
    /// Logs an error to the console and/or an external logging service like Crashlytics.
    func logError(_ error: Error)
    
    /// Translates an error into a user-facing error message, considering localization and user-friendliness.
    func UIErrorMessage(for error: Error) -> String
}

