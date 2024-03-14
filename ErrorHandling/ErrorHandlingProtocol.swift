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

// for backend error reporting
protocol ErrorReporting {
    func logError(_ error: Error)
}

enum AppErrorDomain: String {
    case network = "com.wits.network"
    case database = "com.wits.database"
    case userAuthentication = "com.wits.authentication"
    // ... other domains
}

enum NetworkErrorCode: Int {
    case connectionFailed = 100
    case responseUnsuccessful = 101
    case invalidData = 102
    case jsonParsingFailed = 103
    // ... other network-related errors
}

enum DatabaseErrorCode: Int {
    case dataNotFound = 200
    case saveFailed = 201
    case fetchFailed = 202
    case deleteFailed = 203
    case invalidID = 205
}

enum AuthenticationErrorCode: Int {
    case invalidCredentials = 300
    case userNotFound = 301
    case accessDenied = 302
    // ... other authentication-related errors
}

enum AppError: Error {
    case network(NetworkErrorCode)
    case database(DatabaseErrorCode)
    case authentication(AuthenticationErrorCode)
    case unknown

    // Properties and methods to extract domain, code, and message can be similar to the previous example
}

