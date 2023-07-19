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
    @StateObject var userVM: UserVM
    @State private var password = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var pathRouter: PathRouter
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Back")
                    .modifier(LargeTitleStyle(theme: theme))
                
                TextField("Email", text: $userVM.user.email)
                    .textFieldStyle(TextFieldLoginStyle(theme: theme))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(TextFieldLoginStyle(theme: theme))
                    .submitLabel(.done)
                
            }
            .padding()
            VStack {
                HStack {
                    Button(action: {
                        Task {
                            await userVM.user.id = authManager.signIn(emailAddress: userVM.user.email, password: password)
                            await userVM.fetch()
                            showLogIn = false
                            authManager.isLoggedIn = true
                            dismiss()
                        }
                    })
                    {
                        Text("Sign In")
                    }
                    .buttonStyle(ButtonBaseStyle(theme: theme))
                    
                    NavigationLink("SignUp", destination: SignUpView(showLogIn: $showLogIn, userVM: userVM))
                        .modifier(NavigationLinkStyle(theme: theme))
                }
            }
        }
    }
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var showLogIn = true
//        return SignInView(showLogIn: $showLogIn)
//    }
//}


