//
//  Pallet.swift
//  VoCap
//
//  Created by 윤태민 on 9/18/21.
//

//  Struct for colors that is used for note color.

import SwiftUI

struct Pallet {
    static var colors: [(value: Color, name: String)] = [
        (.systemBlue, "Blue".localized),
        (.systemGreen, "Green".localized),
        (.systemIndigo, "Indigo".localized),
        (.systemOrange, "Orange".localized),
        (.systemPink, "Pink".localized),
        (.systemPurple, "Purple".localized),
        (.systemRed, "Red".localized),
        (.systemTeal, "Teal".localized),
        (.systemYellow, "Yellow".localized),
    ]
}
