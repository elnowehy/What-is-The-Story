//
//  UserVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI
//  Manages User data through UserManager. Acts as an abstraction layer
//  for the underlying database.
//  UserVM.user is populated by the calling function/view, before
//  executing any of the functions
class UserVM: ObservableObject{
    @Published var profile = Profile()
    @Published var user = User()
    private var userManager: UserManager
    private var profileManager = ProfileManager()
    // @EnvironmentObject var authManager: AuthManager
    
    init() {
        self.userManager = UserManager()
    }

    /*
    init() {
        userManager = UserManager() // current user
        self.user =  userManager.user
    }
    */
    // fetch data from Firebase and populate User
    // input: User struct with the user uid populated
    // output: User struc is populated
    // return: Void
    @MainActor
    func fetch() async {
        userManager.user = user
        await userManager.fetch()
        user = userManager.user
    }
    
    // create User document in Firebase.
    // ** the document id should be the same as the authentication one **
    // input: empty User struct with User.uid populated from the authentication id
    // output: user struct is populated
    @MainActor
    func create() async {
        let profileVM = ProfileVM()
        async let profileId = await profileVM.create()
        await user.profileIds.append(profileId)
        // userManager.user.profileIds = user.profileIds
        userManager.user = user
        await userManager.create()
        // authManager.isLoggedIn = true
        // user = userManager.user
        
    }
    
    // updates a user with the user data. ** this ideally shouldn't happen, but maybe if they want to change their email?
    // input: a populated User struct
    // output: an updaetd User struct
    // return: Void
    @MainActor
    func update() async {
        userManager.user = user
        await userManager.create()
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
        user = await userManager.currentUserData()
    }
}
