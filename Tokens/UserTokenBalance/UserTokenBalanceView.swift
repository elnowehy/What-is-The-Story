//
//  UserTokenBalanceView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-17.
//

import SwiftUI

struct UserTokenBalanceView: View {
    @EnvironmentObject var userTokenBalanceVM: UserTokenBalanceVM
    @EnvironmentObject var userVM: UserVM
    
    var body: some View {
        VStack {
            if userTokenBalanceVM.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = userTokenBalanceVM.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Token Balance for \(userVM.user.name)")
                Text("Pending: \(userTokenBalanceVM.userTokenBalance.pending)")
                Text("Unclaimed: \(userTokenBalanceVM.userTokenBalance.unclaimed)")
                Text("Reserved: \(userTokenBalanceVM.userTokenBalance.reserved)")
                Text("Claimed: \(userTokenBalanceVM.userTokenBalance.claimed)")
            }
        }
    }
}


#Preview {
    UserTokenBalanceView()
}
