//
//  ColorExtension.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

//  Extension of Color for use on the VoCap App.

import SwiftUI

// MARK: - NoteDetailView의 Cell에 들어가는 색들
// t: term, d: definition
extension Color {
    static let textBodyColor = Color(UIColor.systemGray6)
    static let textFieldBodyColor = Color(UIColor.clear)
    
    static let tScreenColor = Color(UIColor.systemBlue)
    static let tTextFieldStrokeColor = Color(UIColor.systemBlue)
    
    static let dScreenColor = Color(UIColor.systemGreen)
    static let dTextFieldStrokeColor = Color(UIColor.systemGreen)
}


// MARK: - 기본 색들
extension UIColor {
    static let mainColor = UIColor.systemIndigo
}

extension Color {
    static var mainColor: Color { Color(UIColor.mainColor) }
    
    static var label: Color { Color(UIColor.label) }
    static var secondaryLabel: Color { Color(UIColor.secondaryLabel) }
    static var tertiaryLabel: Color { Color(UIColor.tertiaryLabel) }
    static var quaternaryLabel: Color { Color(UIColor.quaternaryLabel) }
    
    static var systemFill: Color { Color(UIColor.systemFill) }
    static var secondarySystemFill: Color { Color(UIColor.secondarySystemFill) }
    static var tertiarySystemFill: Color { Color(UIColor.tertiarySystemFill) }
    static var quaternarySystemFill: Color { Color(UIColor.quaternarySystemFill) }
    
    static var systemBackground: Color { Color(UIColor.systemBackground) }
    static var secondarySystemBackground: Color { Color(UIColor.secondarySystemBackground) }
    static var tertiarySystemBackground: Color { Color(UIColor.tertiarySystemBackground) }
    static var systemGroupedBackground: Color { Color(UIColor.systemGroupedBackground) }
    static var secondarySystemGroupedBackground: Color { Color(UIColor.secondarySystemGroupedBackground) }
    static var tertiarySystemGroupedBackground: Color { Color(UIColor.tertiarySystemGroupedBackground) }
    
    static var systemRed: Color { Color(UIColor.systemRed) }
    static var systemBlue: Color { Color(UIColor.systemBlue) }
    static var systemPink: Color { Color(UIColor.systemPink) }
    static var systemTeal: Color { Color(UIColor.systemTeal) }
    static var systemGreen: Color { Color(UIColor.systemGreen) }
    static var systemIndigo: Color { Color(UIColor.systemIndigo) }
    static var systemOrange: Color { Color(UIColor.systemOrange) }
    static var systemPurple: Color { Color(UIColor.systemPurple) }
    static var systemYellow: Color { Color(UIColor.systemYellow) }
    
    static var systemGray: Color { Color(UIColor.systemGray) }
    static var systemGray2: Color { Color(UIColor.systemGray2) }
    static var systemGray3: Color { Color(UIColor.systemGray3) }
    static var systemGray4: Color { Color(UIColor.systemGray4) }
    static var systemGray5: Color { Color(UIColor.systemGray5) }
    static var systemGray6: Color { Color(UIColor.systemGray6) }
}

