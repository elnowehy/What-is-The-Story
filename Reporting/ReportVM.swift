//
//  ReportVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-01-24.
//

import Foundation
import SwiftUI

class ReportVM: ObservableObject {
    @Published var report = Report()
    @Published var isFlagged: Bool = false
    @Published var error: Error?
    private var reportManager = ReportManager()


    @MainActor
    func fetch() async {
        reportManager.report = report
        let result = await reportManager.fetch()

        switch result {
        case .success:
            report = reportManager.report
            isFlagged = true // Since a report was successfully fetched
        case .notFound:
            isFlagged = false // No report exists for this content and user
        default:
            self.error = error
        }
        
    }


    @MainActor
    func add() async {
        reportManager.report = report
        let result = await reportManager.add()
        
        switch result {
        case .success:
            isFlagged = true
        case .failure(let error):
            isFlagged = false
            self.error = error
        }
    }

    @MainActor
    func delete() async {
        reportManager.report = report
        let result = await reportManager.delete()
        
        switch result {
        case .success:
            isFlagged = false
        case .failure(let error):
            isFlagged = true
            self.error = error
        }
    }
}

