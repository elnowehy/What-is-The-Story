//
//  GasBalanceVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-04.
//
import SwiftUI

class GasBalanceVM: ObservableObject {
    @Published var gasBalance = GasBalance()
    // @Published var transactions: [Transaction] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private var gasBalanceManager = GasBalanceManager()

    @MainActor
    func fetch() async {
        do {
            isLoading = true
            gasBalance = try await gasBalanceManager.fetch(userId: gasBalance.userId)
            isLoading = false
        } catch {
            print("Error fetching gas balance: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func refresh() async {
        do {
            try await gasBalanceManager.refresh(userId: gasBalance.userId, wallet: gasBalance.userWallet)
            await fetch()
            isLoading = false
        } catch {
            print("Error fetching gas balance: \(error)")
            errorMessage = error.localizedDescription
        }
    }
}

