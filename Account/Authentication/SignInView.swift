//
//  SignInView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-17.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @Binding var showLogIn: Bool
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Back")
                    .font(.headline)
                    .offset(x: -100, y: -100)
                
                TextField("Email", text: $email)
                    .offset(x: 50, y: -50)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                
                SecureField("Password", text: $password)
                    .offset(x: 50, y: -50)
                    .submitLabel(.done)
                
            }
            .padding()
            VStack {
                HStack {
                    Button(action: {
                        Task {
                            await authManager.signIn(emailAddress: email, password: password)
                            dismiss()
                        }
                    })
                    {
                        Text("Sign In")
                    }
                    .padding()
                    
                    NavigationLink("SignUp", destination: SignUpView(showLogIn: $showLogIn))
                        .padding()
                    
                    Button(action: { dismiss()} )
                    {
                        Text("Cancel")
                    }
                    .padding()
                }
                .frame(width: 350, height: 400)
                .foregroundColor(.black)
            }
        }
    }
    /*.alert(authManager.alertMessage, isPresented: $authManager.showingAlert) {
     Button("OK", role: .cancel) {}
     }*/
    /*
     .onChange(of: pathRouter.path) { path in
     if !authManager.isLoggedIn {
     pathRouter.path = NavigationPath(SignInView())// redirect to sign in if not logged in
     }
     }
     */
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        @State var showLogIn = true
        return SignInView(showLogIn: $showLogIn)
    }
}


