//
//  UserVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI

class UserVM: ObservableObject{
    @Injected var profile: Profile
    @Injected var user: User
    private var userManager: UserManager
    // @EnvironmentObject var authManager: AuthManager
    
    init() {
        self.userManager = await UserManager(user: user)
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
        await userManager.create()
        user = userManager.user // in case something happens during the update to the data
    }
    
    // remove a user from Firebase
    // input: User struct with uid populated
    // output: no ouput
    // retrun: Void
    @MainActor
    func remove() async {
        await userManager.remove()
        // there is more to this, all related data in Firebase. I'm not sure if I'll even allow it.
    }
   
    @MainActor
    func currentUserData() async {
        user = await userManager.currentUserData()
    }
}
