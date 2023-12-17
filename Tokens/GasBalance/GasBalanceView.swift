//
//  GasBalanceView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-15.
//

import SwiftUI

struct GasBalanceView: View {
    @StateObject var gasBalanceVM = GasBalanceVM()
    @EnvironmentObject var userVM: UserVM

    var body: some View {
        VStack {
            if gasBalanceVM.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = gasBalanceVM.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                VStack(spacing: 10) {
                    Text("Gas Balance")
                        .font(.headline)

                    Text("\(gasBalanceVM.gasBalance.gasBalance, specifier: "%.8f") MATIC")
                        .font(.title)
                    
                    // Optionally, show more details like reference block
                    // Text("Reference Block: \(viewModel.gasBalance.referenceBlock)")

                    Button(action: {
                        Task {
                            gasBalanceVM.gasBalance.userWallet = userVM.user.wallet
                            await gasBalanceVM.refresh()
                        }
                    }) {
                        Text("Refresh Balance")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            Task {
                gasBalanceVM.gasBalance.userId = userVM.user.id
                await gasBalanceVM.fetch()
            }
        }
        .padding()
        .navigationTitle("Your Gas Wallet")
    }
}

struct GasBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        GasBalanceView()
    }
}
