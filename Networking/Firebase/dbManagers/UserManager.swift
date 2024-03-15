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


import Foundation
import Firebase
import FirebaseFirestoreSwift

// Firebase User data Manager. Should be called through UserVM only
// UserVM has to populate User before calling any of the functions
class UserManager {
    var user = User()
    private var db: Firestore
    // private var uid: String
    private var ref: DocumentReference?
  
    init() {
        self.db = AppDelegate.db
    }

    func setRef() {
        guard !user.id.isEmpty else {return}
        self.ref = self.db.collection("User").document(user.id)
    }

    @MainActor
    func fetch() async throws {
        setRef()
        guard let ref = self.ref else {
            throw AppError.authentication(.userNotFound)
        }
        do {
            let document = try await ref.getDocument()
            self.user = try document.data(as: User.self)
        } catch {
            throw AppError.database(.fetchFailed)
        }
    }


    @MainActor
    func update() async throws {
        setRef()
        guard let ref = self.ref else {
            throw AppError.authentication(.userNotFound)
        }
        do {
            try ref.setData(from: user, merge: true)
        } catch {
            throw AppError.database(.saveFailed)
        }
    }
    
    @MainActor
    func create() async throws {
        if user.id.isEmpty {
            let newRef = self.db.collection("User").document()
            user.id = newRef.documentID
            self.ref = newRef
        }
        do {
            try ref!.setData(from: user)
        } catch {
            throw AppError.database(.saveFailed)
        }
    }

    @MainActor
    func currentUserData() async throws -> User {
        guard let currentUser = Auth.auth().currentUser else {
            throw AppError.authentication(.noCurrentUser)
        }
        
        self.user.id = currentUser.uid
        self.user.email = currentUser.email ?? ""
        
        try await fetch()
        
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
