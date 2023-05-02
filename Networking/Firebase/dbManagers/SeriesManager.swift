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
    public var trailerData = Data()
    public var updateTrailer = false
    private var db: Firestore
    private var ref: DocumentReference?
    private var storage: Storage
    private var posterRef: StorageReference?
    private var trailerRef: StorageReference?
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
        self.posterRef = self.storage.reference().child("posters").child("\(series.id).jpeg")
        self.trailerRef = self.storage.reference().child("trailers").child("\(series.id).mp4")
    }

    @MainActor
    func populateData() async {
        self.data = [
            "id": self.series.id,
            "profile": self.series.profile,
            "title": self.series.title,
            "categories": Array(self.series.categories),
            "synopsis": self.series.synopsis,
        ]
        if updatePoster {
            self.data["poster"] = await storeImage(ref: posterRef!, uiImage: posterImage, quality: series.imgQlty).absoluteString
        }
        
        if updateTrailer {
            self.data["trailer"] = await storeVideo(ref: trailerRef!, data: self.trailerData).absoluteString
        }
    }
    
    
    func populateStruct() {
        series.id = self.data["id"] as? String ?? ""
        series.profile = self.data["profile"] as? String ?? ""
        series.title = self.data["title"] as? String ?? ""
        series.categories = Set(self.data["categories"] as? [String] ?? [])
        series.synopsis = self.data["synopsis"] as? String ?? ""
        series.poster = URL(string: self.data["poster"] as? String ?? "") ?? URL(filePath: "")
        series.trailer = URL(string: self.data["trailer"] as? String ?? "") ?? URL(filePath: "")
        series.episodes = self.data["episodes"] as? [String] ?? []
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
    
    @MainActor
    func addEpisode(episodeId: String) async -> Void {
        setRef()
        do {
            try await ref!.updateData(["episodes": FieldValue.arrayUnion([episodeId])])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func removeEpisode(episodeId: String) async -> Void {
        setRef()
        do {
            try await ref!.updateData(["episodes": FieldValue.arrayRemove([episodeId])])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchAllSeries(for listType: LandingPageVM.SeriesListType, category: Category? = nil, page: Int, pageSize: Int) async throws -> [Series] {
        var fetchedSeries: [Series] = []
        var query: Query
        
        switch listType {
        case .featured:
            query = db.collection("Series").whereField("featured", isEqualTo: true)
        case .popular:
            query = db.collection("Series").order(by: "totalRatings", descending: true)
        case .new:
            query = db.collection("Series").order(by: "releaseDate", descending: true)
        case .trending:
            query = db.collection("Series").order(by: "viewsIncrease", descending: true)
        }
        
        if let category = category {
            query = query.whereField("categories", arrayContains: category)
        }
        
        // Add pagination
        query = query.start(at: [page * pageSize]).limit(to: pageSize)
        
        let querySnapshot = try await query.getDocuments()
        
        await withTaskGroup(of: Series.self) { group in
            for document in querySnapshot.documents {
                group.addTask {
                    let seriesId = document.documentID
                    let seriesManager = SeriesManager()
                    await seriesManager.fetch(id: seriesId)
                    return seriesManager.series
                }
            }
            
            for await result in group {
                fetchedSeries.append(result)
            }
        }
        
        return fetchedSeries
    }
}

