//
//  NavigationManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2024-01-06.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var selectedEpisodeID: String? = nil
    @Published var invitationCode: String? = nil
}

