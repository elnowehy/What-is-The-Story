//
//  UserTokenDashboardView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-17.
//

import SwiftUI

struct UserTokenDashboardView: View {
    @EnvironmentObject var userVM: UserVM
    // @StateObject var gasBalanceVM = GasBalanceVM()
    @StateObject var userTokenBalanceVM = UserTokenBalanceVM()
    @State private var claimAmount: String = "0"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                UserTokenBalanceView()
                    .environmentObject(userVM)
                    .environmentObject(userTokenBalanceVM)
//
//                GasBalanceView()
//                    .environmentObject(userVM)
//                    .environmentObject(gasBalanceVM)

                HStack {
                    TextField("Enter amount to claim", text: $claimAmount)
                        .keyboardType(.decimalPad)
                        .onChange(of: claimAmount) { newValue in
                            enforceTokenLimit()
                        }
                    
                    Button("Max Amount") {
                        claimAmount = String(userTokenBalanceVM.userTokenBalance.unclaimed)
                    }
                    .disabled(claimAmount.isEmpty)
                }
                
                Button("Process the claim") {
                    Task {
                        await processClaim()
                    }
                }
            }
        }
        .onAppear {
            Task {
                userTokenBalanceVM.userTokenBalance.userId = userVM.user.id
                await userTokenBalanceVM.fetch()
                
//                gasBalanceVM.gasBalance.userId = userVM.user.id
//                await gasBalanceVM.fetch()
            }
        }
        .navigationTitle("Token Dashboard")
        .padding()
    }
    
    
    private func processClaim() async {
        guard let claimValue = Double(claimAmount) else {
            return
        }
        
        await userTokenBalanceVM.claim(amount: claimValue)
    }
    
    private func enforceTokenLimit() {
        if let amount = Double(claimAmount), amount > userTokenBalanceVM.userTokenBalance.unclaimed {
            claimAmount = String(userTokenBalanceVM.userTokenBalance.unclaimed)
        }
    }
}


#Preview {
    UserTokenDashboardView()
}
