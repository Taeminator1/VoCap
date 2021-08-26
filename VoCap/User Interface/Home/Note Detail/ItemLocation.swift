//
//  Matrix.swift
//  VoCap
//
//  Created by 윤태민 on 8/2/21.
//

//  Location of item in note:
//  - Term.
//  - Definition.

import Foundation
import SwiftUI

struct CellLocation: Equatable {
    var row: Int            // Nth from the top
    var col: Int            // left side is 0(term), and right side is 1(definition)
    
    init(_ row: Int = -1, _ col: Int = -1) {
        self.row = row
        self.col = col
    }
}
