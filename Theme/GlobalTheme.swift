// Define the colors, fonts, and other properties that we want to use in our app

import SwiftUI

struct GlobalTheme {
    static let primaryColor = Color(.red)
    static let secondaryColor = Color(.white)
    static let accentColor = Color(.red)
    static let backgroundColor = Color(.black)
    static let textColor = Color(.white)
    static let placeholderColor = Color(.gray)
    static let borderColor = Color(.clear)
    static let errorColor = Color(.yellow)
    
    static let titleFont = Font.custom("HelveticaNeue-Bold", size: 24)
    static let subtitleFont = Font.custom("HelveticaNeue-Medium", size: 18)
    static let bodyFont = Font.custom("HelveticaNeue-Light", size: 16)
    static let captionFont = Font.custom("HelveticaNeue-Light", size: 14)
    
    static let padding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 8
}

extension Color {
    static let primary = GlobalTheme.primaryColor
    static let secondary = GlobalTheme.secondaryColor
    static let accent = GlobalTheme.accentColor
    static let background = GlobalTheme.backgroundColor
    static let text = GlobalTheme.textColor
    static let placeholder = GlobalTheme.placeholderColor
    static let border = GlobalTheme.borderColor
    static let error = GlobalTheme.errorColor
}

extension Font {
    static let title = GlobalTheme.titleFont
    static let subtitle = GlobalTheme.subtitleFont
    static let body = GlobalTheme.bodyFont
    static let caption = GlobalTheme.captionFont
}
