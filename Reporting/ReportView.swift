//
//  ReportView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-01-24.
//

import SwiftUI

struct ReportView: View {
    @StateObject var reportVM: ReportVM
    @EnvironmentObject var errorHandlingVM: ErrorHandlingVM

    var body: some View {
        VStack {
            // Flag button
            Button(action: toggleReportMenu) {
                Image(systemName: reportVM.isFlagged ? "flag.fill" : "flag")
            }

            // Dropdown for reasons
            if reportVM.isFlagged {
                Picker("Select a Reason", selection: $reportVM.report.reason) {
                    Text("Select a reason").tag(ReportReason.placeHolder) // Directly tag with the enum value
                    ForEach(ReportReason.allCases.filter { $0 != .placeHolder }, id: \.self) { reason in
                        Text(reason.rawValue).tag(reason) // Ensure the tag is the enum itself, not casted
                    }
                }
            }

            // Save Report button
            Button("Save Report") {
                Task {
                    await reportVM.add()
                }
            }
            .disabled(reportVM.report.reason == .placeHolder)
        }
        .task {
            reportVM.report.id = "\(reportVM.report.contentId)_\(reportVM.report.userId)"
            await reportVM.fetch()
        }
        .onReceive(reportVM.$error) { error in
            if let error = error {
                errorHandlingVM.handleError(error)
                reportVM.error = nil  // Reset the error to prevent repeated handling
            }
        }
    }

    private func toggleReportMenu() {
        Task {
            reportVM.isFlagged.toggle()
            if !reportVM.isFlagged {
                await reportVM.delete()
            }
        }
    }
}
