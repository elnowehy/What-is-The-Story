//
//  AppSettings.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-16.
//

import Foundation

struct AppSettings {
    static let pageSize = 20
    static let commentMax = 140
    static let baseLink = "https://whatisthestory.tv"
    static let totalTokens: Int = 1_000_000_000
    
}

enum SeriesListType {
//      case featured
    case popular
    case new
    case trending
}

enum ContentType: String, CaseIterable, Codable {
    case episode = "Episode"
    case series = "Series"
    case profile = "Profile"
    case answer = "Answer"
    case comment = "Comment"
}

enum Mode {
    case update
    case add
    case view
}

enum ReportReason: String, CaseIterable, Codable {
    case placeHolder = "Select a Reason"
    case childAbuse = "Child Abuse"
    case explicitMaterial = "Explicit Material"
    case legalIssue = "Legal Issue"
}

enum FetchResult {
    case success
    case notFound
    case networkError(Error)
    case otherError(Error)
}
