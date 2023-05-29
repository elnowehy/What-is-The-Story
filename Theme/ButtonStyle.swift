//
//  ButtonStyle.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-26.
//

import SwiftUI

struct witsButtonStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.h4)
            .foregroundColor(theme.colors.onPrimary)
            .padding()
            .background(configuration.isPressed ? theme.colors.primary.opacity(0.7) : theme.colors.primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
    }
}


