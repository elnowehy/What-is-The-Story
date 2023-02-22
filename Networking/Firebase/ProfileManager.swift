//
//  ProfileManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Swinject

@MainActor
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
        let id = profile.id
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
            "name": profile.name,
            "statement": profile.statement,
            "bio": profile.bio,
            "image": profile.image,
            "avatar": profile.avatar,
            "bgcolor": profile.bgColor,
            ]
    }
    
    func populateProfile() {
        profile.id = self.data["id"] as? String ?? ""
        profile.name = self.data["name"] as? String ?? ""
        profile.bio = self.data["bio"] as? String ?? ""
        profile.image = self.data["image"] as? String ?? ""
        profile.avatar = self.data["avatar"] as? String ?? ""
        profile.bgColor = self.data["bgcolor"] as? String ?? ""
    }
    func fetchProfile() async {
        do {
            let document = try await ref.getDocument()
            let data = document.data()
            if data != nil {
                self.data = data!
                self.data["id"] = document.documentID
                self.populateProfile()
            }
        } catch {
                print(error.localizedDescription)
        }
    }
    
    func updateProfile() async {
        populateData()
        do {
            try await ref.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addProfile() async -> String {
        populateData()
        do {
            self.ref = try await db.collection("Profile").addDocument(data: self.data)
            self.data["id"] = ref.documentID
            try await self.ref.updateData(["id": ref.documentID])
            return ref.documentID
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    func removeProfile() {
        ref = db.collection("Profile").document(profile.id)
        ref.delete()
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
