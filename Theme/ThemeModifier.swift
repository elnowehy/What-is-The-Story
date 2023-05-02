import SwiftUI

struct ThemeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(GlobalTheme.padding)
            .background(GlobalTheme.backgroundColor)
            .foregroundColor(GlobalTheme.textColor)
            .accentColor(GlobalTheme.accentColor)
            .cornerRadius(GlobalTheme.cornerRadius)
            .padding(.horizontal, GlobalTheme.spacing)
            .padding(.vertical, GlobalTheme.spacing)
    }
}

extension View {
    func theme() -> some View {
        self.modifier(ThemeModifier())
    }
}
