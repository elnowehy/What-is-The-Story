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
    var mainTitle: Color
    var secondaryTitle: Color
    var menuBackground: Color
    var menuForeground: Color
    var menuText: Color
    var buttonBackground: Color
    var buttonForeground: Color
    var buttonText: Color
    var navBarBackground: Color
    var navBarForeground: Color
    var navBarText: Color
    var tableBackground: Color
    var tableForeground: Color
    var tableText: Color
    var playerBackground: Color
    var playerControlsBackground: Color
    var playerControlsForeground: Color
    var playerControlsText: Color
    var videoBackground: Color
    var videoForeground: Color
    var videoText: Color
    var ratingBackground: Color
    var ratingForeground: Color
    var ratingText: Color
    var toggleBackground: Color
    var toggleForeground: Color
    var toggleText: Color
    var errorBackground: Color
    var errorForeground: Color
    var errorText: Color
    var warningBackground: Color
    var warningForeground: Color
    var warningText: Color
    var successBackground: Color
    var successForeground: Color
    var successText: Color
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
    static let wits = Theme(
        colors: Colors(
            mainTitle: Color(red: 70/255, green: 70/255, blue: 70/255),
            secondaryTitle: Color(.gray),
            menuBackground: Color(.gray),
            menuForeground: Color(.blue),
            menuText: Color(.white),
            buttonBackground: Color(.blue),
            buttonForeground: Color(.gray),
            buttonText: Color(.white),
            navBarBackground: Color(.black),
            navBarForeground: Color(.blue),
            navBarText: Color(.white),
            tableBackground: Color(.white),
            tableForeground: Color(.gray),
            tableText: Color(.black),
            playerBackground: Color(.black),
            playerControlsBackground: Color(.gray),
            playerControlsForeground: Color(.blue),
            playerControlsText: Color(.white),
            videoBackground: Color(.black),
            videoForeground: Color(.blue),
            videoText: Color(.white),
            ratingBackground: Color(.gray),
            ratingForeground: Color(.yellow),
            ratingText: Color(.white),
            toggleBackground: Color(.gray),
            toggleForeground: Color(.blue),
            toggleText: Color(.white),
            errorBackground: Color(.red),
            errorForeground: Color(.black),
            errorText: Color(.white),
            warningBackground: Color(.orange),
            warningForeground: Color(.black),
            warningText: Color(.white),
            successBackground: Color(.green),
            successForeground: Color(.black),
            successText: Color(.white)
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
    @Published var current: Theme = .wits
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
            .foregroundColor(defaultTextColor ?? theme.colors.navBarText)
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
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.buttonText).multilineTextAlignment(.leading)
    }
}
struct H5Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.buttonText).multilineTextAlignment(.leading)
    }
}
struct H4Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.buttonText).multilineTextAlignment(.leading)
    }
}
struct H3Style :  ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.buttonText).multilineTextAlignment(.leading)
    }
}
struct H2Style : ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.body).foregroundColor(defaultTextColor ?? theme.colors.buttonText).multilineTextAlignment(.leading)
    }
}
struct H1Style : ViewModifier {
    @EnvironmentObject var theme: Theme
    var defaultTextColor : Color? = Color("OnSurface")
    
    init(defaultTextColor: Color? = nil) {
        self.defaultTextColor = defaultTextColor
    }
    
    func body(content: Content) -> some View {
        
        return content.font(theme.typography.title).foregroundColor(defaultTextColor ?? theme.colors.buttonText).multilineTextAlignment(.leading)
    }
}


