//
//  TokenManager.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class TokenManager {
    private let db = AppDelegate.db
    private let tokensRef = AppDelegate.db.collection("Tokens")
    private let platform = AppDelegate.db.collection("Platform").document("treasury")
    
    func addToken(token: Tokens) async throws -> Tokens {
        do {
            var newToken = token
            let newDoc = try await tokensRef.addDocument(from: newToken)
            newToken.id = newDoc.documentID
            return newToken
        } catch {
            print("Error adding token document: \(error)")
            throw error
        }
    }

    func fetchUserTokens(userId: String) async throws -> [Tokens] {
        var tokens = [Tokens]()
        let userTokensSnapshot = try await tokensRef.whereField("senderID", isEqualTo: userId).getDocuments()

        for document in userTokensSnapshot.documents {
            if let token = try? document.data(as: Tokens.self) {
                tokens.append(token)
            }
        }

        return tokens
    }

    func issueTokenFromTreasury(token: Tokens) async throws {
        do {
            // Start a Firestore transaction
            try await db.runTransaction { transaction, errorPointer in
                // Get the treasury document
                let snapshot = try transaction.getDocument(self.platform)
                guard var treasuryData = snapshot.data() else {
                    errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve treasury data"
                    ])
                    return
                }
                
                // Deduct the token amount from the treasury
                guard let currentBalance = treasuryData["balance"] as? Int, currentBalance >= token.amount else {
                    errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Insufficient balance in treasury"
                    ])
                    return
                }
                
                treasuryData["balance"] = currentBalance - token.amount
                
                // Update the treasury document
                transaction.setData(treasuryData, forDocument: self.platform)
                
                // Issue the tokens (add a new document in Tokens collection)
                let _ = try transaction.setData(from: token, forDocument: self.tokensRef.document())
            }
        } catch {
            print("Transaction failed: \(error.localizedDescription)")
            throw error
        }
    }


    // Other Firestore operations...
}
