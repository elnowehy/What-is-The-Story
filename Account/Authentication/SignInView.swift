//
//  SignInView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-17.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var pathRouter: PathRouter
    

    var body: some View {
        NavigationStack(path: $pathRouter.path) {
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
                    
                    NavigationLink("SignUp", destination: SignUpView())
                        .padding()
                }
                .frame(width: 350, height: 400)
                .foregroundColor(.black)
                
            }
        }
        /*.alert(authManager.alertMessage, isPresented: $authManager.showingAlert) {
         Button("OK", role: .cancel) {}
         }*/
    }
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        return SignInView()
    }
}


