//
//  SignOutView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-24.
//

import SwiftUI

struct SignOutView: View {
    @EnvironmentObject var userVM: UserVM
    
    var body: some View {
        Button(String(userVM.isLoggedIn)) {
            Task {
                await userVM.signOut()
            }
        }
    }
}

struct SignOutView_Previews: PreviewProvider {
    static var previews: some View {
        SignOutView()
    }
}
