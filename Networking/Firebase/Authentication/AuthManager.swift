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
@MainActor
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
    
    func signUp (emailAddress: String, password: String) async -> String {
        var userId: String = ""
        do {
            let result = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
            let user = result.user
            // self.isLoggedIn = true
            userId  = user.uid
        }
        catch {
            print("an error occured: \(error.localizedDescription)")
        }
        return userId
    }
    
    func signIn (emailAddress: String, password: String) async -> String {
        var userId: String = ""
        do {
            let result = try await Auth.auth().signIn(withEmail: emailAddress, password: password)
            userId = result.user.uid
            // self.isLoggedIn = true
        }
        catch {
            print("an error occured: \(error.localizedDescription)")
        }
        return userId
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        self.isLoggedIn = false
    }
}
