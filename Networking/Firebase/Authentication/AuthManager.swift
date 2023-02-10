//
//  AuthManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-23.
//
// A class that handles singning, creating and logging out users in Firebase

import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = true
    @Published var user: User
    @Published var alertMessage = ""
    @Published var showingAlert = false
    
    
    init() {
        self.user = User(uid: "", name: "", email: "", password: "", sponsor: "", tokens: 0)
        // listenToAuthState()
        loginInStatus()
    }
    
    
    func listenToAuthState() {

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if let user = Auth.auth().currentUser {
                    self.user.uid = user.uid
                    self.user.email = user.email!
                    let userDataManager = UserManager(user: self.user)
                    // userDataManager.fetchUser()
                    self.isLoading = userDataManager.isLoading
                    self.isLoggedIn = true
                    self.user = userDataManager.user
                    // if self.isLoading { // should I make the log in status dependent on isLoading?
                    //     self.isLoggedIn = false
                    // } else {
                    //     self.isLoggedIn = true
                    // }
                } else {
                    self.isLoggedIn = false
                }
            } else {
                self.isLoggedIn = false
            }
        }
    }
    
    
    func signIn(email: String, password: String, completion: ((Error?) -> Void)? = nil) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.alertMessage = "LOGIN ERROR: " + error!.localizedDescription
                self.showingAlert = true
            } else if result != nil {
                self.isLoggedIn = true
                self.user.uid = result!.user.uid
                self.user.email = result!.user.email!
                let userDataManager = UserManager(user: self.user)
                userDataManager.fetchUser()
                self.isLoading = userDataManager.isLoading
                self.user = userDataManager.user
            } else {
                self.alertMessage = ("what the hell am I doing here? T.Y. - 1992")
                self.showingAlert = true
            }
        }
    }
    
    func signUp ()  {
        Auth.auth().createUser(withEmail: self.user.email, password: self.user.password) {(result, error) in
            if error != nil {
                //completion?(error)
                print(error!.localizedDescription)
                self.alertMessage = "SIGN UP ERROR: " + error!.localizedDescription
                self.showingAlert = true
            } else {
                // get the UID ** should I do this here? Or leave populating userManager logic somewhere else?
                // I mean how about the portoflio id? Should this be handled by UserManager?
                self.user.uid = result!.user.uid
                let userManager = UserManager(user: self.user)
                userManager.setUser()
                self.isLoggedIn = true // no need for this it's being set by listenToAuthStat 
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        // self.isLoggedIn = false //// the hope is listenToAuthState() will update it anyway
    }
    
    func loginInStatus() {
        if Auth.auth().currentUser == nil {
            self.isLoggedIn = false
        } else {
            self.isLoggedIn = true
        }
        
    }
}
