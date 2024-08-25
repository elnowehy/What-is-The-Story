//
//  ProfileManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage



class ProfileManager: ObservableObject {
    @Published var profile = Profile()
    public var avatarImage = UIImage()
    private var db: Firestore
    private var ref: DocumentReference?
    private var storage: Storage
    private var storageRef: StorageReference?
    private var data: [String: Any]
    private var lastDocument: DocumentSnapshot?
    
    
    init() {
        self.db = AppDelegate.db
        self.storage = AppDelegate.storage
        self.data = [:]
    }
        
    func setRef() {
        if profile.id.isEmpty {
            // create a referece to populate User.profileIds during creation
            self.ref = self.db.collection("Profile").document()
            if let profileId = self.ref?.documentID {
                profile.id = profileId
            }
        }
        
        self.ref = self.db.collection("Profile").document(profile.id)
        self.storageRef = self.storage.reference().child("avatars").child("\(profile.id).jpeg")
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.profile.id,
            "userId": self.profile.userId,
            "brand": self.profile.brand,
            "tagline": self.profile.tagline,
            "avatar": await storeImage(ref: storageRef!, uiImage: avatarImage, quality: profile.imgQlty).absoluteString
        ]
    }
    
    
    func populateStruct() {
        profile.id = self.data["id"] as? String ?? ""
        profile.userId = self.data["userId"] as? String ?? ""
        profile.brand = self.data["brand"] as? String ?? ""
        profile.tagline = self.data["tagline"] as? String ?? ""
        profile.avatar = URL(string: self.data["avatar"] as? String ?? "") ?? URL(filePath: "")
        profile.seriesIds = self.data["seriesIds"] as? [String] ?? []
    }
    
    @MainActor
    func fetch() async {
        setRef()
        do {
            let document = try await ref!.getDocument()
            let data = document.data()
            if data != nil {
                self.data = data!
                self.populateStruct()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    @MainActor
//    func fetchByQuery(field: String, prefix: String, pageSize: Int) async -> [Profile]{
//        var profileList = [Profile]()
//        let endValue = prefix + "\u{f8ff}"
//        var query = db.collection("Profile")
//            .whereField(field, isGreaterThan: prefix)
//            .whereField(field, isLessThan: endValue)
//            .limit(to: pageSize)
//            
//        if let lastDocument = lastDocument {
//            query = query.start(afterDocument: lastDocument)
//        }
//        
//        do {
//            let documents = try await query.getDocuments()
//            for document in documents.documents {
//                let data = document.data()
//                if !data.isEmpty {
//                    self.data = data
//                    self.populateStruct()
//                    profileList.append(self.profile)
//                }
//            }
//            
//            lastDocument = documents.documents.last
//            
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        return profileList
//    }
    
    @MainActor
    func update() async {
        setRef()
        await populateData() // I need to think about the avatar image and URL
        do {
            try await ref!.updateData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func create() async -> String {
        do {
            setRef()
            await populateData()
            try await ref!.setData(self.data)
            return profile.id
        } catch {
            print (error.localizedDescription)
            return ""
        }
    }
    
    func remove() {
        setRef()
        ref!.delete()
    }
    
    @MainActor
    func addSeries(seriesId: String) async -> Void {
        setRef()
        do {
            try await ref!.updateData(["seriesIds": FieldValue.arrayUnion([seriesId])])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func removeSeries(seriesId: String) async -> Void {
        setRef()
        do {
            try await ref!.updateData(["seriesIds": FieldValue.arrayRemove([seriesId])])
        } catch {
            print(error.localizedDescription)
        }
    }
}


class ProfileInfoManager: ObservableObject {
    var profile = Profile()
    var info = ProfileInfo()
    public var profileId: String = ""
    public var photo = UIImage()
    public var background = UIImage()
    public var updatePhoto = false
    public var updateBackground = false
    private var db: Firestore
    private var ref: DocumentReference?
    private var storage: Storage
    private var photoRef: StorageReference?
    private var bgRef: StorageReference?
    private var data: [String: Any]

    
    init() {
        self.db = AppDelegate.db
        self.storage = AppDelegate.storage
        self.data = [:]
    }
    
    private func setRef() {
        if profileId.isEmpty {
            fatalError("Profile id is not defined")
        }
        self.ref = self.db.collection("Profile").document(profileId).collection("ProfileInfo").document(profileId)
        self.photoRef = self.storage.reference().child("photos").child("\(profileId).jpeg")
        self.bgRef = self.storage.reference().child("background").child("\(profileId).jpeg")
    }
    
    @MainActor
    func populateData() async {
        self.data = [
            "id": profileId,
            "bio": info.bio,
        ]
        if updatePhoto {
            self.data["photo"] = await storeImage(ref: photoRef!, uiImage: photo, quality: info.photoQlty).absoluteString
        }
        if updateBackground {
            self.data["background"] = await storeImage(ref: bgRef!, uiImage: background, quality: info.bgQlty).absoluteString
        }
    }
    
    func populateStruct() {
        info.id = profileId
        info.bio = self.data["bio"] as? String ?? ""
        info.photo = URL(string: self.data["photo"] as? String ?? "") ?? URL(filePath: "")
        info.background = URL(string: self.data["background"] as? String ?? "") ?? URL(filePath: "")
    }
    
    @MainActor
    func fetch() async {
        setRef()
        do {
            let document = try await ref!.getDocument()
            let data = document.data()
            if data != nil {
                self.data = data!
                self.populateStruct()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    

    
    @MainActor
    func update() async {
        setRef()
        await populateData()
        do {
            try await ref!.updateData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func create() async  {
        do {
            setRef()
            updatePhoto = true
            updateBackground = true
            await populateData()
            try await self.ref!.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func remove() {
        setRef()
        ref!.delete()
    }
}

