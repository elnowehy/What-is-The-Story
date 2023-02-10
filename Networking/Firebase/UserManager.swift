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

class UserManager:ObservableObject {
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

    
    func populateData() {
        self.data = [
            "id": user.email,
            "name": user.name,
            "sponsor": user.sponsor,
            "tokens": user.tokens,
            "profile": user.profileId
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
    func currentUserData() async {
        do {
            let user = try await Auth.auth().currentUser
            self.user.uid = user!.uid
            self.user.email = user!.email!
            Task {
                await fetchUser()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeUser() {
        ref = db.collection("User").document(user.uid)
        ref.delete()
    }
}

/*

 

     func fetchUser() async {
         do {
             try await db.collection("User").whereField("email", isEqualTo: self.user.email).getDocuments()
         } catch {
             print("Error getting documents: \(err)")
         }
         
         { (querySnapshot, err) in
             if let err = err {
                 print("Error getting documents: \(err)")
             } else if querySnapshot != nil {
                 for document in querySnapshot!.documents {
                     let data = document.data()
                     self.user.email = data["email"] as? String ?? ""
                     self.user.name  = data["name"] as? String ?? ""
                     self.user.sponsor = data["sponsor"] as? String ?? ""
                     self.user.tokens = data["tokens"] as? Int ?? 0
                     self.isLoading = false
                 }
             } else {
                 print("Really!!")
             }
         }
          
     }

        func fetchUser() {
      //   DispatchQueue.main.async {
             @FirestoreQuery(
                 collectionPath: "User",
                 predicates: [.whereField("email", isEqualTo: self.user.email)]
             ) var dataResult: Result<[User], Error>
             
             if case let .success(dataResult) = dataResult {
                 if dataResult.count > 0 {
                     self.user.name = dataResult[0].name
                     self.user.sponsor = dataResult[0].sponsor
                     self.user.tokens = dataResult[0].tokens
                     self.isLoading = false
                 } else {
                     self.isLoading = true
                 }
             } else if case let .failure(failure) = dataResult {
                 print(failure.localizedDescription)
             }
       //  }
     }


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
