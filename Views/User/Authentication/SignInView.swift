//
//  SignInView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-17.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @State private var email = "enter your email"
    @State private var password = "123456"
    @State private var path = NavigationPath()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        
        NavigationStack(path: $path) {
            VStack {
                Group {
                    VStack {
                        Text("Welcome")
                            .font(.headline)
                            .offset(x: -100, y: -100)
                        
                        TextField("Email", text: $email)
                            .offset(x: 100, y: -50)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.next)
                        // I can't see "Email" for some reason?
                        SecureField("Password", text: $password)
                            .offset(x: 100, y: -50)
                            .submitLabel(.done)
                    }
                }
                .foregroundColor(.black)
                .padding()
                HStack {
                    Button(action: {
                        authManager.signIn(email: email, password: password)
                        if authManager.isLoggedIn {
                            path.append("AccountView")
                        }
                    })
                    {
                        Text("Sign In")
                    }
                    .padding()
                    
                    Button(action: {
                        path.append("SignUpView")
                    }) {
                        Text("Sign Up")
                    }
                    .padding()
                }
                
                /*
                .navigationDestination(for: String.self) { view in
                    if view == "AccountView" {
                        AccountView(user: authManager.user)
                    } else if view == "ProgressView" {
                        ProgressView()
                    } else if view == "SignUpView" {
                        SignUpView()
                    }
                }
                */
                .frame(width: 350, height: .infinity)
                .foregroundColor(.black)
                
            }
            /*            .onAppear {
             if !authManager.isLoading {
                path.append("AccountView")
             }
             */
        }.alert(authManager.alertMessage, isPresented: $authManager.showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        // let userData = UserData()
        // userData.user = User(name: "", email: "", password: "", sponsor: "", tokens: 0)
        return SignInView()
    }
}


