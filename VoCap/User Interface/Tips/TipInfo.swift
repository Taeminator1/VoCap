//
//  Tip.swift
//  VoCap
//
//  Created by 윤태민 on 7/18/21.
//

//  Basic info for tip: Each element consists of fileName and viewSize
//  If you want to add another tip:
//  - Add case of TipType enumeration and
//  - Add element of tips in TipInfo structure.

import SwiftUI

enum TipType: Int {
    case tip0 = 0       // Tip for how to add item.
    case tip1 = 1       // Tip for how to glnace item.
}

struct TipInfo {
    static let tips: [Tip] = [
        Tip(fileName: "HowToAddItem",       viewSize: (300.0, 350.0)),
        Tip(fileName: "HowToGlanceItem",    viewSize: (280.0, 210.0))
    ]
    
    struct Tip {
        var fileName: String
        var viewSize: (width: CGFloat, height: CGFloat)
    }
}
