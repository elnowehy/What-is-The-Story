//
//  AnswerVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import Foundation

class AnswerVM: ObservableObject {
    @Published var answer = Answer()
    @Published var isLoading = false
    @Published var userHasVoted = false
    private var answerManager = AnswerManager()
    var voteVM = VoteVM()
    
    @MainActor
    func fetch() async {
        answerManager.answer.id = answer.id
        
        isLoading = true
        let result = await answerManager.fetch()
        switch result {
        case .success:
            self.answer = answerManager.answer
        case .notFound:
            print("Answer not found")
        case .error(let error):
            print(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func add() async {
        answerManager.answer = answer
        await answerManager.update()
    }
    
    @MainActor
    func update() async {
        answerManager.answer = answer
        voteVM.vote.answerId = answer.id
        voteVM.vote.id = answer.userId
        let result = await voteVM.fetch()
        
        switch result {
        case .notFound:
            await voteVM.add()
        case .success:
            await voteVM.delete()
        case .error(let error):
            print(error.localizedDescription)
        }
        await answerManager.update()
    }
    
    @MainActor
    func delete() async {
        answerManager.answer = answer
        await answerManager.delete()
    }
    
    @MainActor
    func voteCount() async -> Int {
        answerManager.answer = answer
        do {
            return try await answerManager.voteCount()
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
}
