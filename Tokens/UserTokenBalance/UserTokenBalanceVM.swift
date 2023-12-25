//
//  UserTokenBalanceVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-17.
//

import SwiftUI

class UserTokenBalanceVM: ObservableObject {
    @Published var userTokenBalance = UserTokenBlance()
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private var userTokenBalanceManager = UserTokenBalanceManager()
    
    @MainActor
    func fetch() async {
        do {
            isLoading = true
            userTokenBalance = try await userTokenBalanceManager.fetch(userId: userTokenBalance.userId)
            isLoading = false
        } catch {
            print("Error fetching user balance: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func claim(amount: Double) async {
        guard amount <= userTokenBalance.unclaimed else {
            errorMessage = "Claim amount exceeds unclaimed tokens"
            return
        }
        
        do {
            isLoading = true
            _ = try await userTokenBalanceManager.claim(userId: userTokenBalance.userId, amount: amount)
            
            userTokenBalance.unclaimed -= amount
            userTokenBalance.claimed += amount
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
