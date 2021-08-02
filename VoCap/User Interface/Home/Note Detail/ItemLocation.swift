//
//  Matrix.swift
//  VoCap
//
//  Created by 윤태민 on 8/2/21.
//

import Foundation
import SwiftUI

struct ItemLocation: Equatable {
    var row: Int
    var col: Int
    
    init(_ row: Int = -1, _ col: Int = -1) {
        self.row = row
        self.col = col
    }
}
