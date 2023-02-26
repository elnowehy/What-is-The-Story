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
// access: Gear/Settings from the AccountView



import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct UserView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var userVM = UserVM()
    
    var body: some View {
        
        VStack {
            Text("Welcome, \(userVM.user.name)")
                .font(.title)
            Text("Email: \(userVM.user.email)")
                .font(.subheadline)
            
            Spacer()
            
            Button(action: {
                Task {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("can't even log out")
                    }
                }
            })
            {
                Text("Sign Out")
            }
            .padding()
            
        }.navigationBarHidden(true)
    }
    
}


