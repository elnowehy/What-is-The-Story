//
//  ProfileVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation

class ProfileVM: ObservableObject{
    // private var profileId: String
    @Published var profile: Profile
    private var profileManager: ProfileManager
    
    init(profile: Profile) {
        self.profile = profile
        self.profileManager = ProfileManager(profile: profile)
    }
    
    // fetch data from Firebase and populate "profile"
    // input: Profile struct with the profile id populated
    // output: profile struc is populated
    // return: Void
    func fetch() async {
        Task {
            await profileManager.fetchProfile()
            profile = profileManager.profile
        }
    }
    
    // create Profile document in Firebase and
    // input: empty Profile struct
    // output: profile strucct is populated
    // return: Profile Id
    @MainActor
    func create() async -> String {
        async let profileId = profileManager.addProfile()
        profile.id = await profileId
        return profile.id
        
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
    func update() async {
        Task {
            await profileManager.updateProfile()
            profile = profileManager.profile // in case something happens during the update to the data
        }
    }
    
    // remove a profile from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func remove() {
        profileManager.removeProfile()
        // I'm sure much more needs to be done
    }
}
