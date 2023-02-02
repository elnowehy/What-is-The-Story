//
//  WriteUser.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-10.
//

import SwiftUI
import Firebase

struct SignUpView: View {
    @State var user: User = User(uid: "", name: "", email: "", password: "", sponsor: "", tokens: 0)
    @EnvironmentObject var authManager: AuthManager
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack  {
                Text("Welcome to WITS")
                    .font(.headline)
                    .offset(x: -100, y: -100)
                Group  {
                    HStack {
                        Text("Email")
                            .foregroundColor(.gray)
                        TextEditor(text: $user.email)
                            .offset(x: 100, y: -50)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.next)
                    }
                    
                    HStack {
                        Text("Password")
                        SecureField("password", text: $user.password)
                            .offset(x: 100, y: -50)
                            .submitLabel(.done)
                    }
                    
                    
                    HStack {
                        Text("User Name:")
                        TextEditor(text: $user.name)
                            .frame(width: .infinity, height: 50)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .foregroundColor(.black)
                .padding()
            

                HStack {
                    Button (action: {
                        authManager.user = user
                        authManager.signUp()
                        if authManager.isLoggedIn {
                            path.append("AccountView")
                        }
                    }) {
                        Text("Save")
                    }
                    .padding()
                    
                    Button (action: {
                        path.append("SignInView")
                    }) {
                        Text("Canel")
                    }
                    .padding()
                }
                .navigationDestination(for: String.self) { view in
                    if view == "AccountView" {
                        AccountView(user: authManager.user)
                    } else if view == "SignInView" {
                        SignInView()
                    } /* else if view == "SignUpView" {
                        // SignUpView()
                        // path.removeLast()
                        print("\(view)")
                    } */
                }
                .frame(width: 350, height: .infinity)
                .foregroundColor(.black)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}


struct SignUpUserView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

enum AuthStatus{
    case success
    case emailAlreadyInUse
    case failure(error: Error)
}

/*
 struct EmailInputView: View {
 var placeHolder: String = ""
 @Binding var txt: String
 
 var body: some View {
 TextField(placeHolder, text: $txt)
 .keyboardType(.emailAddress)
 .onReceive(Just(txt)) { newValue in
 let validString = newValue.filter { "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._-+$!~&=#[]@".contains($0) }
 if validString != newValue {
 self.txt = validString
 }
 }
 }
 }
 */
