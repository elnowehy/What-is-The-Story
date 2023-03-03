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

@MainActor
class UserManager: ObservableObject {
    @Injected var user: User
    @Published var isLoading = true
    private var db: Firestore
    // private var uid: String
    private var ref: DocumentReference
    private var data: [String: Any] // dictionary
  
    
    init(user: User) {
        //self.user = user
        self.db = Firestore.firestore()
        if user.id.isEmpty {
            self.ref = self.db.collection("User").document()
        } else {
            self.ref = self.db.collection("User").document(user.id)
        }
        self.data = [:] // to be populated
    }
    
    
    init() {
        // self.user = User()
        self.db = Firestore.firestore()
        self.data = [:] // to be populated
        let fbUser = Auth.auth().currentUser
        self.ref = self.db.collection("User").document(fbUser!.uid)
        self.user.id = fbUser!.uid
        self.user.email = fbUser!.email!
        Task {
            await fetch()
        }
    }

    // in the future, I can make this smarter by passing updated fields only
    // but make sure you pass the full set if it's going to be used with 'create: setData'
    func populateData() {
        self.data = [
            "id": user.email,
            "name": user.name,
            "profileIds": user.profileIds,
            "InvitationCode": user.invitationCode,
        ]
    }
    
    func populateStruct() {
        user.email = self.data["email"] as? String ?? ""
        user.name  = self.data["name"] as? String ?? ""
        user.profileIds =  self.data["profileId"] as? [String] ?? []
        user.invitationCode =  self.data["invitationCode"] as? String ?? ""
    }

    func fetch() async {
        do {
            let document = try await ref.getDocument()
            let data = document.data()
            if data != nil {
                self.data = data!
                self.populateStruct()
                self.isLoading = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func update() async {
        populateData()
        do {
            try await ref.updateData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func create() async {
        populateData()
        do {
            try await ref.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }

    func currentUserData() async -> User {
        async let user = Auth.auth().currentUser
        self.user.id = await user!.uid
        self.user.email = await user!.email!
        await fetch()
        return self.user
        
    }
    
    func remove() async {
        do {
            try await ref.delete()
        } catch {
            fatalError("can't delete user")
        }
        // far from complete :(
    }
}
