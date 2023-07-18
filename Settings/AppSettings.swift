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
    
    enum SeriesListType {
  //      case featured
        case popular
        case new
        case trending
    }
}

enum ContentType: String, CaseIterable, Codable {
    case episode
    case series
    case profile
}

enum Mode {
    case update
    case add
    case view
}

enum FetchResult {
    case success
    case notFound
    case networkError(Error)
    case otherError(Error)
}
