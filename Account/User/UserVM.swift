//
//  UserVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI
import CryptoKit
//  Manages User data through UserManager. Acts as an abstraction layer
//  for the underlying database.
//  UserVM.user is populated by the calling function/view, before
//  executing any of the functions
class UserVM: ObservableObject{
    @Published var profile = Profile()
    @Published var user = User()
    @Published var error: Error?
    private var userManager = UserManager()
    private var profileManager = ProfileManager()
    private var authManager = AuthManager()
    var isLoggedIn: Bool {
        return authManager.isLoggedIn
    }

    
    init() {
        Task {
            await updateUserData()
        }
    }
    
    @MainActor
    private func updateUserData() async {
        if isLoggedIn {
            if let _user = authManager.fbUser {
                self.user.id = _user.uid
                await fetch()
            } else {
                self.error = AppError.authentication(.noCurrentUser)
            }
        }
    }

    // fetch data from Firebase and populate User
    // input: User struct with the user uid populated
    // output: User struc is populated
    // return: Void
    @MainActor
    func fetch() async {
        do {
            userManager.user = user
            try await userManager.fetch()
            user = userManager.user
        } catch {
            self.error = error
        }
    }
    
    // create User document in Firebase.
    // ** the document id should be the same as the authentication one **
    // input: empty User struct with User.uid populated from the authentication id
    // output: user struct is populated
    @MainActor
    func create() async {
        do {
            let profileVM = ProfileVM()
            async let profileId = await profileVM.create()
            await user.profileIds.append(profileId)
            user.invitationCode = generateInvitationCode(name: user.name, profileId: await profileId)
            userManager.user = user
            try await userManager.create()
            user = userManager.user
            profileVM.profile.userId = userManager.user.id
            profileVM.profile.brand = user.name
            await profileVM.update()
        } catch {
            self.error = error
        }
    }
    
    // updates a user with the user data. ** this ideally shouldn't happen, but maybe if they want to change their email?
    // input: a populated User struct
    // output: an updaetd User struct
    // return: Void
    @MainActor
    func update() async {
        do {
            userManager.user = user
            try await userManager.update()
            user = userManager.user
        } catch {
            self.error = error
        }
    }
    
    // remove a user from Firebase
    // input: User struct with uid populated
    // output: no ouput
    // retrun: Void
    @MainActor
    func remove() async {
        userManager.user = user
        await userManager.remove()
        // there is more to this, all related data in Firebase. I'm not sure if I'll even allow it.
    }
   
    @MainActor
    func currentUserData() async {
        do {
            user = try await userManager.currentUserData()
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func signUp(email: String, password: String) async -> Result<String, AppError>  {
        let result = await authManager.signUp(emailAddress: email, password: password)
        
        switch result {
        case .success(let userId):
            await updateUserData()
            return .success(userId)
        case .failure(let error):
            self.error = error
            return .failure(error)
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async -> Result<String, AppError> {
        let result = await authManager.signIn(emailAddress: email, password: password)
        
        switch result {
        case .success(let userId):
            await updateUserData()
            return .success(userId)
        case .failure(let error):
            self.error = error
            return .failure(error)
        }
    }

    
    @MainActor
    func signOut() async {
        let result = await authManager.signOut()
        
        switch result {
        case .success(()):
            user = User()
        default:
            self.error = error
        }

    }
    
    private func generateInvitationCode(name: String, profileId: String) -> String {
        let profile = String(profileId.prefix(4))
        let short = String(name.prefix(2)).lowercased()
        
        let rawCode = profile + short
        
        if let data = rawCode.data(using: .utf8) {
            let hashed = SHA256.hash(data: data)
            // Convert the hash to a hexadecimal string
            let hexString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            let code = String(hexString.prefix(8))
            return code
        } else {
            print("Invitation code not generated")
            return "InvitationCodeNotGenerated"
        }
    }
}
