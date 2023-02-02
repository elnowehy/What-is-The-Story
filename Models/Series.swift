//
//  Series.swift
//  WITS
//
//  Created by Amr El-Nowehy on 2023-01-06.
//

import Foundation
import SwiftUI

struct Series {
    let sid: String   //series id
    let title: String
    let thumbnail: Image
    let description: String
    let episodes: [String]
    let creator: String
}
