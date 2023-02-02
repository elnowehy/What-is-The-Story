//
//  AccountView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will show the user's account information, such as their name, email, tokens, sponsor
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

struct AccountView: View {
    var user: User
    
    var body: some View {
        
        VStack {
            Text("Welcome, \(user.name)")
                .font(.title)
            Text("Email: \(user.email)")
                .font(.subheadline)
            Text("Sponsor: \(user.sponsor)")
                .font(.subheadline)
            Text("Tokens: \(user.tokens)")
                .font(.subheadline)
        }.navigationBarHidden(true)
        // A button to logout?
    }
    
    
}


