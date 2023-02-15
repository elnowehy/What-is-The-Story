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
        if user.uid.isEmpty {
            self.ref = self.db.collection("User").document()
        } else {
            self.ref = self.db.collection("User").document(user.uid)
        }
        self.data = [:] // to be populated
    }
    
    
    init() {
        self.user = User()
        self.db = Firestore.firestore()
        self.data = [:] // to be populated
        let fbUser = Auth.auth().currentUser
        self.ref = self.db.collection("User").document(fbUser!.uid)
        self.user.uid = fbUser!.uid
        self.user.email = fbUser!.email!
        Task {
            await fetchUser()
        }
    }

    
    func populateData() {
        self.data = [
            "id": user.email,
            "name": user.name,
            "sponsor": user.sponsor,
            "tokens": user.tokens,
            "profileId": user.profileId
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
                self.user.sponsor = data!["sponsor"] as? String ?? ""
                self.user.tokens = data!["tokens"] as? Int ?? 0
                self.user.profileId =  data!["profileId"] as? String ?? ""
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
        self.user.uid = await user!.uid
        self.user.email = await user!.email!
        await fetchUser()
        return self.user
        
    }
    
    func removeUser() {
        ref = db.collection("User").document(user.uid)
        ref.delete()
    }
}
