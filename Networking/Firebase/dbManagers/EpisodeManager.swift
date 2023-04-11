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
    
    
    init() {
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
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
            "title": self.episode.title,
            "synopsis": self.episode.synopsis,
            "question": self.episode.question,
            "votingOpen": self.episode.votingOpen,
            "pollClosingDate": self.episode.pollClosingDate,
            "series": self.episode.series,
            "view": self.episode.views,
        ]
        
        if updateVideo {
            self.data["video"] = await storeVideo(ref: videoRef!, data: self.videoData).absoluteString
        }
    }
    
    
    func populateStruct() {
        episode.id = self.data["id"] as? String ?? ""
        episode.title = self.data["title"] as? String ?? ""
        episode.synopsis = self.data["synopsis"] as? String ?? ""
        episode.question = self.data["question"] as? String ?? ""
        episode.votingOpen = self.data["votingOpen"] as? Bool ?? false
        episode.pollClosingDate = self.data["pollClosingDate"] as? Date ?? Date()
        episode.series = self.data["series"] as? String ?? ""
        episode.views = self.data["views"] as? Int ?? 0
        episode.video = URL(string: self.data["video"] as? String ?? "")!
    }
    
    @MainActor
    func fetch(id: String) async {
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

