import SwiftUI

struct GlobalThemePreview: View {
    var body: some View {
        VStack(spacing: GlobalTheme.spacing) {
            Text("Primary Color")
                .font(GlobalTheme.titleFont)
                .foregroundColor(GlobalTheme.textColor)
            Rectangle()
                .frame(height: 100)
                .foregroundColor(GlobalTheme.primaryColor)
            Text("Secondary Color")
                .font(GlobalTheme.titleFont)
                .foregroundColor(GlobalTheme.textColor)
            Rectangle()
                .frame(height: 100)
                .foregroundColor(GlobalTheme.secondaryColor)
            Text("Accent Color")
                .font(GlobalTheme.titleFont)
                .foregroundColor(GlobalTheme.textColor)
            Rectangle()
                .frame(height: 100)
                .foregroundColor(GlobalTheme.accentColor)
        }
        .padding(GlobalTheme.padding)
        .background(GlobalTheme.backgroundColor)
        .theme()
    }
}

struct GlobalThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        GlobalThemePreview()
            .previewLayout(.sizeThatFits)
    }
}
