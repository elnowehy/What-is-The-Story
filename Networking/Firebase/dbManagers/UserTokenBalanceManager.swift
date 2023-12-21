//
//  UserTokenBalanceManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-12-17.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFunctions


class UserTokenBalanceManager {
    private var db: Firestore
    private var functions: Functions
    
    init() {
        self.db = AppDelegate.db
        self.functions = Functions.functions()
    }
    
    @MainActor
    func fetch(userId: String) async throws -> UserTokenBlance {
        // Fetch gas balance data from Firestore
        let document = try await db.collection("Tokens_Balance").document(userId).getDocument()
        let pendingDoc = try await db.collection("Tokens/Treasury/PendingTokens").document(userId).getDocument()
        if let documentData = document.data() {
            var pending = 0.0
            if let pendingDocData = pendingDoc.data() {
                pending = pendingDocData["pending"] as? Double ?? 0
            }
            let unclaimed = documentData["unclaimed"] as? Double ?? 0
            let reserved = documentData["reserved"] as? Double ?? 0
            let claimed = documentData["claimed"] as? Double ?? 0
            
            return UserTokenBlance(
                userId: userId,
                pending: pending,
                unclaimed: unclaimed,
                reserved: reserved,
                claimed: claimed)
        } else {
            // Handle the case where there's no data
            return UserTokenBlance(userId: userId)
        }
    }
    
    @MainActor
    func claim(userId: String, amount: Double) async throws {
        let data: [String: Any] = [
            "userId": userId,
            "amount": amount
        ]
        
        do {
            let result = try await functions.httpsCallable("handleTokenClaims").call(data)
            if let resultData = result.data as? [String: Any],
               let error = resultData["error"] as? String {
                throw NSError(domain: "FirebaseFunction", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
            }
        } catch let error as NSError {
            if let errorMessage = error.userInfo[FunctionsErrorDetailsKey] as? String {
                throw NSError(domain: error.domain, code: error.code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            } else {
                throw error
            }
        }
    }
}
