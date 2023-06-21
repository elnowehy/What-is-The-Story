//
//  ButtonStyle.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-26.
//

import SwiftUI

struct TextFieldBaseStyle: TextFieldStyle {
    var theme: Theme
    var maxWidth: CGFloat? = nil // Add this

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(theme.typography.text)
            .padding(5)
            .background(theme.colors.tertiaryBackground)
            .foregroundColor(theme.colors.text)
            .cornerRadius(8)
            .shadow(color: theme.colors.shadow, radius: theme.shapes.shadowRadius)
            .frame(maxWidth: maxWidth)
    }
}

struct TextFieldLoginStyle: TextFieldStyle {
    var theme: Theme
    var maxWidth: CGFloat? = nil // Add this

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(theme.typography.subtitle)
            .padding(5)
            .background(theme.colors.tertiaryBackground)
            .foregroundColor(theme.colors.text)
            .cornerRadius(8)
            .shadow(color: theme.colors.shadow, radius: theme.shapes.shadowRadius)
            .frame(maxWidth: maxWidth)
    }
}

struct TagTextBaseStyle: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .font(theme.typography.button)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.colors.secondaryBackground)
            .foregroundColor(theme.colors.text)
            .cornerRadius(8)
    }
}


struct ButtonBaseStyle: ButtonStyle {
    var theme: Theme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .foregroundColor(theme.colors.primaryBackground) // Text color for the button text
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(configuration.isPressed ? theme.colors.secondaryBackground.opacity(theme.opacity.enabled) : theme.colors.accent) // Secondary background for the button color
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(configuration.isPressed ? theme.scales.button : theme.scales.full)
    }
}

struct NavigationLinkStyle: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .font(theme.typography.button)
            .foregroundColor(theme.colors.primaryBackground)
            .padding(theme.spacing.button)
            .background(theme.colors.accent) 
            .cornerRadius(theme.shapes.largeCornerRadius)
            .scaleEffect(1.0) // Apply any desired scale effect
    }
}

struct ToggleBaseStyle: ToggleStyle {
    var theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        Toggle(isOn: configuration.$isOn) {
            configuration.label
        }
        .toggleStyle(SwitchToggleStyle(tint: theme.colors.accent))
    }
}

struct VideoPlayerStyle: ViewModifier {
    var theme: Theme
    @Binding var isFullScreen: Bool
    
    func body(content: Content) -> some View {
        content
            .accentColor(theme.colors.text)
            .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.text))
            .frame(maxWidth: .infinity, maxHeight: isFullScreen ? .infinity : UIScreen.main.bounds.height * 9/16)
            .clipped()
    }
}

struct TabViewBaseStyle: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .accentColor(theme.colors.accent)
            .tabViewStyle(.automatic)
            .background(theme.colors.primaryBackground)
            .edgesIgnoringSafeArea(.top)
            .ignoresSafeArea(.keyboard)
    }
}

struct LargeTitleStyle: ViewModifier {
    var theme: Theme

    func body(content: Content) -> some View {
        content
            .font(theme.typography.title)
            .padding(.horizontal)
            .foregroundColor(theme.colors.text)
    }
}

struct TextBaseStyle: ViewModifier {
    var theme: Theme

    func body(content: Content) -> some View {
        content
            .font(theme.typography.text)
            .padding(.horizontal)
            .foregroundColor(theme.colors.text)
    }
}

struct RowBaseStyle: ViewModifier {
    var theme: Theme

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .background(theme.colors.primaryBackground)
            .cornerRadius(8)
    }
}

struct CategoryButtonStyle: ButtonStyle {
    var theme: Theme
    var isSelected: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .padding(.horizontal, theme.spacing.button)
            .padding(.vertical, theme.spacing.button)
            .background(isSelected ? theme.colors.text : theme.colors.secondaryBackground)
            .foregroundColor(isSelected ? theme.colors.primaryBackground : theme.colors.text)
            .cornerRadius(theme.spacing.button)
    }
}

struct CardStyleModifier: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: theme.dimensions.cardWidth, height: theme.dimensions.cardHieght)
            //.clipped()
            .cornerRadius(theme.spacing.cardPadding)
            .background(theme.colors.tertiaryBackground)
    }
}

struct ThumbStyleModifier: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: theme.dimensions.thumbWidth, height: theme.dimensions.thumbHieght)
            .clipShape(Circle())
            .cornerRadius(theme.spacing.cardPadding)
            .background(theme.colors.tertiaryBackground)
    }
}

struct PhotoStyleModifier: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: theme.dimensions.photoWidth, height: theme.dimensions.photoHeight)
            // .clipped()
            .cornerRadius(theme.spacing.cardPadding)
            .border(theme.colors.accent, width: theme.spacing.small)
            .background(theme.colors.tertiaryBackground)
    }
}

struct PosterStyleModifier: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: theme.dimensions.photoWidth, height: theme.dimensions.photoHeight)
            // .clipped()
            .cornerRadius(theme.spacing.cardPadding)
            .border(theme.colors.accent, width: theme.spacing.small)
            .background(theme.colors.tertiaryBackground)
    }
}

extension View {
    func cardStyle(theme: Theme) -> some View {
        self.modifier(CardStyleModifier(theme: theme))
    }
    
    func photoStyle(theme: Theme) -> some View {
        self.modifier(PhotoStyleModifier(theme: theme))
    }
    
    func thumbStyle(theme: Theme) -> some View {
        self.modifier(ThumbStyleModifier(theme: theme))
    }
}









