//
//  AnswerView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-06.
//

import SwiftUI

struct AnswerView: View {
    @ObservedObject var answerVM: AnswerVM
    var onVoteChange: (AnswerVM) -> Void

    var body: some View {
        HStack {
            Button(action: {
                onVoteChange(answerVM)
            }) {
                Image(systemName: answerVM.userHasVoted ? "checkmark.circle.fill" : "circle")
            }
            Text(answerVM.answer.text)
        }
    }
}





//struct AnswerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnswerView()
//    }
//}
