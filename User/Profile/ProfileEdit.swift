//
//  ProfileEdit.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-07.
//

import SwiftUI

struct ProfileEdit: View {
    var profileId: String
    @State var profile = Profile
    
    init(profileId: String) {
        self.profileId = profileId
        self.profile = Profile(id: profileId)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ProfileEdit_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEdit()
    }
}
