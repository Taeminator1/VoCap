//
//  Tip.swift
//  VoCap
//
//  Created by 윤태민 on 7/18/21.
//

//  Basic info for tip: Each element consists of fileName and viewSize

import SwiftUI

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

