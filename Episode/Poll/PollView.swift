//
//  PollView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import SwiftUI

struct PollView: View {
    @ObservedObject var pollVM: PollVM
    @EnvironmentObject var userVM: UserVM
    @EnvironmentObject var auth: AuthManager
    @State private var newAnswer: String = ""

    var body: some View {
        VStack {
             Text(pollVM.poll.question)
                 .font(.headline)
             
             if pollVM.isOpen {
                 Text("Poll is open")
                     .foregroundColor(.green)
             } else {
                 Text("Poll is closed")
                     .foregroundColor(.red)
             }
             
            if !userHasVoted && auth.isLoggedIn {
                 TextField("Enter your answer", text: $newAnswer)
                 Button(action: addAnswer) {
                     Label("Add Answer", systemImage: "plus")
                 }
             }
             
             ScrollView {
                 ForEach(pollVM.answerVMs, id: \.answer.id) { answerVM in
                     HStack {
                         if userVM.user.id == answerVM.answer.userId  {
                             Button(action: { deleteAnswer(id: answerVM.answer.id) }) {
                                 Image(systemName: "trash")
                             }
                         }
                         AnswerView(answerVM: answerVM, onVoteChange: updateVote)
                     }
                 }
             }
         }
     }
    
    var userHasVoted: Bool {
        pollVM.answerVMs.contains { $0.userHasVoted }
    }
    
    func addAnswer() {
        Task {
            if !newAnswer.isEmpty {
                let newAnswerVM = AnswerVM()
                newAnswerVM.answer = Answer(id: "\(pollVM.poll.id)_\(userVM.user.id)", pollId: pollVM.poll.id, userId: userVM.user.id)
                newAnswerVM.answer.text = newAnswer
                await newAnswerVM.add()
                pollVM.answerVMs.append(newAnswerVM)
                newAnswer = ""
            }
        }
    }
 
    func deleteAnswer(id: String) {
        Task {
            if let index = pollVM.answerVMs.firstIndex(where: { $0.answer.id == id }) {
                await pollVM.answerVMs[index].delete()
                pollVM.answerVMs.remove(at: index)
            }
        }
    }

    func updateVote(answerVM: AnswerVM) {
        Task {
            // If the user has voted for this answer, remove their vote.
            if answerVM.userHasVoted {
                await answerVM.voteVM.delete()
                answerVM.userHasVoted = false
            } else {
                // If the user has voted for another answer, remove their vote from that answer.
                if let previousAnswerVM = pollVM.answerVMs.first(where: { $0.userHasVoted }) {
                    await previousAnswerVM.voteVM.delete()
                    previousAnswerVM.userHasVoted = false
                }
                // Add a vote for this answer.
                answerVM.voteVM.vote.id = userVM.user.id
                answerVM.voteVM.vote.answerId = answerVM.answer.id
                await answerVM.voteVM.add()
                answerVM.userHasVoted = true
            }
        }
    }
}


//struct PollView_Previews: PreviewProvider {
//    static var previews: some View {
//        PollView()
//    }
//}
