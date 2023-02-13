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
    @Published var profile: Profile
    @Published var isLoading = true
    private var db: Firestore
    private var ref: DocumentReference
    private var data: [String: Any] // dictionary
    
    init(profile: Profile) {
        self.db = Firestore.firestore()
        self.profile = profile
        self.data = [
            "id": profile.id,
            "name": profile.name,
            "title": profile.title,
            "bio": profile.bio,
            "bgcolor": profile.bgColor,
            "image": profile.image,
            "thumbnail": profile.thumbnail,
            "serieseIds": profile.serieseIds,
            "videoIds": profile.videoIds,
            "ideaIds": profile.ideaIds,
            "voteIds": profile.voteIds,
            "commentIds": profile.commentIds,
            "likeIds": profile.likeIds,
            "viewIds": profile.viewIds
            ]
        
        if profile.id.isEmpty {
            self.ref = self.db.collection("Profile").document()
        } else {
            self.ref = self.db.collection("Profile").document(profile.id) // will return a Document reference for a unsaved one
        }
    }
    
    @MainActor
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

    func populateProfile() {
        self.profile.id = self.data["id"] as? String ?? ""
        self.profile.name = self.data["name"] as? String ?? ""
        self.profile.title = self.data["title"] as? String ?? ""
        self.profile.bio = self.data["bio"] as? String ?? ""
        self.profile.bgColor = self.data["bgcolor"] as? String ?? ""
        self.profile.image = self.data["image"] as? String ?? ""
        self.profile.thumbnail = self.data["thumbnail"] as? String ?? ""
        self.profile.serieseIds = self.data["serieseIds"] as? [String] ?? []
        self.profile.videoIds = self.data["videoIds"] as? [String] ?? []
        self.profile.ideaIds = self.data["ideaIds"] as? [String] ?? []
        self.profile.voteIds = self.data["voteIds"] as? [String] ?? []
        self.profile.commentIds = self.data["commentIds"] as? [String] ?? []
        self.profile.likeIds = self.data["likeIds"] as? [String] ?? []
        self.profile.viewIds = self.data["viewIds"] as? [String] ?? []
    }
  
    @MainActor
    func updateProfile() async {
        do {
            try await ref.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func addProfile() async -> String {
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
