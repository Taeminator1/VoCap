//
//  ColorExtension.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

import SwiftUI

// MARK: - Note 관련 color
extension Color {
    static let buttonBackground = Color(UIColor.systemGray6)
}

// MARK: - Toolbar 등에 쓰이는 icon 및 text color
extension Color {
    static let mainColor = Color(UIColor.systemIndigo)
}

extension UIColor {
    static let mainColor = UIColor.systemIndigo
}

// MARK: - Note 안의 item 관련 color
// t: term, d: definition
extension Color {
    static let textBodyColor = Color(UIColor.systemGray6)
    static let textFieldBodyColor = Color(UIColor.clear)
    
    static let tTextStrokeColor = Color(UIColor.systemBlue)
    static let tScreenColor = Color(UIColor.systemBlue)
    static let tTextFieldStrokeColor = Color(UIColor.systemBlue)
    
    static let dTextStrokeColor = Color(UIColor.systemGreen)
    static let dScreenColor = Color(UIColor.systemGreen)
    static let dTextFieldStrokeColor = Color(UIColor.systemGreen)
}



// MARK: - myColor
struct myColor {
    static var colors: [Color] = [.systemBlue, .systemGreen, .systemIndigo, .systemOrange, .systemPink, .systemPurple, .systemRed, .systemTeal, .systemYellow]
    static var colornames = ["Blue", "Green", "Indigo", "Orange", "Pink", "Purple", "Red", "Teal", "Yellow"]
}

extension Color {

    static var label: Color {
        return Color(UIColor.label)
    }

    static var secondaryLabel: Color {
        return Color(UIColor.secondaryLabel)
    }

    static var tertiaryLabel: Color {
        return Color(UIColor.tertiaryLabel)
    }

    static var quaternaryLabel: Color {
        return Color(UIColor.quaternaryLabel)
    }

    static var systemFill: Color {
        return Color(UIColor.systemFill)
    }

    static var secondarySystemFill: Color {
        return Color(UIColor.secondarySystemFill)
    }

    static var tertiarySystemFill: Color {
        return Color(UIColor.tertiarySystemFill)
    }

    static var quaternarySystemFill: Color {
        return Color(UIColor.quaternarySystemFill)
    }

    static var systemBackground: Color {
           return Color(UIColor.systemBackground)
    }

    static var secondarySystemBackground: Color {
        return Color(UIColor.secondarySystemBackground)
    }

    static var tertiarySystemBackground: Color {
        return Color(UIColor.tertiarySystemBackground)
    }

    static var systemGroupedBackground: Color {
        return Color(UIColor.systemGroupedBackground)
    }

    static var secondarySystemGroupedBackground: Color {
        return Color(UIColor.secondarySystemGroupedBackground)
    }

    static var tertiarySystemGroupedBackground: Color {
        return Color(UIColor.tertiarySystemGroupedBackground)
    }

    static var systemRed: Color {
        return Color(UIColor.systemRed)
    }

    static var systemBlue: Color {
        return Color(UIColor.systemBlue)
    }

    static var systemPink: Color {
        return Color(UIColor.systemPink)
    }

    static var systemTeal: Color {
        return Color(UIColor.systemTeal)
    }

    static var systemGreen: Color {
        return Color(UIColor.systemGreen)
    }

    static var systemIndigo: Color {
        return Color(UIColor.systemIndigo)
    }

    static var systemOrange: Color {
        return Color(UIColor.systemOrange)
    }

    static var systemPurple: Color {
        return Color(UIColor.systemPurple)
    }

    static var systemYellow: Color {
        return Color(UIColor.systemYellow)
    }

    static var systemGray: Color {
        return Color(UIColor.systemGray)
    }

    static var systemGray2: Color {
        return Color(UIColor.systemGray2)
    }

    static var systemGray3: Color {
        return Color(UIColor.systemGray3)
    }

    static var systemGray4: Color {
        return Color(UIColor.systemGray4)
    }

    static var systemGray5: Color {
        return Color(UIColor.systemGray5)
    }

    static var systemGray6: Color {
        return Color(UIColor.systemGray6)
    }
}

