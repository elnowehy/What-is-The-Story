//
//  ButtonStyle.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-26.
//

import SwiftUI

struct VideoButtonStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .foregroundColor(theme.colors.onPrimary)
            .padding()
            .background(configuration.isPressed ? theme.colors.primary.opacity(theme.opacity.enabled) : theme.colors.primary)
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(configuration.isPressed ? theme.scales.button : theme.scales.full)
    }
}

struct NavigationButtonStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .foregroundColor(theme.colors.onSurface)
            .padding()
            .background(configuration.isPressed ? theme.colors.primary.opacity(theme.opacity.enabled) : theme.colors.primary)
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(configuration.isPressed ? theme.scales.button : theme.scales.full)
    }
}

struct NavigationLinkStyle: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .font(theme.typography.button)
            .foregroundColor(theme.colors.onSurface)
            .padding()
            .background(theme.colors.primary)
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(1.0) // Apply any desired scale effect
    }
}


struct GenToggleStyle: ToggleStyle {
    var theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        Toggle(isOn: configuration.$isOn) {
            configuration.label
        }
        .font(theme.typography.button)
        .toggleStyle(SwitchToggleStyle(tint: theme.colors.primary))
    }
}

struct VideoPlayerStyle: ViewModifier {
    var theme: Theme
    @Binding var isFullScreen: Bool
    
    func body(content: Content) -> some View {
        content
            .accentColor(theme.colors.primary)
            .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
            .frame(maxWidth: .infinity, maxHeight: isFullScreen ? .infinity : UIScreen.main.bounds.height * 9/16)
            .clipped()
    }
}



struct GenTextFieldStyle: TextFieldStyle {
    var theme: Theme

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(theme.typography.body)
            .padding()
            .background(theme.colors.primary)
            .foregroundColor(theme.colors.onPrimary)
            .cornerRadius(8)
    }
}





