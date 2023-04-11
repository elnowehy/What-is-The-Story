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
    // @State var user = User()
    @StateObject var userVM: UserVM
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Back")
                    .font(.headline)
                    .offset(x: -100, y: -100)
                
                TextField("Email", text: $userVM.user.email)
                    .offset(x: 50, y: -50)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                
                SecureField("Password", text: $userVM.user.password)
                    .offset(x: 50, y: -50)
                    .submitLabel(.done)
                
            }
            .padding()
            VStack {
                HStack {
                    Button(action: {
                        Task {
                            await userVM.user.id = authManager.signIn(emailAddress: userVM.user.email, password: userVM.user.password)
                            // userVM.user = user
                            await userVM.fetch()
                            showLogIn = false
                            authManager.isLoggedIn = true
                            dismiss()
                        }
                    })
                    {
                        Text("Sign In")
                    }
                    .padding()
                    
                    NavigationLink("SignUp", destination: SignUpView(showLogIn: $showLogIn, userVM: userVM))
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
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var showLogIn = true
//        return SignInView(showLogIn: $showLogIn)
//    }
//}


