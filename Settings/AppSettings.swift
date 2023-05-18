//
//  AppSettings.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-16.
//

import Foundation

struct AppSettings {
    static let pageSize = 20
    
    enum SeriesListType {
        case featured
        case popular
        case new
        case trending
    }
}
