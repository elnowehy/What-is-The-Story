//
//  ProfileVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI

class ProfileVM: ObservableObject{
    @Published var profile = Profile()
    var info = ProfileInfo()
    public var avatarImage = UIImage(systemName: "person.circle")!
    public var photoImage = UIImage(systemName: "photo.artframe")!
    public var bgImage = UIImage(systemName: "scribble")!
    public var updatePhoto = false
    public var updateBackground = false
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
    @MainActor
    func fetch() async {
        profileManager.profile.id = profile.id
        await profileManager.fetch()
        profile = profileManager.profile
    }
    
    @MainActor
    func fetchProfileByBrand(brand: String) async -> [(Profile, String)] {
        var results = [(Profile, String)]()

        
        let profiles = await self.profileManager.fetchByQuery(field: "brand", prefix: brand, pageSize: AppSettings.pageSize)
        
        for profile in profiles {
            profileInfoManager.profileId = profile.id
            await profileInfoManager.fetch()
            results.append((profile, profileInfoManager.profile.tagline))
        }
        
        return results
    }
    
    // create Profile document in Firebase and
    // input: empty Profile struct
    // output: profile strucct is populated
    // return: Profile Id
    @MainActor
    func create() async -> String {
        profileManager.avatarImage = avatarImage
        async let profileId = profileManager.create()
        profile.id = await profileId
        profileInfoManager.profileId = await profileId
        profileInfoManager.photo = photoImage
        profileInfoManager.background = bgImage
        await profileInfoManager.create()
        return await profileId
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
    @MainActor
    func update() async {
        profileManager.avatarImage = avatarImage
        profileManager.profile = profile
        await profileManager.update()
    }
    
    // remove a profile from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func remove() {
        profileManager.profile = profile
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
    @MainActor
    func fetchInfo() async {
        profileInfoManager.profileId = profile.id
        await profileInfoManager.fetch()
        info = profileInfoManager.info
    }
    
    // create Profile document in Firebase and
    // input: empty Profile struct
    // output: profile strucct is populated
    // return: Profile Id
    @MainActor
    func createInfo() async {
        await profileInfoManager.create()
    }
    
    // updates a profile with the profile data
    // input: a populated Profile struct
    // output: an updaetd Profile struct
    // return: Void
    @MainActor
    func updateInfo() async {
        profileInfoManager.profileId = profile.id
        profileInfoManager.info = info
        if updatePhoto {
            profileInfoManager.photo = photoImage
            profileInfoManager.updatePhoto = true
        }
        if updateBackground {
            profileInfoManager.background = bgImage
            profileInfoManager.updateBackground = true
        }
        await profileInfoManager.update()
    }
    
    // remove a profile info from Firebase
    // input: Profile struct with witht he profile id populated
    // output: no ouput
    // retrun: Void
    func removeInfo() {
        profileInfoManager.remove()
        // I'm sure much more needs to be done
    }
    
    // this function has to be called after the series has been
    // created and we already have the seriesId
    @MainActor
    func addSeries(seriesId: String) async  {
        await profileManager.addSeries(seriesId: seriesId)
        profile.seriesIds.append(seriesId)
    }
    
    @MainActor
    func removeSeries(seriesId: String) async {
        await profileManager.removeSeries(seriesId: seriesId)
        await MainActor.run {
            profile.seriesIds.removeAll { id in
                seriesId == id
            }
        }
    }
}
