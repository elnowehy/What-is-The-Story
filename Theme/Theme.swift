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
}

struct Colors {
    var text: Color
    var primaryBackground: Color
    var secondaryBackground: Color
    var tertiaryBackground: Color
    var shadow: Color
    var accent: Color

}

struct Spacing{
    var large:CGFloat
    var medium:CGFloat
    var small:CGFloat
    var button: CGFloat
    var cardPadding: CGFloat
}

struct Shapes{
    var largeCornerRadius: CGFloat
    var mediumCornerRadius: CGFloat
    var smallCornerRadius: CGFloat
    var cardCornerRadius: CGFloat
    var shadowRadius: CGFloat
}

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

struct Dimensions {
    var cardWidth: Double
    var cardHieght: Double
    var photoWidth: Double
    var photoHeight: Double
    var thumbWidth: Double
    var thumbHieght: Double
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
    let dimensions: Dimensions
    
// consider adding the following:
//    var borderStyles: BorderStyles
//    var shadowStyles: ShadowStyles
//    var scales: Scales
//    var opacity: Opacity
//    var iconography: Iconography
//    var animation: Animation
    
    init(colors: Colors, shapes: Shapes, spacing: Spacing, typography: Typography, scales: Scales, opacity: Opacity, dimensions: Dimensions) {
        self.colors = colors
        self.shapes = shapes
        self.spacing = spacing
        self.typography = typography
        self.scales = scales
        self.opacity = opacity
        self.dimensions = dimensions
    }
}

extension Theme {
    static let wits = Theme(
        colors: Colors(
            text: Color(red: 70/255, green: 70/255, blue: 70/255),
            primaryBackground: Color(.white),
            secondaryBackground: Color(red:233/255, green: 233/255, blue: 231/255),
            tertiaryBackground: Color(red:233/255, green: 233/255, blue: 221/255),
            shadow: Color(red: 181/255, green: 181/255, blue: 181/255),
            accent: Color(red: 91/255, green: 144/255, blue: 180/255)
        ),
        
        shapes: Shapes(
            largeCornerRadius: 15,
            mediumCornerRadius: 10,
            smallCornerRadius: 5,
            cardCornerRadius: 5,
            shadowRadius: 5
        ),
        
        spacing: Spacing(
            large: 24,
            medium: 16,
            small: 8,
            button: 8,
            cardPadding: 4
        ),
        
        typography: Typography(
            title: .headline,
            subtitle: .subheadline,
            body: .body,
            caption: .caption,
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
        ),
        
        dimensions: Dimensions (
            cardWidth: 80.0,
            cardHieght: 95.0,
            photoWidth: 150,
            photoHeight: 350,
            thumbWidth: 50,
            thumbHieght: 50
        )
    )
    
}

class ThemeManager: ObservableObject {
    @Published var current: Theme = .wits
}






