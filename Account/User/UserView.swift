//
//  UserView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will show the user's private information, such as their name, email, tokens, sponsor
//  and referral code.
//
//  User can sign out from this view?
//
// access:
// 1. Navigatoin bar "Account"
// 2. SignInView
// 3. SignUp View


import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct UserView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var userVM = UserVM()
    
    var body: some View {
        if authManager.isLoggedIn {
            VStack {
                Text("Welcome, \(userVM.user.name)")
                    .font(.title)
                Text("Email: \(userVM.user.email)")
                    .font(.subheadline)
                Text("Sponsor: \(userVM.user.sponsor)")
                    .font(.subheadline)
                Text("Tokens: \(userVM.user.tokens)")
                    .font(.subheadline)
            }.navigationBarHidden(true)
            // A bubtton to logout
            
            // AccountTabView(isShowingAccountTab: true)
            
        } else {
            SignInView()
        }
    }
    
}


