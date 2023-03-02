//
//  UserVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation

@MainActor
class UserVM: ObservableObject{
    @Published var user: User
    @Injected private var profile: Profile
    private var userManager: UserManager
    
    init(user: User) {
        self.user = user
        self.userManager = UserManager(user: user)
    }
    
    init() {
        userManager = UserManager() // current user
        self.user =  userManager.user
    }
    
    // fetch data from Firebase and populate User
    // input: User struct with the user uid populated
    // output: User struc is populated
    // return: Void
    func fetch() {
        Task {
            await userManager.fetch()
            user = userManager.user
        }
    }
    
    // create User document in Firebase.
    // ** the document id should be the same as the authentication one **
    // input: empty User struct with User.uid populated from the authentication id
    // output: user struct is populated
    func create() async {
        let profileVM = ProfileVM()
        Task {
            async let profileId = profileVM.create() // ** Problem **: for some reason the following code doesn't wait for this line
            user.profileIds.append(await profileId)
            userManager.user.profileIds = user.profileIds
            
            await userManager.create()
            user = userManager.user
        }
    }
    
    // updates a user with the user data. ** this ideally shouldn't happen, but maybe if they want to change their email?
    // input: a populated User struct
    // output: an updaetd User struct
    // return: Void
    func update() {
        Task {
            await userManager.create()
            user = userManager.user // in case something happens during the update to the data
        }
    }
    
    // remove a user from Firebase
    // input: User struct with uid populated
    // output: no ouput
    // retrun: Void
    func remove() {
        userManager.remove()
    
        // there is more to this, all related data in Firebase. I'm not sure if I'll even allow it.
    }
}
