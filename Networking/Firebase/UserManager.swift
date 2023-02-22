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

class UserManager: ObservableObject {
    @Published var user: User
    @Published var isLoading = true
    private var db: Firestore
    // private var uid: String
    private var ref: DocumentReference
    private var data: [String: Any] // dictionary
  
    
    init(user: User) {
        self.user = user
        self.db = Firestore.firestore()
        if user.id.isEmpty {
            self.ref = self.db.collection("User").document()
        } else {
            self.ref = self.db.collection("User").document(user.id)
        }
        self.data = [:] // to be populated
    }
    
    
    init() {
        self.user = User()
        self.db = Firestore.firestore()
        self.data = [:] // to be populated
        let fbUser = Auth.auth().currentUser
        self.ref = self.db.collection("User").document(fbUser!.uid)
        self.user.id = fbUser!.uid
        self.user.email = fbUser!.email!
        Task {
            await fetchUser()
        }
    }

    
    func populateData() {
        self.data = [
            "id": user.email,
            "name": user.name,
            "profileIds": user.profileIds,
            "InvitationCode": user.invitationCode,
        ]
    }
    
    @MainActor
    func fetchUser() async {
        do {
            let document = try await ref.getDocument()
            let data = document.data()
            if data != nil {
                self.user.email = data!["email"] as? String ?? ""
                self.user.name  = data!["name"] as? String ?? ""
                self.user.profileIds =  data!["profileId"] as? [String] ?? []
                self.user.invitationCode =  data!["invitationCode"] as? String ?? ""
                
                self.isLoading = false
                self.populateData()  // why? Just in case
                
                
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    @MainActor
    func setUser() async {
        self.populateData()
        do {
            try await ref.setData(self.data)
        } catch {
            print(error.localizedDescription)
        }
    }

    @MainActor
    func currentUserData() async -> User {
        async let user = Auth.auth().currentUser
        self.user.id = await user!.uid
        self.user.email = await user!.email!
        await fetchUser()
        return self.user
        
    }
    
    func removeUser() {
        ref = db.collection("User").document(user.id)
        ref.delete()
    }
}
