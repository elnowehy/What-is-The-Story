//
//  PollUpdateView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-07-04.
//

import SwiftUI

struct PollUpdateView: View {
    @ObservedObject var pollVM: PollVM

    var body: some View {
        VStack {
            TextField("Question", text: $pollVM.poll.question)
                .padding(.top, 20)
                .autocapitalization(.sentences)

            DatePicker("Poll Closing Date", selection: $pollVM.poll.closingDate, in: Date()...)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
        }
    }
}

//struct PollUpdateView_Previews: PreviewProvider {
//    static var previews: some View {
//        PollUpdateView()
//    }
//}
