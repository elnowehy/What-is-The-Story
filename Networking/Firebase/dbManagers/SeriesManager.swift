//
//  SeriesManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-27.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage



class SeriesManager: ObservableObject {
    @Published var series = Series()
    public var posterImage = UIImage()
    public var updatePoster = false
    public var updateTrailer = false
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
        if series.id.isEmpty {
            // create a referece to populate Profile.seriesIds during creation
            self.ref = self.db.collection("Series").document()
            if let seriesId = self.ref?.documentID {
                series.id = seriesId
            }
        }
        
        self.ref = self.db.collection("Series").document(series.id)
        self.storageRef = self.storage.reference().child("posters").child("\(series.id).jpeg")
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.series.id,
            "profile": self.series.profile,
            "title": self.series.title,
            "genre": self.series.genre,
            "synopsis": self.series.synopsis,
            "episodes": self.series.episodes,
        ]
        if updatePoster {
            self.data["poster"] = await storeImage(ref: storageRef!, uiImage: posterImage, quality: series.imgQlty).absoluteString
        }
    }
    
    
    func populateStruct() {
        series.id = self.data["id"] as? String ?? ""
        series.profile = self.data["profile"] as? String ?? ""
        series.title = self.data["title"] as? String ?? ""
        series.genre = self.data["genre"] as? String ?? ""
        series.synopsis = self.data["synopsis"] as? String ?? ""
        series.poster = URL(string: self.data["poster"] as? String ?? "")!
 //       series.trailer = URL(string: self.data["trailer"] as? String ?? "")!
    }
    
    @MainActor
    func fetch(id: String) async {
        series.id = id
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
            try await ref!.updateData(self.data)
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
            return series.id
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

