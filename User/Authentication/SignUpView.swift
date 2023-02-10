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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var pathRouter: PathRouter
    
    
    var body: some View {
        NavigationStack(path: $pathRouter.path) {
            VStack  {
                Group {
                    VStack {
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
                            await user.uid = authManager.signUp(emailAddress: user.email, password: user.password)
                            
                            
                            if(!user.uid.isEmpty) {
                                let userMV = UserVM(user: user)
                                userMV.create()
                                user.uid = userMV.user.uid
                            } else {
                                print("we have a problem")
                            }
                        }
                        
                       // if(authManager.isLoading) {
                       //     pathRouter.path.append("ProgressView")
                       // } else {
                       //     pathRouter.path.append("UserView")
                       //  }
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
                
                .navigationDestination(for: String.self) { view in
                    if view == "UserView" {
                        UserView(user: user)
                    }  else if view == "ProgressView" {
                        ProgressView()
                    } else {
                        SignUpView()
                    }
                }
                
                .frame(width: 350, height: 500)
                .foregroundColor(.black)
                
                
               .navigationBarBackButtonHidden(true)
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
