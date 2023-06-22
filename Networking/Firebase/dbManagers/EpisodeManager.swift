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



class EpisodeManager: ObservableObject {
    @Published var episode = Episode()
    public var videoData = Data()
    public var updateVideo = false
    private var db: Firestore
    private var ref: DocumentReference?
    private var storage: Storage
    private var videoRef: StorageReference?
    private var data: [String: Any]
    private var lastDocument: DocumentSnapshot?
    
    
    init() {
        self.db = AppDelegate.db
        self.storage = AppDelegate.storage
        self.data = [:]
    }
        
    func setRef() {
        if episode.id.isEmpty {
            self.ref = self.db.collection("Episode").document()
            if let episodeId = self.ref?.documentID {
                episode.id = episodeId
            }
        }
        
        self.ref = self.db.collection("Episode").document(episode.id)
        self.videoRef = self.storage.reference().child("videos").child("\(episode.id).mp4")
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.episode.id,
            "userId": self.episode.userId,
            "title": self.episode.title,
            "synopsis": self.episode.synopsis,
            "question": self.episode.question,
            "votingOpen": self.episode.votingOpen,
            "pollClosingDate": self.episode.pollClosingDate,
            "series": self.episode.series,
            "view": self.episode.views,
            "numOfRatings": self.episode.numOfRatings,
            "totalRatings": self.episode.totalRatings,
            "avgRating": self.episode.avgRating,
            "releaseDate": self.episode.releaseDate,
            "featuredScore": self.episode.featuredScore
        ]
        
        if updateVideo {
            self.data["video"] = await storeVideo(ref: videoRef!, data: self.videoData).absoluteString
        }
    }
    
    
    func populateStruct() {
        episode.id = self.data["id"] as? String ?? ""
        episode.userId = self.data["userId"] as? String ?? ""
        episode.title = self.data["title"] as? String ?? ""
        episode.synopsis = self.data["synopsis"] as? String ?? ""
        episode.question = self.data["question"] as? String ?? ""
        episode.votingOpen = self.data["votingOpen"] as? Bool ?? false
        episode.pollClosingDate = self.data["pollClosingDate"] as? Date ?? Date()
        episode.series = self.data["series"] as? String ?? ""
        episode.views = self.data["views"] as? Int ?? 0
        episode.numOfRatings = self.data["numOfRatings"] as? Int ?? 0
        episode.totalRatings = self.data["totalRatings"] as? Int ?? 0
        episode.avgRating = self.data["avgRating"] as? Double ?? 0.0
        if let timestamp = self.data["releaseDate"] as? Timestamp {
            episode.releaseDate = timestamp.dateValue()
        }
        episode.video = URL(string: self.data["video"] as? String ?? "") ?? URL(filePath: "")
    }
    
    @MainActor
    func fetch(id: String) async -> Episode {
        episode.id = id
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
        
        return episode
    }
    
//    @MainActor
//    func fetchByQuery(field: String, prefix: String, pageSize: Int) async -> [Episode] {
//        var episodeList = [Episode]()
//        let endValue = prefix + "\u{f8ff}"
//        var query = db.collection("Episode")
//            .whereField(field, isGreaterThan: prefix)
//            .whereField(field, isLessThan: endValue)
//            .limit(to: pageSize)
//        
//        if let lastDocument = lastDocument {
//            query = query.start(afterDocument: lastDocument)
//        }
//        
//        do {
//            let documents = try await query.getDocuments()
//            for document in documents.documents {
//                let data = document.data()
//                if !data.isEmpty {
//                    self.data = data
//                    self.populateStruct()
//                    episodeList.append(self.episode)
//                }
//            }
//            
//            lastDocument = documents.documents.last
//            
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        return episodeList
//    }
    
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
            return episode.id
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

