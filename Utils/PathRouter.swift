//
//  PathRouter.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-03.
//

import SwiftUI

class PathRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func rest() {
        path = NavigationPath()
    }
    
}
