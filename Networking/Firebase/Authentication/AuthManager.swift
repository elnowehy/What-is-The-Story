//
//  AuthManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-23.
//
// A class that handles singning, creating and logging out users in Firebase

// import SwiftUI
import FirebaseAuth
// import //  FirebaseFireStoreSwift
import KeychainAccess


typealias FireBaseUser = FirebaseAuth.User

final class AuthManager: ObservableObject {
    private let keychain = Keychain(service: "com.elnowehy.wits.What-is-The-Story")
    @Published var isLoggedIn: Bool  = false {
        didSet {
            storeSessionState()
        }
    }
    
    var fbUser: FireBaseUser? {
        didSet {
            objectWillChange.send()
        }
    }
   

    init()  {
        self.isLoggedIn = loadSessionState()
        self.listenToAuthState()
    }
    
    // MARK: - Keychain Storage for User Session
    private func storeSessionState() {
        do {
            try keychain.set(isLoggedIn ? "true" : "false", key: "isLoggedIn")
            if let uid = fbUser?.uid {
                try keychain.set(uid, key: "firebaseUID")
            }
        } catch {
            print("Error storing session state in Keychain: \(error)")
        }
    }

    private func loadSessionState() -> Bool {
        do {
            if let isLoggedInValue = try keychain.get("isLoggedIn") {
                return isLoggedInValue == "true"
            }
        } catch {
            print("Error loading session state from Keychain: \(error)")
        }
        return false
    }
    
    func listenToAuthState() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
