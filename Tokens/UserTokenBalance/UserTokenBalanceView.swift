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

    // Optional state variables for previous balance values
    @State private var previousPending: Double?
    @State private var previousUnclaimed: Double?
    @State private var previousReserved: Double?
    @State private var previousClaimed: Double?
    @State private var previousGas: Double?

    var body: some View {
        VStack {
            if userTokenBalanceVM.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = userTokenBalanceVM.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Token Balance for \(userVM.user.name)")
                balanceText(title: "Pending", value: userTokenBalanceVM.userTokenBalance.pending, previousValue: $previousPending)
                balanceText(title: "Unclaimed", value: userTokenBalanceVM.userTokenBalance.unclaimed, previousValue: $previousUnclaimed)
                balanceText(title: "Reserved", value: userTokenBalanceVM.userTokenBalance.reserved, previousValue: $previousReserved)
                balanceText(title: "Claimed", value: userTokenBalanceVM.userTokenBalance.claimed, previousValue: $previousClaimed)
                balanceText(title: "Gas Balance", value: userTokenBalanceVM.userTokenBalance.gas, previousValue: $previousGas)
            }
            
            Button(action: refreshBalances) {
                Text("Refresh Balance")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }

    private func refreshBalances() {
        Task {
            userTokenBalanceVM.userTokenBalance.wallet = userVM.user.wallet
            await userTokenBalanceVM.refresh()
        }
    }

    private func balanceText(title: String, value: Double, previousValue: Binding<Double?>) -> some View {
        var color: Color = .black

        // Apply color only if previous value was set
        if let previous = previousValue.wrappedValue {
            color = value > previous ? .green : (value < previous ? .red : .black)
        }

        previousValue.wrappedValue = value
        return Text("\(title): \(value)")
            .foregroundColor(color)
    }
}



#Preview {
    UserTokenBalanceView()
}
