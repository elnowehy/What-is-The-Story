//
//  UserVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation

class UserVM: ObservableObject{
    @Published var user: User
    private var userManager: UserManager
    
    init(user: User) {
        self.user = user
        self.userManager = UserManager(user: user)
    }
    
    // fetch data from Firebase and populate User
    // input: User struct with the user uid populated
    // output: User struc is populated
    // return: Void
    func fetch() {
        Task {
            await userManager.fetchUser()
            user = userManager.user
        }
    }
    
    // create User document in Firebase. ** the document id should be the same as the authentication one **
    // input: empty User struct with User.uid populated from the authentication id
    // output: user struct is populated
    func create()  {
        let profileVM = ProfileVM(profile: Profile(id: ""))
        Task {
            profileVM.create()
            user.profileId = profileVM.profile.id
            userManager.user.profileId = user.profileId
            
            await userManager.setUser()
            user = userManager.user
        }
    }
    
    // updates a user with the user data. ** this ideally shouldn't happen, but maybe if they want to change their email?
    // input: a populated User struct
    // output: an updaetd User struct
    // return: Void
    func update() {
        Task {
            await userManager.setUser()
            user = userManager.user // in case something happens during the update to the data
        }
    }
    
    // remove a user from Firebase
    // input: User struct with uid populated
    // output: no ouput
    // retrun: Void
    func remove() {
        
        userManager.removeUser()
    
        // there is more to this, all related data in Firebase. I'm not sure if I'll even allow it.
    }
}
