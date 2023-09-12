//
//  TokenVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-24.
//

import SwiftUI

class TokenVM: ObservableObject {
    @Published var tokensList = [Tokens]()
    private var tokenManager = TokenManager()
    
    @MainActor
    func issueTokens(userId: String, amount: Int, reason: Tokens.TransType) async {
        // Construct token
        let newToken = Tokens(senderID: "treasury", receiverID: userId, amount: amount, transType: reason)

        // Deduct tokens from treasury and issue tokens to user
        do {
            try await tokenManager.issueTokenFromTreasury(token: newToken)
        } catch {
            print("Error issuing tokens:", error.localizedDescription)
        }
    }

    
    @MainActor
    func claimTokens(userId: String, claimAmount: Int) async {
        // Check if claimAmount is in multiples of 100
        guard claimAmount % 100 == 0 else {
            print("Claim amount must be in multiples of 100.")
            return
        }

        let tax = Int(Double(claimAmount) * 0.02)
        let netAmount = claimAmount - tax

        // ... Transfer netAmount to user's claimed balance, and deduct it from user's unclaimed balance ...
    }

    
    @MainActor
    func transactTokens(senderId: String, receiverId: String, amount: Int) async {
        // Transfer tokens from sender to receiver
        // ... Your business logic here ...
    }
    
    // Other business logic operations...
}
