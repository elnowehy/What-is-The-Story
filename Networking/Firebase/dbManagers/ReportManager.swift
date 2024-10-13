//
//  ReportManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-01-26.
//

import Foundation
import Firebase
// import FirebaseFireStoreSwift

class ReportManager: ObservableObject {
    @Published var report = Report()
    private var db: Firestore
    private var ref: DocumentReference?
    private var data: [String: Any]
    
    var coll: CollectionReference {
        db.collection("Reports")
    }
    
    init() {
        self.db = AppDelegate.db
        self.data = [:]
    }
    
    func setRef() throws {
        guard !report.id.isEmpty else {
            throw AppError.database(.invalidID)
        }
        
        self.ref = self.db.collection("Reports").document(report.id)
    }
    
    @MainActor
    func populateData() {
        
        let contentReference = self.db.collection(report.contentType.rawValue).document(report.contentId)
        self.data = [
            "id": report.id,
            "userId": report.userId,
            "contentId": report.contentId,
            "contentType": report.contentType.rawValue,
            "reason": report.reason.rawValue,
            "timestamp": report.timestamp,
            "reviewed": report.reviewed,
            "blocked": report.blocked,
            "reference": contentReference
        ]
    }
    
    @MainActor
    func populateStruct() async {
        var report = Report()
        report.id = data["id"] as? String ?? ""
        report.userId = data["userId"] as? String ?? ""
        report.contentId = data["contentId"] as? String ?? ""
        report.reviewed = data["reviewed"] as? Bool ?? false
        report.blocked = data["blocked"] as? Bool ?? false
        report.timestamp = data["timestamp"] as? Date ?? Date()
        
        if let contentTypeRawValue = data["contentType"] as? String, let contentType = ContentType(rawValue: contentTypeRawValue) {
            report.contentType = contentType
        } else {
            report.contentType = .episode
        }

        if let reasonRawValue = data["reason"] as? String, let reason = ReportReason(rawValue: reasonRawValue) {
            report.reason = reason
        } else {
            report.reason = .placeHolder
        }
    }
    
    @MainActor
    func add() async -> Result<Void, AppError> {
        do {
            try setRef()
            populateData()
            try await ref!.setData(self.data)
            return .success(())
        } catch let error as AppError {
            return .failure(error)
        } catch {
            return .failure(AppError.unknown(error.localizedDescription))
        }
    }
    
    @MainActor
    func fetch() async -> FetchResult {
        do {
            try setRef()
            let document = try await ref!.getDocument()
            if document.exists {
                let data = document.data()
                self.data = data!
                await self.populateStruct()
                return .success
            } else {
                // Set report to a default state indicating no existing report
                self.report = Report(
                    id: "",
                    userId: report.userId,
                    contentId: report.contentId,
                    contentType: report.contentType,
                    reason: .placeHolder,
                    timestamp: Date(),
                    reviewed: false,
                    blocked: false,
                    reference: ""
                )
                return .notFound
            }
        } catch let error as AppError {
            return .error(error)
        } catch {
            return .error(AppError.unknown(error.localizedDescription))
        }
    }

    
    func delete() async -> Result<Void, AppError> {
        do {
            try setRef()
            try await ref!.delete()
            return .success(())
        } catch let error as AppError {
            return .failure(error)
        } catch {
            return .failure(AppError.unknown(error.localizedDescription))
        }
    }
    
}
