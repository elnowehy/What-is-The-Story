//
//  TextField.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-28.
//

import SwiftUI

struct witsTextFieldStyle: TextFieldStyle {
    var theme: Theme

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(theme.typography.h3)
            .padding()
            .background(theme.colors.primary)
            .foregroundColor(theme.colors.onPrimary)
            .cornerRadius(8)
    }
}

