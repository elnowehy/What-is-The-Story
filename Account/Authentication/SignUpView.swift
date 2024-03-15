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
    @State private var password = ""
    @State private var confPass = ""
    @ObservedObject var userVM: UserVM
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var errorHandlingVM: ErrorHandlingVM
    @State private var isSaving: Bool = false
    
    var body: some View {
        ZStack {
            VStack  {
                Group {
                    VStack {
                        Spacer()
                        
                        Text("Welcome to WITS")
                            .modifier(LargeTitleStyle(theme: theme))
                        
                        
                        TextField("Email", text: $userVM.user.email)
                            .textFieldStyle(TextFieldLoginStyle(theme: theme))
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.next)
                        
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(TextFieldLoginStyle(theme: theme))
                            .submitLabel(.done)
                        
                        SecureField("Password", text: $confPass)
                            .textFieldStyle(TextFieldLoginStyle(theme: theme))
                            .submitLabel(.done)
                        
                        
                        TextField("User Name", text: $userVM.user.name)
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
                            guard password == confPass else {
                                errorHandlingVM.handleError(AppError.authentication(.passwordMismatch))
                                return
                            }
                            isSaving = true
                            let signUpResult = await userVM.signUp(email: userVM.user.email, password: password)
                            switch signUpResult {
                            case .success:
                                await userVM.create()
                                let signInResult = await userVM.signIn(email: userVM.user.email, password: password)
                                switch signInResult {
                                case .success(let userId):
                                    userVM.user.id = userId
                                    showLogIn = false
                                    dismiss()
                                case .failure(let error):
                                    errorHandlingVM.handleError(error)
                                }
                            case .failure(let error):
                                errorHandlingVM.handleError(error)
                            }
                            password = ""
                            confPass = ""
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

