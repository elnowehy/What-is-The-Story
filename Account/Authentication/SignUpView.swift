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
    @State private var password = ""
    @ObservedObject var userVM: UserVM
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var theme: Theme
    @State private var isSaving: Bool = false
    
    var body: some View {
        ZStack {
            VStack  {
                Group {
                    VStack {
                        Spacer()
                        
                        Text("Welcome to WITS")
                            .modifier(LargeTitleStyle(theme: theme))
                        
                        
                        TextField("Email", text: $user.email)
                            .textFieldStyle(TextFieldLoginStyle(theme: theme))
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.next)
                        
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(TextFieldLoginStyle(theme: theme))
                            .submitLabel(.done)
                        
                        
                        TextField("User Name", text: $user.name)
                            .textFieldStyle(TextFieldLoginStyle(theme: theme))
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                        
                    }
                    .padding()
                    .foregroundColor(.black)
                }
                
                HStack {
                    Spacer()
                    
                    Button (action: {
                        Task {
                            isSaving = true
                            await user.id = authManager.signUp(emailAddress: user.email, password: password)
                            if(!user.id.isEmpty) {
                                userVM.user = user
                                await userVM.create()
                                await user.id = authManager.signIn(emailAddress: user.email, password: password)
                                showLogIn = false
                                authManager.isLoggedIn = true
                            } else {
                                fatalError("we have a problem")
                            }
                            password = ""
                            isSaving = false
                        }
                    }) {
                        Text("Save")
                    }
                    .buttonStyle(ButtonBaseStyle(theme: theme))
                    
                    Spacer()
                    
                    Button (action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                    .buttonStyle(ButtonBaseStyle(theme: theme))
                    
                    Spacer()
                }
                
                .frame(width: 350, height: 300)
                .foregroundColor(.black)
                
                
                .navigationBarBackButtonHidden(true)
            }
            
            if isSaving {
                SavingProgressView()
            }
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

