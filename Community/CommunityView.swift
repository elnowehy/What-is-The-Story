//
//  CommunityView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        Text("Hello, Community!")
            .modifier(LargeTitleStyle())
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
