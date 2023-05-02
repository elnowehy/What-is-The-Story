import SwiftUI

extension View {
    func applyGlobalTheme() -> some View {
        self
            .background(GlobalTheme.backgroundColor)
            .foregroundColor(GlobalTheme.textColor)
            .accentColor(GlobalTheme.accentColor)
            .font(.body)
    }
}
