//
//  Flag.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-01-24.
//
// ** data model **

import Foundation

struct Report: Identifiable {
    var id: String = ""
    var userId: String = "" // ID of the user who raised the flag
    var contentId: String  = "" // ID of the content being flagged
    var contentType: ContentType = .episode // Type of the content (e.g., episode, comment, series)
    var reason: ReportReason = .placeHolder // Reason for flagging
    var timestamp: Date = Date() // Time when the flag was raised
    var reviewed: Bool = false // Whether the flag has been reviewed by an admin
    var blocked: Bool = false // Wether the content has been blocked by an admin
    var reference: String = "" // reference link to the content
}
