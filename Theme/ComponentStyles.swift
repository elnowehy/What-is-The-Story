//
//  ButtonStyle.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-26.
//

import SwiftUI

struct ButtonBaseStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .foregroundColor(theme.colors.buttonForeground)
            .padding()
            .background(configuration.isPressed ? theme.colors.buttonBackground.opacity(theme.opacity.enabled) : theme.colors.buttonBackground)
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(configuration.isPressed ? theme.scales.button : theme.scales.full)
    }
}


struct VideoButtonStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .buttonStyle(ButtonBaseStyle(theme: theme))
            .foregroundColor(theme.colors.videoForeground)
            .background(configuration.isPressed ? theme.colors.videoBackground.opacity(theme.opacity.enabled) : theme.colors.videoBackground)
    }
}


struct NavigationButtonStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .foregroundColor(theme.colors.menuForeground)
            .padding()
            .background(configuration.isPressed ? theme.colors.buttonBackground.opacity(theme.opacity.enabled) : theme.colors.buttonBackground)
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(configuration.isPressed ? theme.scales.button : theme.scales.full)
    }
}

struct NavigationLinkStyle: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .font(theme.typography.button)
            .foregroundColor(theme.colors.menuForeground)
            .padding()
            .background(theme.colors.menuBackground)
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
        .toggleStyle(SwitchToggleStyle(tint: theme.colors.toggleBackground))
    }
}

struct VideoPlayerStyle: ViewModifier {
    var theme: Theme
    @Binding var isFullScreen: Bool
    
    func body(content: Content) -> some View {
        content
            .accentColor(theme.colors.videoBackground)
            .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.videoBackground))
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
            .background(theme.colors.buttonText)
            .foregroundColor(theme.colors.buttonForeground)
            .cornerRadius(8)
    }
}

struct GenTabViewStyle: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .accentColor(theme.colors.menuForeground)
            .tabViewStyle(.automatic)
            .listStyle(.inset)
            .background(theme.colors.menuBackground)
            .edgesIgnoringSafeArea(.top)
            .ignoresSafeArea(.keyboard)
    }
}

struct SeriesTitleStyle: ViewModifier {
    var theme: Theme

    func body(content: Content) -> some View {
        content
            .font(theme.typography.title)
            .padding(.horizontal)
            .foregroundColor(theme.colors.mainTitle)
    }
}

struct GenRowStyle: ViewModifier {
    var theme: Theme

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .background(theme.colors.menuBackground)
            .cornerRadius(theme.shapes.smallCornerRadius)
    }
}

struct GenListViewStyle: ViewModifier {
    var theme: Theme

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .background(theme.colors.menuBackground)
    }
}

struct CategoryButtonStyle: ButtonStyle {
    var theme: Theme
    var isSelected: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? theme.colors.tableBackground : theme.colors.menuBackground)
            .foregroundColor(isSelected ? theme.colors.buttonForeground : theme.colors.buttonBackground)
            .cornerRadius(theme.shapes.smallCornerRadius)
    }
}








