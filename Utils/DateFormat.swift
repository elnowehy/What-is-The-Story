//
//  DateFormat.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-15.
//

import Foundation

func formattedTimestamp(for timestamp: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, MMM d yy"
    return dateFormatter.string(from: timestamp)
}
