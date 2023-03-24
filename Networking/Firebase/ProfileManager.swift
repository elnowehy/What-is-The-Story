//
//  ProfileManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage


class ProfileManager:ObservableObject {
    @Published var profile = Profile()
    public var avatarImage = UIImage()
    private var db: Firestore
    private var ref: DocumentReference?
    private var storage: Storage
    private var storageRef: StorageReference?
    private var data: [String: Any]
    
    
    init() {
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
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
            "brand": self.profile.brand,
            "avatar": await storeImage(ref: storageRef!, uiImage: avatarImage, quality: profile.imgQlty).absoluteString
        ]
    }
    
    
    func populateStruct() {
        profile.id = self.data["id"] as? String ?? ""
        profile.brand = self.data["brand"] as? String ?? ""
        profile.avatar = URL(string: self.data["avatar"] as? String ?? "")!
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
        await populateData() // I need to think about the avatar image and URL
        do {
            try await ref!.setData(self.data)
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
}


class ProfileInfoManager: ObservableObject {
    private var profile = Profile()
    @Published var info = ProfileInfo()
    public var profileId: String
    private var db: Firestore
    private var ref: DocumentReference?
    private var data: [String: Any] // dictionary
    
    init() {
        db = Firestore.firestore()
        data = [:]
        profileId = ""
    }
    
    private func setRef() {
        if profileId.isEmpty {
            fatalError("Profile id is not defined")
        }
        self.ref = self.db.collection("Profile").document(profileId).collection("ProfileInfo").document(profileId)
    }
    
    // in the future, I can make this smarter by passing updated fields only
    // but make sure you pass the full set if it's going to be used with 'create: setData'
    func populateData() {
        self.data = [
            "id": profileId,
            "statement": info.statement,
            "bio": info.bio,
            "image": info.image,
            "bgImage": info.bgImage
        ]
    }
    
    func populateStruct() {
        info.id = profileId
        info.statement = self.data["statement"] as? String ?? ""
        info.bio = self.data["bio"] as? String ?? ""
        info.image = self.data["image"] as? String ?? ""
        info.bgImage = self.data["bgImage"] as? String ?? ""
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
        populateData()
        do {
            try await ref!.updateData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func create() async  {
        setRef()
        populateData()
        do {
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

/*

 
 func test() {
     let test = self.db.collection("User").document("a55yXrgdsmSRZCKhNmci8Xqlmh93")
     test.getDocument() { document, error in print(error!.localizedDescription) }
     // self.db.collection("User")  { collection, error in
     // let test = self.db.collection("User").whereField("email", isEqualTo: self.user.email)
     db.collection("User").whereField("email", isEqualTo: self.user.email).getDocuments() { (querySnapshot, err) in
             if let err = err {
                 print("Error getting documents: \(err)")
             } else {
                 for document in querySnapshot!.documents {
                     print("\(document.documentID) => \(document.data())")
                     let data = document.data()
                     print(data["name"])
                 }
             }
     }
     // Firebase.Analytics.logEvent("Error_Creating_Collection_Reference", parameters: ["error": "help me"])
     print("Error creating reference: help him")
       test.getDocument() { document, error in
         if let document = document, document.exists {
             guard let data = document.data() else {
                 return
             }
             if let error = error {
                 Firebase.Analytics.logEvent("Error_Creating_Collection_Reference", parameters: ["error": error.localizedDescription])
                 print("Error creating reference: \(error.localizedDescription)")
             }
         }
         print("I don't know what do")
     }

 }
 
*/
