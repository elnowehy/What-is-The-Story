//
//  ProfileVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI

class ProfileVM: ObservableObject{
    @Injected var profile: Profile
    var info = ProfileInfo()
    private var profileManager: ProfileManager
    private var profileInfoManager: ProfileInfoManager
    

    init() {
        profileManager = ProfileManager()
        profileInfoManager = ProfileInfoManager()
    }


    // fetch data from Firebase and populate "profile"
    // input: Profile struct with the profile id populated
    // output: profile struc is populated
    // return: Void
    func fetch() {
        Task {
            await profileManager.fetch()
            profile = profileManager.profile
        }
    }
    
    // create Profile document in Firebase and
    // input: empty Profile struct
    // output: profile strucct is populated
    // return: Profile Id
    func create() async -> String {
        async let profileId = profileManager.create()
        profile.id = await profileId
        await profileInfoManager.create()
        return await profileId
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
    func update() {
        Task {
            await profileManager.update()
            profile = profileManager.profile // in case something happens during the update to the data
        }
    }
    
    // remove a profile from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func remove() {
        
        profileManager.remove()
        // I'm sure much more needs to be done, e.g. remove from Profile.Creation
        
    }
    
    // *********************
    // **** ProfileInfo ****
    // *********************
    
    // fetch info data from Firebase and populate "info"
    // input: Profile struct with the profile id populated
    // output: info struc is populated
    // return: Void
    func fetchInfo() {
        Task {
            // profileInfoManager.profileId = profile.id
            await profileInfoManager.fetch()
            info = profileInfoManager.info
        }
    }
    
    // create Profile document in Firebase and
    // input: empty Profile struct
    // output: profile strucct is populated
    // return: Profile Id
    func createInfo() {
        Task {
            await profileInfoManager.create()
        }
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
    func updateInfo()  {
        Task {
            // profileInfoManager.profileId = profile.id
            await profileInfoManager.update()
            info = profileInfoManager.info // in case something happens during the update to the data
        }
    }
    
    // remove a profile info from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func removeInfo() {
        profileInfoManager.remove()
        // I'm sure much more needs to be done
    }
}
