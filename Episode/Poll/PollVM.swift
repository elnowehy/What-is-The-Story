//
//  PollVM.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import Foundation

class PollVM: ObservableObject {
    @Published var poll: Poll = Poll()
    @Published var answerVMs = [AnswerVM]()
    @Published var isLoading = false
    private var pollManager = PollManager()
    var userTokenValanceVM = UserTokenBalanceVM()
    var answerVM = AnswerVM()
    @Published var validationError: String = ""
    @Published var rewardTokenString: String = "" {
        didSet {
            poll.rewardTokens = Double(rewardTokenString) ?? 0.0
        }
    }
    
    var isOpen: Bool {
        poll.closingDate > Date()
    }
    
    func setUserTokenBalanceVM(_ vm: UserTokenBalanceVM) {
        userTokenValanceVM = vm
    }
    
    @MainActor
    func fetch() async {
        pollManager.poll.id = poll.id
        
        isLoading = true
        let result = await pollManager.fetch()
        switch result {
        case .success:
            self.poll = pollManager.poll
            await fetchAnswers()
        case .notFound:
            print("poll not found")
        case .error(let error):
            print(error.localizedDescription)
        }
        isLoading = false
    }
    
    func update() {
        if validateRewardTokens() {
            Task {
                pollManager.poll = poll
                await pollManager.add()
                userTokenValanceVM.userTokenBalance.unclaimed -= poll.rewardTokens
                userTokenValanceVM.userTokenBalance.reserved += poll.rewardTokens
                await userTokenValanceVM.update()
            }
        }
    }
    
    @MainActor
    func delete() async {
        pollManager.poll = poll
        await pollManager.delete()
    }
    
    func validateRewardTokens() -> Bool {
        guard !userTokenValanceVM.userTokenBalance.userId.isEmpty else {
            validationError = "Token balance data is unavailable."
            return false
        }
        
        if  poll.rewardTokens > userTokenValanceVM.userTokenBalance.unclaimed {
            validationError = "Insufficient unclaimed tokens for the reward"
            return false
        }
        
        validationError = ""
        return true
    }
    
    @MainActor
    func fetchAnswers() async {
        answerVMs.removeAll()
        for id in poll.answerIds {
            answerVM = AnswerVM()
            answerVM.answer.id = id
            await answerVM.fetch()
            
            // Fetch user's vote for this answer
            answerVM.voteVM.vote.answerId = id
            answerVM.voteVM.vote.id = answerVM.answer.userId
            let result = await answerVM.voteVM.fetch()
            
            switch result {
            case .success:
                answerVM.userHasVoted = true
            default:
                answerVM.userHasVoted = false
            }
            
            answerVMs.append(answerVM)
        }
    }
    
    @MainActor
    func addAnswer() async {
        await answerVM.update()
        poll.answerIds.append(answerVM.answer.id)
        update()
    }
    
    func deleteAnswer() async {
        self.poll.answerIds.removeAll(where: { $0 == answerVM.answer.id })
        await answerVM.delete()
        update()
        await fetchAnswers()
    }
}
