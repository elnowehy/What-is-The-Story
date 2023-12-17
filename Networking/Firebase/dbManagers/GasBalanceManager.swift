//
//  GasBalanceManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-04.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFunctions

class GasBalanceManager {
    private var db: Firestore
    private var functions: Functions

    init() {
        self.db = AppDelegate.db
        self.functions = Functions.functions()
        // functions.useEmulator(withHost:"localhost", port:5001)
    }

    @MainActor
    func fetch(userId: String) async throws -> GasBalance {
        // Fetch gas balance data from Firestore
          let document = try await db.collection("Tokens_Balance").document(userId).getDocument()
          if let documentData = document.data() {
              let gasBalance = documentData["userGasBalance"] as? Double ?? 0
              let referenceBlock = documentData["lastProcessedBlockNumber"] as? Int ?? 0
              // let transactions = transactionsData.map { Transaction(dictionary: $0) }
              
              return GasBalance(userId: userId, gasBalance: gasBalance, referenceBlock: referenceBlock)
          } else {
              // Handle the case where there's no data
              return GasBalance(userId: userId, gasBalance: 0.0, referenceBlock: 0)
          }
      }
    
    @MainActor
    func refresh(userId: String, wallet: String) async throws -> Void {
        let data: [String: Any] = [
            "userId": userId,
            "userWalletAddress": wallet
        ]
        
        do {
            _ = try await functions.httpsCallable("checkAndUpdateUserGasBalance").call(data)
        } catch {
            throw error
        }
    }
}
