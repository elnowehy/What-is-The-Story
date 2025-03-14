//
//  VoteVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import Foundation

class VoteVM: ObservableObject {
    @Published var vote: Vote = Vote()
    @Published var isLoading = false
    @Published var error: Error?
    private var voteManager = VoteManager()
    
    @MainActor
    func fetch() async -> FetchResult {
        voteManager.vote = vote
        
        isLoading = true
        let result = await voteManager.fetch()
        switch result {
        case .success:
            self.vote = voteManager.vote
        case .notFound:
            self.error = AppError.database(.dataNotFound)
        default:
            self.error = error
        }
        
        isLoading = false
        return result
    }
    
    @MainActor
    func add() async {
        voteManager.vote = vote
        await voteManager.add()
    }
    
    @MainActor
    func delete() async {
        voteManager.vote = vote
        await voteManager.delete()
    }
}
