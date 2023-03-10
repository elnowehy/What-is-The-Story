//
//  WriteUser.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-10.
//

import SwiftUI
import Firebase

struct SignUpView: View {
    @Binding var showLogIn: Bool
    @State private var user  = User()
    @ObservedObject var userVM = UserVM()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack  {
            Group {
                VStack {
                    Spacer()
                    
                    Text("Welcome to WITS")
                        .font(.headline)
                        .padding()
                        .offset(x: -100, y: -100)
                    
                    
                    TextField("Email", text: $user.email)
                        .offset(x: 50, y: -50)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                    
                    
                    SecureField("Password", text: $user.password)
                        .offset(x: 50, y: -50)
                        .submitLabel(.done)
                    
                    
                    TextField("User Name", text: $user.name)
                    //.frame(width: .infinity, height: 50)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .offset(x: 50, y: -50)
                    
                }
                .padding()
                .foregroundColor(.black)
            }
            
            HStack {
                Button (action: {
                    Task {
                        await user.id = authManager.signUp(emailAddress: user.email, password: user.password)
                        if(!user.id.isEmpty) {
                            userVM.user = user
                            await userVM.create()
                            await user.id = authManager.signIn(emailAddress: user.email, password: user.password)
                            showLogIn = false
                            authManager.isLoggedIn = true
                        } else {
                            fatalError("we have a problem")
                        }
                    }                    
                }) {
                    Text("Save")
                }
                .padding()
                
                Button (action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }
                .padding()
            }
            
            .frame(width: 350, height: 300)
            .foregroundColor(.black)
            
            
            .navigationBarBackButtonHidden(true)
        }
    }
}

/*
struct SignUpUserView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(path: NavigationPath[])
    }
}
*/
enum ViewOption{
    case success
    case emailAlreadyInUse
    case failure(error: Error)
}

