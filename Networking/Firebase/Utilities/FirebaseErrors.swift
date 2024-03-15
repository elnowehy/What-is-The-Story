//
//  CrashlyticsManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-02-27.
//

import FirebaseCrashlytics
import FirebaseAuth

class CrashlyticsManager: ErrorReporting {
    
    func logError(_ error: Error) {
        // Access the shared Crashlytics instance
        let crashlytics = Crashlytics.crashlytics()
        
        // Check if the error is of type AppError for detailed logging
        if let appError = error as? AppError {
            switch appError {
            case .network(let errorCode):
                crashlytics.setCustomValue("Network Error", forKey: "Error Type")
                crashlytics.setCustomValue(errorCode.rawValue, forKey: "Network Error Code")
            case .database(let errorCode):
                crashlytics.setCustomValue("Database Error", forKey: "Error Type")
                crashlytics.setCustomValue(errorCode.rawValue, forKey: "Database Error Code")
            case .authentication(let errorCode):
                crashlytics.setCustomValue("Authentication Error", forKey: "Error Type")
                crashlytics.setCustomValue(errorCode.rawValue, forKey: "Authentication Error Code")
            case .unknown:
                crashlytics.setCustomValue("Unknown Error", forKey: "Error Type")
            }
        }

        // Record the error to Crashlytics
        crashlytics.record(error: error)
    }
}

extension AppError {
    static func fromFirebaseError(_ error: Error) -> AppError {
        let nsError = error as NSError

        guard let authError = AuthErrorCode.Code(rawValue: nsError.code) else {
            return .unknown(error.localizedDescription)
        }
        
        switch authError {
        case .emailAlreadyInUse:
            return .authentication(.invalidCredentials)
        case .userDisabled:
            return .authentication(.accessDenied)
        case .userNotFound:
            return .authentication(.userNotFound)
        case .accountExistsWithDifferentCredential:
            return .authentication(.invalidCredentials)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}



