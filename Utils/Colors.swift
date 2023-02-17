//
//  Colors.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-16.
//

import SwiftUI

// convert Color to string
// let color = Color.white
// let hexString = color.toHexString() // returns "#FFFFFF"
extension Color {
    func toHexString() -> String? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
}

// convert a string to Color
// let colorString = "#00ff00"
// let color = Color(hex: colorString)

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0xFF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
    }
}
