//
//  AuthManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-23.
//
// A class that handles singning, creating and logging out users in Firebase

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift


typealias FireBaseUser = FirebaseAuth.User

final class AuthManager: ObservableObject {
    var fbUser: FireBaseUser? {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var isLoggedIn: Bool = false

    init()  {
        self.listenToAuthState()
    }
    
    func listenToAuthState() {
         
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            
            if let currentUser = Auth.auth().currentUser {
                self.isLoggedIn = true
                self.fbUser = currentUser
            } else {
                self.isLoggedIn = false
                self.fbUser = nil
            }
        }
    }
    
    func signUp (emailAddress: String, password: String) async -> Result<String, AppError> {
        do {
            let result = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
            self.isLoggedIn = true
            return .success(result.user.uid)
        }
        catch {
            let appError = AppError.fromFirebaseError(error)
            return .failure(appError)
        }
    }
    
    func signIn (emailAddress: String, password: String) async -> Result<String, AppError> {
        do {
            let result = try await Auth.auth().signIn(withEmail: emailAddress, password: password)
            self.isLoggedIn = true
            return .success(result.user.uid)
        }
        catch {
            let appError = AppError.fromFirebaseError(error)
            return .failure(appError)
        }
    }
    
    @MainActor
    func signOut() async -> Result<Void, AppError> {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            return .success(())
        } catch let signOutError as NSError {
            let appError = AppError.fromFirebaseError(signOutError)
            return .failure(appError)
        }
    }
}
