//
//  UserModel.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-10.
//
// A class that handles user's data:
// 1. create the data
// 2. fetches the data
// 3. maybe onde delete the data


import SwiftUI
import Firebase
import FirebaseFirestoreSwift

// Firebase User data Manager. Should be called through UserVM only
// UserVM has to populate User before calling any of the functions
class UserManager: ObservableObject {
    @Published var user = User()
    private var db: Firestore
    // private var uid: String
    private var ref: DocumentReference?
    private var data: [String: Any] // dictionary
  
    
    init() {
        self.db = Firestore.firestore()
        self.data = [:] // to be populated
    }
    
    // I hope I won't need this. To be removed after inspecting the deisgn
//    init() {
//        // self.user = User()
//        self.db = Firestore.firestore()
//        self.data = [:] // to be populated
//        if let fbUser = Auth.auth().currentUser {
//            self.ref = self.db.collection("User").document(fbUser.uid)
//            self.user.id = fbUser.uid
//            self.user.email = fbUser.email!
////            Task {
////                await fetch()
////            }
//        } else {
//            self.ref = self.db.collection("User").document()
//        }
//    }

    func setRef() {
        if user.id.isEmpty {
            self.ref = self.db.collection("User").document()
            self.user.id = self.ref!.documentID
        } else {
            self.ref = self.db.collection("User").document(user.id)
        }
    }
    
    // in the future, I can make this smarter by passing updated fields only
    // but make sure you pass the full set if it's going to be used with 'create: setData'
    func populateData() {
        self.data = [
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "profileIds": user.profileIds,
            "InvitationCode": user.invitationCode,
        ]
    }
    
    func populateStruct() {
        user.id = self.data["id"] as? String ?? ""
        user.email = self.data["email"] as? String ?? ""
        user.name  = self.data["name"] as? String ?? ""
        user.profileIds =  self.data["profileIds"] as? [String] ?? []
        user.invitationCode =  self.data["invitationCode"] as? String ?? ""
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
    func create() async {
        setRef()
        populateData()
        do {
            try await ref!.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }

    @MainActor
    func currentUserData() async -> User {
        async let user = Auth.auth().currentUser
        self.user.id = await user!.uid
        self.user.email = await user!.email!
        await fetch()
        populateStruct()
        return self.user
    }
    
    @MainActor
    func remove() async {
        setRef()
        do {
            try await ref!.delete()
        } catch {
            fatalError("can't delete user")
        }
        // far from complete :(
    }
}
