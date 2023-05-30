//
//  Theme.swift
//  SwiftUIThemingExample
//
//  Created by Kashif.Mehmood on 18/01/2023.
//

import SwiftUI

struct Typography{
    var title: Font
    var subtitle: Font
    var body: Font
    var caption: Font
    var button: Font
    var text:Font

    

    func h6Style(color: Color = Color("OnSurface")) -> some ViewModifier {
        return H6Style(defaultTextColor: color)
    }
    func h5Style(color: Color = Color("OnSurface"))-> some ViewModifier {
        return H6Style(defaultTextColor: color)
    }
    func h4Style(color: Color = Color("OnSurface")) -> some ViewModifier {
        return H6Style(defaultTextColor: color)
    }
    func h3Style(color: Color = Color("OnSurface"))-> some ViewModifier {
        return H6Style(defaultTextColor: color)
    }
    func h2Style(color: Color = Color("OnSurface")) -> some ViewModifier {
        return H6Style(defaultTextColor: color)
    }
    func h1Style(color: Color = Color("OnSurface")) -> some ViewModifier {
        return H6Style(defaultTextColor: color)
    }

    
}

struct Colors {
    var primary: Color
    var secondary: Color
    var primaryVariant: Color
    var backGround: Color
    var surface: Color
    var onPrimary: Color
    var onBackGround: Color
    var onSurface : Color
    var onError: Color
    var error: Color
    var warning: Color
    var success: Color
    
}

struct Spacing{
    var largeSpacing:CGFloat
    var mediumSpacing:CGFloat
    var smallSpacing:CGFloat
    var extraLargeSpacing: CGFloat
}

struct Shapes{
    
    var largeCornerRadius:CGFloat
    var mediumCornerRadius:CGFloat
    var smallCornerRadius:CGFloat
}

//struct BorderStyles {
//    var button: BorderStyle
//    var textField: BorderStyle
//}
//
//struct BorderStyle {
//    var width: CGFloat
//    var color: Color
//    var style: BorderStyleType // You need to define this enum based on your needs
//}
//
//struct ShadowStyles {
//    var buttonShadow: ShadowStyle
//    var cardShadow: ShadowStyle
//}
//
//struct ShadowStyle {
//    var color: Color
//    var radius: CGFloat
//    var x: CGFloat
//    var y: CGFloat
//    var opacity: Double
//}
//
struct Scales {
    var button: CGFloat
    var card: CGFloat
    var full: CGFloat
}

struct Opacity {
    var enabled: Double
    var disabled: Double
    var hover: Double
}

//struct Iconography {
//    var standardIconSize: CGSize
//}
//
//struct Animation {
//    var standardDuration: Double
//    var standardEasing: Animation // You will have to customize this as per your requirement
//}

class Theme : ObservableObject{
    let colors: Colors
    let shapes: Shapes
    let spacing: Spacing
    let typography: Typography
    let scales: Scales
    let opacity: Opacity
    
// consider adding the following:
//    var borderStyles: BorderStyles
//    var shadowStyles: ShadowStyles
//    var scales: Scales
//    var opacity: Opacity
//    var iconography: Iconography
//    var animation: Animation
    
    init(colors: Colors, shapes: Shapes, spacing: Spacing, typography: Typography, scales: Scales, opacity: Opacity) {
        self.colors = colors
        self.shapes = shapes
        self.spacing = spacing
        self.typography = typography
        self.scales = scales
        self.opacity = opacity
    }
}

extension Theme {
//    static let dark = Theme(
//
//        colors: Colors(primary: Color("Primary"), secondary: Color("Secondary"), primaryVariant: Color("PrimaryVariant"), backGround: Color("Background"), surface: Color("Surface"), onPrimary: Color("OnPrimary"), onBackGround: Color("OnBackGround"), onSurface: Color("OnSurface"), onError: Color("OnError"), error: Color("Error"), warning: Color("Warning"), success: Color("Success")),
//
//        shapes: Shapes(largeCornerRadius: 16, mediumCornerRadius: 12, smallCornerRadius: 8),
//
//        spacing: Spacing(largeSpacing: 24, mediumSpacing: 16, smallSpacing: 8, extraLargeSpacing: 32),
//
//        typography: Typography(h1: Font.custom("NunitoSans-Bold", size: 3), h2:Font.custom("NunitoSans-Bold", size: 24), h3: Font.custom("NunitoSans-Bold", size: 18), h4: Font.custom("NunitoSans-Bold", size: 14), h5: Font.custom("NunitoSans-Bold", size: 12), h6: Font.custom("NunitoSans-Bold", size: 10), body1: Font.custom("NunitoSans-Regular", size: 14), body2: Font.custom("NunitoSans-Regular", size: 14))
//    )
//
//    static let light = Theme(
//
//        colors: Colors(primary: Color("Primary"), secondary: Color("Secondary"), primaryVariant: Color("PrimaryVariant"), backGround: Color("Background"), surface: Color("Surface"), onPrimary: Color("OnPrimary"), onBackGround: Color("OnBackGround"), onSurface: Color("OnSurface"), onError: Color("OnError"), error: .green, warning: Color("Warning"), success: Color("Success")),
//
//        shapes: Shapes(largeCornerRadius: 16, mediumCornerRadius: 12, smallCornerRadius: 8),
//
//        spacing: Spacing(largeSpacing: 24, mediumSpacing: 16, smallSpacing: 8, extraLargeSpacing: 32),
//
//        typography: Typography(h1: Font.custom("NunitoSans-Bold", size: 32), h2:Font.custom("NunitoSans-Bold", size: 24), h3: Font.custom("NunitoSans-Bold", size: 18), h4: Font.custom("NunitoSans-Bold", size: 14), h5: Font.custom("NunitoSans-Bold", size: 12), h6: Font.custom("NunitoSans-Bold", size: 10), body1: Font.custom("NunitoSans-Regular", size: 14), body2: Font.custom("NunitoSans-Regular", size: 14)))
    
    static let goofy = Theme(
        colors: Colors(
            primary: Color(.red), // vibrant red
            secondary: Color(.green), // bright yellow
            primaryVariant: Color(.brown), // deep blue
            backGround: Color(.cyan), // soft yellow background
            surface: Color(.cyan), // soft yellow surface
            onPrimary: Color.white,
            onBackGround: Color(.darkGray), // deep blue text on yellow
            onSurface: Color(.orange), // deep blue text on yellow
            onError: Color.red,
            error: Color.red,
            warning: Color.orange,
            success: Color.green
        ),
        
        shapes: Shapes(
            largeCornerRadius: 15,
            mediumCornerRadius: 10,
            smallCornerRadius: 5
        ),
        
        spacing: Spacing(
            largeSpacing: 24,
            mediumSpacing: 16,
            smallSpacing: 8,
            extraLargeSpacing: 32
        ),
        
        typography: Typography(
            title: Font.system(size: 20, weight: .bold, design: .rounded),
            subtitle: Font.system(size: 18, weight: .bold, design: .rounded),
            body: Font.system(size: 16, weight: .bold, design: .rounded),
            caption: Font.system(size: 14, weight: .bold, design: .rounded),
            button: Font.system(size: 12, weight: .bold, design: .rounded),
            text: Font.system(size: 10, weight: .bold, design: .rounded)

        ),
        
        scales: Scales(
            button: 1.1,
            card: 1.1,
            full: 1.0
        ),
        
        opacity: Opacity(
            enabled: 1.0,
            disabled: 0.0,
            hover: 0.5
        )
    )
    
}

class ThemeManager: ObservableObject {
    @Published var current: Theme = .goofy
}


struct LargeTitleStyle: ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color?
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(theme.typography.text)
            .foregroundColor(defaultTextColor ?? theme.colors.primaryVariant)
            .multilineTextAlignment(.leading)
    }
}



struct H6Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.primaryVariant).multilineTextAlignment(.leading)
    }
}
struct H5Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.primaryVariant).multilineTextAlignment(.leading)
    }
}
struct H4Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.primaryVariant).multilineTextAlignment(.leading)
    }
}
struct H3Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.primaryVariant).multilineTextAlignment(.leading)
    }
}
struct H2Style : ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.body).foregroundColor(defaultTextColor ?? theme.colors.primaryVariant).multilineTextAlignment(.leading)
    }
}
struct H1Style : ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.primaryVariant).multilineTextAlignment(.leading)
    }
}


