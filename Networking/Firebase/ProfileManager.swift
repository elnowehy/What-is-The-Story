//
//  ProfileManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift


class ProfileManager:ObservableObject {
    @Injected var profile: Profile
    @Published var isLoading = true
    private var db: Firestore
    private var ref: DocumentReference
    private var data: [String: Any] // dictionary
    
    init() {
        @Injected var profile: Profile! // I had to do this again, I'm running into compiler errors because I'm using the first one in the initializer
       guard let profile = profile else {
             fatalError("Profile not injected")
       }
        
        self.db = Firestore.firestore()
        self.data = [:]
        
        if profile.id.isEmpty {
            self.ref = self.db.collection("Profile").document()
        } else {
            self.ref = self.db.collection("Profile").document(profile.id) // will return a Document reference for a unsaved one
        }
        
    }
        


    func populateData() {
        self.data = [
            "id": profile.id,
            "brand": profile.brand,
            "avatar": profile.avatar,
            ]
    }
    
    func populateStruct() {
        profile.id = self.data["id"] as? String ?? ""
        profile.brand = self.data["brand"] as? String ?? ""
        profile.avatar = self.data["avatar"] as? String ?? ""
    }
    
    @MainActor
    func fetch() async {
        do {
            let document = try await ref.getDocument()
            let data = document.data()
            if data != nil {
                self.data = data!
                self.data["id"] = document.documentID
                self.populateStruct()
            }
        } catch {
                print(error.localizedDescription)
        }
    }
    
    @MainActor
    func update() async {
        populateData()
        do {
            try await ref.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func create() async -> String {
        populateData()
        
        self.ref = db.collection("Profile").addDocument(data: self.data)
        self.data["id"] = ref.documentID
        do {
            try await self.ref.updateData(["id": ref.documentID])
            return ref.documentID
        } catch {
            print (error.localizedDescription)
            return ""
        }
    }
    
    func remove() {
        ref.delete()
    }
}


class ProfileInfoManager: ObservableObject {
    @Injected var profile: Profile
    @Published var info = ProfileInfo()
    @Published var isLoading = true
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
            "bgColor": info.bgColor
        ]
    }
    
    func populateStruct() {
        info.id = profileId
        info.statement = self.data["statement"] as? String ?? ""
        info.bio = self.data["bio"] as? String ?? ""
        info.image = self.data["image"] as? String ?? ""
        info.bgColor = self.data["bgcolor"] as? String ?? ""
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
